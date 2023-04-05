 -- Soccer EURO-CUP 2016 Analysis --
 
select * from countries;
select * from city;
select * from assist_referee_mt;
select * from coach_mt;
select * from goal_details;
select * from match_captain;
select * from match_details;
select * from match_mt;
select * from penalty_gk;
select * from penalty_shootout;
select * from player_booked;
select * from player_in_out;
select * from player_mt;
select * from player_positions;
select * from referee_mt;
select * from teams;
select * from team_coaches;
select * from venue;


-- Queries -- 

#1. count the number of venues for EURO cup 2016 ?
select count(*) as no_of_venue from venue;


#2. count the number of countries that participated in the 2016-EURO Cup ?
select count(distinct(team_id)) as no_of_countries from player_mt;


#3. find the number of goals scored in EURO cup 2016 within normal time schedule ?
select count(goal_id) as no_of_goals from goal_details
where goal_schedule = 'NT';


#4. find the number of matches ended with a result ?
select count(match_no) as no_of_matches from match_mt
where results is not null;


#5. find the number of matches ended with draws ?
select count(match_no) as no_of_matches from match_mt
where results = 'DRAW';


#6. find the date when Football EURO cup 2016 begins ?
select min(play_date) as 'EURO cup 2016 begins' from match_mt;


#7. find the number of self-goals scored in EURO cup 2016 ?
 select count(goal_type) as 'no of self goals' from goal_details
 where goal_type = 'O';


#8. find the number of goal scored in every match within normal play schedule. Sort the result-set on match number. Return match number, number of goal scored ?
select match_no,count(goal_id) as no_of_goal_scored
from goal_details
group by match_no
order by match_no;


#9. find those matches where no stoppage time added in the first half of play. Return match no, date of play, and goal scored ?
select match_no, play_date, goal_score from match_mt
where stop1_sec = 0;


#10. count the number of matches ending with a goalless draw in-group stage of play. Return number of matches ?
select count(distinct(match_no)) as no_of_matches from match_details
where win_lose = 'D' and 
goal_score = '0' and
play_stage = 'G'; 


#12. find the players with shot number they taken in penalty shootout matches. Return match_no, Team, player_name, jersey_no, score_goal, kick_no ?
select ps.match_no, pt.playing_club,pt.Player_name,pt.jersey_no,ps.score_goal,ps.kick_no from 
penalty_shootout as ps
inner join 
player_mt as pt
on ps.player_id = pt.player_id;


#13. count the number of penalty shots taken by the teams. Return country name, number of shots as “Number of Shots” ?
select c.country_name,count(ps.kick_id) as no_of_shots 
from countries as c
inner join 
penalty_shootout  as ps
on c.country_id = ps.team_id
group by c.country_name
order by count(ps.kick_id) desc, c.country_name ;


#14. count the number of booking happened in each half of play within normal play schedule. Return play_half, play_schedule, number of booking happened ?
select * from player_in_out;
select * from player_booked;

select play_half,play_schedule, count(*) as 'no of booking'
from player_booked
where play_schedule = 'NT' 
group by play_half,play_schedule ;


#15. find the winner of EURO cup 2016. Return country name ?
select * from match_details;
select * from countries;

-- Subquery
select country_name from countries where country_id = (
select team_id from match_details
where play_stage = 'F' and win_lose = 'W'
);

-- Joins
select c.country_name
from countries as c
inner join match_details as md
on c.country_id = md.team_id
where md.play_stage = 'F' and md.win_lose = 'W' ;

-- CTE
with cte as (
select c.country_name from countries as c
inner join match_details as md
on c.country_id = md.team_id 
where md.play_stage = 'F' and md.win_lose = 'W'
)
select * from cte;



#16. find the most watched match in the world. Return match_no, play_stage, goal_score, audience ?
select * from match_details;
select * from match_mt;

select match_no,play_stage,goal_score,audence from match_mt 
where audence in (select max(audence) from match_mt);


#17. find the match number in which Germany played against Poland. Group the result set on match number. Return match number ?
select * from countries;
select * from match_details;

select match_no as no_of_match from match_details as md
inner join countries as c
on md.team_id = c.country_id
where c.country_name = 'Germany' or c.country_name = 'Poland'
group by match_no 
having count(match_no) = 2; 



#18. find those players who scored number of goals in every match. Group the result set on match number, country name and player name. 
#Sort the result-set in ascending order by match number. Return match number, country name, player name and number of matches ?
select * from countries;
select * from player_mt;
select * from goal_details;

select gd.match_no,c.country_name,p.player_name,count(gd.goal_id) as no_of_goals
from goal_details as gd
inner join countries as c
on gd.team_id = c.country_id
inner join player_mt as p
on gd.player_id = p.player_id
group by gd.match_no,c.country_name,p.player_name
order by gd.match_no asc;


#19. find the players who were the goalkeepers of England squad in 2016-EURO cup. Return player name, jersey number, club name ?
select p.player_name,p.jersey_no,p.playing_club from player_mt as p
inner join countries as c
on p.team_id = c.country_id
where posi_to_play = 'GK' and c.country_name = 'England';


