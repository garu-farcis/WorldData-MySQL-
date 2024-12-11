


USE WORLD;
/*Using count, get the number of cities in the USA*/
SELECT NAME FROM WORLD.CITY WHERE (SELECT NAME FROM WORLD.COUNTRY WHERE CODE='USA');
SELECT * FROM WORLD.COUNTRY;
SELECT * FROM WORLD.CITY;
SELECT COUNT(C.NAME) FROM WORLD.CITY C LEFT JOIN WORLD.COUNTRY CO ON C.COUNTRYCODE = CO.CODE WHERE C.COUNTRYCODE='USA'; 
/*Find out what the population and average life expectancy for people in Argentina (ARG) is*/
SELECT POPULATION, LIFEEXPECTANCY FROM WORLD.COUNTRY WHERE CODE='ARG';
/* Using IS NOT NULL, ORDER BY, LIMIT, what country has the highest life expectancy? */
SELECT LIFEEXPECTANCY,CODE,NAME FROM WORLD.COUNTRY WHERE CODE IS NOT NULL ORDER BY LIFEEXPECTANCY DESC LIMIT 100; 
/*Using LEFT JOIN, ON, what is the capital of Spain (ESP)?*/
SELECT C.NAME,CO.NAME FROM WORLD.CITY C LEFT JOIN WORLD.COUNTRY CO ON C.ID= CO.CAPITAL WHERE CO.CODE='ESP';
/*Using LEFT JOIN, ON, list all the languages spoken in the 'Southeast Asia' region*/
SELECT * FROM WORLD.COUNTRYLANGUAGE;
SELECT CL.LANGUAGE, CO.NAME FROM WORLD.COUNTRYLANGUAGE CL LEFT JOIN WORLD.COUNTRY CO ON CL.COUNTRYCODE = CO.CODE WHERE CO.CODE IS NOT NULL AND CO.REGION ='Southeast Asia';
/* DATA WRANGLING */
-- find missing value and null--
select count(*) from world.country where gnp = 0; 
select count(*) from world.country where gnpold is null;
/* Data Exploration*/
-- ranking countries by GNP and GNPOLD--
select rank() over (order by gnp desc) as gnp_rank, rank() over (order by gnpold desc) as gnp_old_rank, name, gnp, gnpold, lifeexpectancy from world.country order by gnp_rank;
-- oldest life expectancy in the world for a country--
select * from world.country;
select name, region, lifeexpectancy from world.country order by lifeexpectancy desc;
-- oldest life expectancy in the world for a city--
select * from world.country;
select * from world.countrylanguage;
 -- find top life expectancy countries by continents, ranking by world's life expectancy--
create view v_continent_rank as 
		select code, name, continent, region,  
			lifeexpectancy, rank() over (partition by continent order by lifeexpectancy desc) as life_con_rank, rank() over (order by lifeexpectancy desc) as life_rank, min(lifeexpectancy) over (partition by continent) as lowest_con_life,
			gnp, rank() over (partition by continent order by gnp desc) as gnp_con_rank, rank() over (order by gnp desc) as gnp_rank
		from world.country 
		order by continent, lifeexpectancy;

select * from v_continent_rank where lifeexpectancy is not null and life_con_rank =1 order by lifeexpectancy desc; 
 create view v_continent_rank as 
		select code, name, continent, region,  
			lifeexpectancy, rank() over (partition by continent order by lifeexpectancy desc) as life_con_rank, rank() over (order by lifeexpectancy desc) as life_rank, min(lifeexpectancy) over (partition by continent) as lowest_con_life,
			gnp, rank() over (partition by continent order by gnp desc) as gnp_con_rank, rank() over (order by gnp desc) as gnp_rank
		from country 
		order by continent, lifeexpectancy;

