select count(vehicle_id) 
from stolen_vehicles

-- OBJECTIVE 1: Find the number of vehicles each year
select count(vehicle_id) as number_of_vehicles_stolen, year(date_stolen) as inYear
from stolen_vehicles
group by year(date_stolen)

-- OBJECTIVE 2 : Find the number of vehicles stolen each month
select count(vehicle_id) as number_of_vehicles_stolen, month(date_stolen) as inMonth
from stolen_vehicles
group by MONTH(date_stolen)
order by inMonth

select count(vehicle_id) as number_of_vehicles_stolen, month(date_stolen) as inMonth, year(date_stolen) as inYear
from stolen_vehicles
group by MONTH(date_stolen), year(date_stolen)
order by year(date_stolen), month(date_stolen)

-- OBJECTIVE 3 : Find number of vehicles stolen each day of the week
-- as day number 
select datepart(dw, date_stolen) as DayoftheWeek, count(vehicle_id) as number_of_vehicles_stolen
from stolen_vehicles
group by datepart(dw, date_stolen)
order by dayoftheweek

--as day name
select datename(dw, date_stolen) as DayoftheWeek, count(vehicle_id) as number_of_vehicles_stolen
from stolen_vehicles
group by datename(dw, date_stolen)
order by DayoftheWeek

--sort by dayName
select count(vehicle_id) as number_of_vehicles_stolen, datepart(dw, date_stolen) as DayoftheWeek,
	case when datepart(dw, date_stolen) = 1 then 'Sunday'
		 when datepart(dw, date_stolen) = 2 then 'Monday'
		 when datepart(dw, date_stolen) = 3 then 'Tuesday'
		 when datepart(dw, date_stolen) = 4 then 'Wednesday'
		 when datepart(dw, date_stolen) = 5 then 'Thursday'
		 when datepart(dw, date_stolen) = 6 then 'Friday'
		 else 'Saturday' end as dow
from stolen_vehicles
group by datepart(dw, date_stolen)
order by DayoftheWeek
/*
on which day of the week were most vehicles stolen
order by number_of_vehicles_stolen desc
*/

-- OBJECTIVE 4: Find vehicle types that are most often and least often stolen
select vehicle_type, count(vehicle_id) as number_of_vehicles
from stolen_vehicles
group by vehicle_type
order by number_of_vehicles desc

-- OBJECTIVE 5: Average age of each vehicle type
select top 10 vehicle_type, avg(cast(year(date_stolen) - model_year as float)) as avgAge 
from stolen_vehicles
group by vehicle_type
order by avgAge asc

select top 10 vehicle_type, avg(cast(year(date_stolen) - model_year as float)) as avgAge 
from stolen_vehicles
group by vehicle_type
order by avgAge desc

-- OBJECTIVE 6: Find the percent of luxury vehicles stolen vs standard vehicles stolen

select *
from stolen_vehicles sv
left join make_details md on sv.make_id = md.make_id

with table1 as (select vehicle_type, 
	   case when make_type = 'Luxury' then 1 else 0 end as luxury
from stolen_vehicles sv
left join make_details md on sv.make_id = md.make_id)

select vehicle_type, (cast(sum(luxury) as float) / cast(count(luxury) as float)) * 100 as percentage_luxury
from table1
group by vehicle_type
order by percentage_luxury desc 

-- OBJECTIVE 7 : create a table where the rows represent the top 10 vehicle types, the columns represent the top 7 vehicle colors and the values are the number of vehicles stolen
/* Silver	1272
White	934
Black	589
Blue	512
Red	390
Grey	378
Green	224*/

select *
from stolen_vehicles

select color, count(vehicle_id) as num_vehicles
from stolen_vehicles
group by color
order by num_vehicles desc

select top 10 vehicle_type, count(vehicle_id) as num_vehicles,
	SUM(case when color = 'Silver' then 1 else 0 end) as silver, 
	SUM(case when color = 'White' then 1 else 0 end) as white, 
	SUM(case when color = 'Black' then 1 else 0 end) as black, 
	SUM(case when color = 'Blue' then 1 else 0 end) as blue, 
	SUM(case when color = 'Red' then 1 else 0 end) as red, 
	SUM(case when color = 'Grey' then 1 else 0 end) as grey, 
	SUM(case when color = 'Green' then 1 else 0 end) as green, 
	SUM(case when color IN ('Gold', 'Brown', 'Yellow' , 'Orange', 'Purple' , 'Cream', 'Pink') then 1 else 0 end) as other
from stolen_vehicles
group by vehicle_type
order by num_vehicles desc

-- Objective 8 : Find the number of vehicles that were stolen in each region
select *
from locations

select region, count(vehicle_id) as num_vehicles_stolen
from stolen_vehicles sv
left join locations l 
	on sv.location_id = l.location_id
group by region
order by num_vehicles_stolen desc

-- Objective 9: Explore the correlation between the number of vehicles stolen, region and population density
select region, count(vehicle_id) as num_vehicles_stolen, population, density
from stolen_vehicles sv
left join locations l 
	on sv.location_id = l.location_id
group by region, population, density
order by num_vehicles_stolen desc

-- Objective 10: Find whether the types of vehicles stolen in the three most dense regions differ from the three least dense regions
select region, count(vehicle_id) as num_vehicles_stolen, population, density
from stolen_vehicles sv
left join locations l 
	on sv.location_id = l.location_id
group by region, population, density
order by density desc

Auckland	1638	1695200	343.09
Nelson	92	54500	129.15
Wellington	420	543500	67.52

Otago	139	246000	7.89
Gisborne	176	52100	6.21
Southland	26	102400	3.28

(select 'High Density' ,vehicle_type, count(vehicle_id) as total_vehicles_stolen
from stolen_vehicles sv
left join locations l 
	on sv.location_id = l.location_id
where region in ('Auckland', 'Nelson', 'Wellington')
group by sv.vehicle_type
order by total_vehicles_stolen desc
limit 5)

union

(select 'Low Density', vehicle_type, count(vehicle_id) as total_vehicles_stolen
from stolen_vehicles sv
left join locations l 
	on sv.location_id = l.location_id
where region in ('Otago', 'Gisborne', 'Southland')
group by sv.vehicle_type
order by total_vehicles_stolen desc
limit 5)