#20. find the players under contract to Liverpool were in the Squad of England in 2016-EURO cup. 
# Return player name, jersey number, position to play, age ?
select * from player_mt;
select * from country;

select player_name,jersey_no,posi_to_play,age from player_mt where team_id = (
select country_id from countries where country_name = 'England' and playing_club = 'Liverpool' 
);



#21. find the maximum penalty shots taken by the teams. Return country name, maximum penalty shots ?
select * from penalty_shootout;
select * from countries;

select c.country_name, MAX(t.count) as max_penalty_shots
from countries as c
inner join
(
select team_id, match_no, COUNT(kick_id) as count
from penalty_shootout
group by team_id, match_no
) AS t
on c.country_id = t.team_id
group by c.country_name
order by MAX(t.count) desc;

 

#22. count the number of goals scored by each player within normal play schedule. 
#Group the result set on player name and country name and sorts the result-set according to the highest to the lowest scorer. 
# Return player name, number of goals and country name ? 
select * from goal_details;
select * from player_mt;
select * from countries;

select p.player_name,count(gd.goal_id) as no_of_goals,c.country_name
from player_mt as p
inner join goal_details as gd
on p.player_id = gd.player_id
inner join countries as c
on p.team_id = c.country_id
where gd.goal_schedule = 'NT'
group by p.player_name,c.country_name;



#23. find the highest individual scorer in EURO cup 2016. Return player name, country name and highest individual scorer ?
select * from player_mt;
select * from countries;
select * from goal_details;

select p.player_name,c.country_name,count(gd.goal_id) as 'highest individual goal scorer'from player_mt as p
inner join countries as c
on p.team_id = c.country_id
inner join goal_details as gd
on gd.player_id = p.player_id
group by p.player_name, c.country_name
having count(goal_id) = (
select count(goal_id) as no_of_goals from player_mt as p
inner join goal_details as gd
on p.player_id = gd.player_id
group by p.player_name,c.country_name
order by count(gd.goal_id) desc limit 1
);


#24. count the number of matches played in each venue. Sort the result-set on venue name. Return Venue name, city, and number of matches ?
select * from venue;
select * from city;
select * from match_mt;

select venue_name,city,count(m.match_no) as no_of_matches from venue as v
inner join city as c
on v.city_id = c.city_id
inner join match_mt as m
on v.venue_id = m.venue_id 
group by venue_name,city
order by venue_name;


#25. find the team(s) who conceded the most goals in EURO cup 2016. Return country name, team group and match played ?
select * from teams;
select * from countries;

select c.country_name,t.team_group,t.match_played,t.goal_agnst as most_goals
from teams as t
inner join countries as c
on c.country_id = t.team_id
where t.goal_agnst = 
(
select goal_agnst from teams order by goal_agnst desc limit 1
)
order by t.goal_agnst desc ;



#26. find the goal scored by the players according to their playing position. Return country name, position to play, number of goals ?
select * from countries;
select * from player_mt;
select * from goal_details;

select c.country_name,p.posi_to_play,count(gd.goal_id) as 'no of goals'
from countries as c
inner join player_mt as p
on c.country_id = p.team_id
inner join goal_details as gd
on gd.player_id = p.player_id
group by c.country_name,p.posi_to_play
order by p.posi_to_play,c.country_name ; 



#27. find those players who came into the field at the last time of play. 
# Return match number, country name, player name, jersey number and time in out ?
select * from player_mt;
select * from player_in_out;
select * from countries;

select pio.match_no,c.country_name,p.player_name,p.jersey_no,pio.time_in_out
from player_in_out as pio
inner join 
countries as c
on pio.team_id = c.country_id
inner join player_mt as p
on pio.player_id = p.player_id
where (pio.in_out = "I" and pio.time_in_out = "90" and play_schedule = "NT") or
pio.in_out = "I" and pio.time_in_out = "120" and play_schedule = "ET"
order by pio.match_no , pio.time_in_out ;



#28. find the referees and number of booked they made. Return referee name, number of matches ?
select * from referee_mt;
select * from player_booked;
select * from match_mt;

select r.referee_name,count(pb.match_no) as no_of_booked from referee_mt as r
inner join match_mt as m
on r.referee_id = m.referee_id
inner join player_booked as pb
on m.match_no = pb.match_no
group by r.referee_name
order by no_of_booked desc ;



#29. find the players along with their team booked number of times in the tournament. 
#show the result according to the team and number of times booked in descending order. 
#Return country name, player name, and team booked number of times ?

select * from countries;
select * from player_mt;
select * from player_booked;

select c.country_name,p.player_name,count(pb.team_id) as booked_no_of_times
from player_mt as p
inner join player_booked as pb 
on p.player_id = pb.player_id
inner join countries as c
on c.country_id = pb.team_id
group by c.country_name,p.player_name
order by c.country_name, p.player_name desc ;



#30. Return match number, play date, country name, player of the Match, jersey number. ?
select * from match_mt;
select * from countries;
select * from player_mt;

select m.match_no,m.play_date,c.country_name,p.player_name,p.jersey_no
from match_mt as m
inner join player_mt as p
on m.plr_of_match = p.player_id
inner join countries as c
on p.team_id = c.country_id
order by m.match_no ;



