select * from v_continent_rank where lifeexpectancy is not null and life_con_rank =1 order by lifeexpectancy desc;
/* Finding:
The top life expectancy per continent: 
	1/ Andorra(Europe), 
    2/ Macao(Asia), 
    3/ Australia(Oceania), 
    4/ Canada(North America), 
    5/ Saint Helena(Africa), 
    6/ and French Guiana(South America). */

-- find top GNP countries by continents, ranking by world's GNP
select * from v_continent_rank where gnp >0 and gnp_con_rank =1 order by gnp desc;
/* 	Finding:
The top GNP countries per continent: 
	1/ USA(North America), 
    2/ Japan(Asia), 
    3/ Germany(Europe), 
    4/ Brazil(South America), 
    5/ Australia(Oceania), 
    6/ and South Africa(Africa).
What's special, Austalia has both high life expectancy and GNP. */

-- find top life expectancy countries limited by life expectancy over 80
select * from v_continent_rank where lifeexpectancy >80 order by lifeexpectancy desc;
/* 	Finding:
- Countries with high life expectancy above 80 years old were 1/Andorra, 2/Macao, 3/San Marino, 4/Japan, and 5/Singapore.
- Although the United State, Germany, France, and United Kingdom were ranked among top 5 GNP growth, they didn't have high life expectacy above 80. */ 

-- Lowest life expectancy countries below 45
select * from v_continent_rank where lifeexpectancy <=45 order by lifeexpectancy desc;
/* 	Finding:
There were 12 countries having lowest life expectancy below 45 which all locate in Africa continent. */

-- is there any high life expectancy amoung African countries?
select * from v_continent_rank where continent = 'africa' and lifeexpectancy >70 order by lifeexpectancy desc;
/*	Finding:
- There were 6 African countries with life expectancy above 70: Saint Helena, Libyan Arab Jamahiriya, Tunisia, Réunion, Mauritius, and Seychelles. 
- Saint Helena got the highest life expectancy with 76.8 compared to all African countries. */

-- find top 5 GNP countries in Africa
select * from v_continent_rank where continent = 'africa' order by gnp desc limit 5;
/*	Finding:
- Top 5 GNP countries in African were South Africa, Egypt, Nigeria, Algeria, and Libyan Arab Jamahiriya.
- Libyan Arab Jamahiriya was the most outstanding country in Africa for long life expectancy and high GNP growth. */

-- find lowest life expectancy by continents
select code, name, continent, region,  
	lifeexpectancy, rank() over (partition by continent order by lifeexpectancy desc) as life_con_rank, rank() over (order by lifeexpectancy desc) as life_rank, min(lifeexpectancy) over (partition by continent) as lowest_con_life,
	gnp, rank() over (partition by continent order by gnp desc) as gnp_con_rank, rank() over (order by gnp desc) as gnp_rank
from country
where lifeexpectancy is not null and gnp >0 
order by continent, lifeexpectancy;
/*	FindingL
Lowest life expectancy country by continents: 
	1/ Afghanistan(Asia)=45.9, 
	2/ Moldova(Europe)=64.5, 
    3/ Haiti(North American)=49.2, 
    4/ Zambia(Africa)=37.2, 
    5/ Kiribati(Oceania)=59.8, 
    6/ Brazil(South America)=62.9
*/

/* Reference */
-- search box by country name
delimiter $$
drop procedure if exists countrysearch;
create procedure countrysearch (in countryname varchar(200))
	begin
		select co.*, ci.*, cl.* from country as co
        inner join city as ci
        on co.code = ci.countrycode 
        inner join countrylanguage as cl
        on ci.countrycode = cl.countrycode
        where co.name = countryname;
	end $$
delimiter ;
call countrysearch ('United States');

-- show tables
select * from world.city;
select * from world.country;
select * from world.countrylanguage;
select co.*, ci.*, cl.* from world.country as co inner join world.city as ci on co.code = ci.countrycode inner join world.countrylanguage as cl on ci.countrycode = cl.countrycode where co.name = countryname;
 
 
 
 
 
 
 
 
 
 
 
 
