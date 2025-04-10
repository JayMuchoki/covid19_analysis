Create  database Covid19_Analysis;
use Covid19_Analysis;

select * from CovidDeaths$;

--- Chances of dying in percentage among the people tested (if an mount of people tested correspond to people dying shows 100% of dying of affected then what is the chances of dying if this amount died)
SELECT  
    continent,
    Location,
    Population,
    CAST(total_cases AS float) AS Total_cases,
    CAST(total_deaths AS float) AS Total_deaths,
    CASE 
        WHEN (CAST(total_cases AS float) = 0 OR total_cases IS NULL) OR (CAST(total_deaths AS float) = 0 OR total_deaths IS NULL) THEN '0%' 
        ELSE CONCAT(
            CAST(ROUND((CAST(total_deaths AS float)  / CAST(total_cases AS float) * 100.0), 2) AS VARCHAR),
            '%'
        )
    END AS Percentage_of_dying
FROM 
    CovidDeaths$;



--Display percentage of population that has Covid (if significantly Total population is 100% population then what of an amount of those tested with covid )

select continent,Location,Population,Total_cases, concat(cast(round((total_cases/population)*100,2) as varchar),'%') as Percentage_Of_affected_citizens from CovidDeaths$
order by  Percentage_Of_affected_citizens desc



--countries with high  total infection rates
select continent,location, max(total_cases) as Total_Infection_rates From CovidDeaths$
 where continent is not null
group by continent,location
order by Total_Infection_rates desc
;

--looking at countries with Hoghest infection rate compared to population

select continent,location ,  MAX(total_cases) as Highest_test_case,max(round((total_cases/population)*100,2)) as Highest_percentage_population_infected from CovidDeaths$
group by continent,location 
order by Highest_percentage_population_infected desc;


---the highest death count recorded

select Location,max(cast(total_deaths as int) ) as Total_Death_count 
from CovidDeaths$
where continent is  null
group by location
order by  Total_Death_count desc ;



--find the total recorded cases  and death of a certain date in the world

select date,sum(new_cases) as InfectedCases ,sum(cast(new_deaths as int)) as De athCases    from CovidDeaths$
where continent is not null
group by date
order by date 


--joining the tables and looking at total population vs vaccinations 

select * from CovidDeaths$ d
join CovidVaccinations$ v
on d.date=v.Date
and  d.location=v.location


---looking at total population vs vaccinations 


select d.continent,d.location,d.date,d.population,v.new_vaccinations  from CovidDeaths$ d
join CovidVaccinations$ v
on d.date=v.Date
and  d.location=v.location
where d.continent is not null
order by d.location ,d.date


select d.continent,d.location,d.date,d.population,d.new_deaths,v.new_vaccinations  from CovidDeaths$ d
join CovidVaccinations$ v
on d.date=v.Date
and  d.location=v.location
where d.continent is not null
order by d.location ,d.date



--Finding a rollup number it order to find the accumulating number of people vaccinated each day per country
-- note that we will have them partioned by the location then have the ordered by location and date   date will be the one showing diffrent case scenario of the recored vaccinations
select d.continent,d.location,d.date,d.population,d.new_deaths,v.new_vaccinations
,sum(cast(v.new_vaccinations as int) ) over(partition by d.Location order by d.location,d.date)as ToTal_countrys_vaccination  
from CovidDeaths$ d
join CovidVaccinations$ v
on d.date=v.Date
and  d.location=v.location
where d.continent is not null
order by d.location ,d.date


--using a CTE inorder to find the percentage of the people vaccinated 

with Covid19_data as (
select d.continent,d.location,d.date,d.population,d.new_deaths,v.new_vaccinations
,sum(cast(v.new_vaccinations as int) ) over(partition by d.Location order by d.location,d.date)as Total_countrys_vaccination  
from CovidDeaths$ d
join CovidVaccinations$ v
on d.date=v.Date
and  d.location=v.location
)


select continent ,location ,date ,population,new_vaccinations,Total_countrys_vaccination,
concat(cast(round((Total_countrys_vaccination/population)*100,2) as varchar) ,'%') from Covid19_data
where continent is not null
order by location ,date;

select * from CovidVaccinations$


select d.continent,d.location,d.date,d.population,d.new_deaths,v.new_vaccinations
,sum(cast(v.new_vaccinations as int) ) over(partition by d.Location order by d.location,d.date)as Total_countrys_vaccination  
 into #covid19 
from CovidDeaths$ d
join CovidVaccinations$ v
on d.date=v.Date
and  d.location=v.location


select * from #covid19