
--selecting usable data fromm the set
select*
from dbo.CovidDeaths 
where continent is not null and location= 'Asia'
order by location


--total cases vs total deaths

Select top 100
location, date, total_cases, nullif(total_deaths,0) total_deaths,(convert(float,total_deaths)/ nullif(convert(float,total_cases),0))*100 percentage_deaths
from dbo.CovidDeaths
where location like '%states%'
order by 3 desc



--Looking at total cases vs population
Select 
location, date, total_cases ,population ,(convert(float,total_cases)/ nullif(convert(float,population),0))*100 percentage_cases
from dbo.CovidDeaths
where location like '%states%'
order by 1,2

--looking at countries at high infection rates compared to population

Select location, population, max(total_cases) highestInfectionCount  ,Max((convert(float,total_cases))/ nullif(convert(float,population),0))*100 percentageInfected
from dbo.CovidDeaths
--where location like '%states%'
where continent is not null
group by location, population
order by 4 desc

-- countries with the highest death count per population
Select location, max(cast(total_deaths as int)) highestDeathCount  
from dbo.CovidDeaths
where nullif(continent,'') is not null
group by location
order by 2 desc

--focusing on continent

-- Continent with the highest death count per population
Select continent, sum(cast(total_deaths as int)) highestDeathCount  
from dbo.CovidDeaths
where nullif(continent,'') is not null
group by continent
order by 2 desc

--Global Numbers
Select 
date, sum(cast(new_deaths as float)) new_deaths, sum(cast(new_cases as float)) new_cases,(sum(cast(new_deaths as float))/ nullif(sum(cast(new_cases as float)),0))*100 percentage_New_deaths
from dbo.CovidDeaths
where  continent is not null
group by date
order by 4 desc


--total population vs vaccinated

select nullif(d.continent,'') Continent, d.location,d.date, d.population, nullif(v.new_vaccinations,'') new_vaccination from 
dbo.CovidDeaths d join 
dbo.CovidVaccinations v 
on d.location=v.location and d.date=v.date
where nullif(d.continent,'') is not  null
order by 1,2,3

--rolling summ of vaccinnations

select nullif(d.continent,'') Continent, d.location,d.date, d.population, nullif(v.new_vaccinations,'') new_vaccination,
sum(cast(v.new_vaccinations as int)) over(partition by d.location order by d.location, d.date) as rolligPeopleVaccinated
from 
dbo.CovidDeaths d join 
dbo.CovidVaccinations v 
on d.location=v.location and d.date=v.date
where nullif(d.continent,'') is not  null
order by 1,2,3

--using CTE to calculate  rolling percentage of people newly vaccinated 

with popvsvac(Continent, Location, Date, Population, New_vaccination, RollingPeopleVaccinated)
as
(
select nullif(d.continent,'') Continent, d.location,d.date, d.population, nullif(v.new_vaccinations,'') new_vaccination,
sum(cast(v.new_vaccinations as int)) over(partition by d.location order by d.location, d.date) as rolligPeopleVaccinated
from 
dbo.CovidDeaths d join 
dbo.CovidVaccinations v 
on d.location=v.location and d.date=v.date
where nullif(d.continent,'') is not  null
--order by 1,2,3
)
select *, ((RollingPeopleVaccinated)/nullif(cast(Population as float),0))*100 as RollingPercentageVaccinated
from popvsvac
order by 1,2

-- temp table-------------------------------------------------------------------------------------------------------------------------------
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select nullif(d.continent,'') Continent, d.location,d.date, cast(d.population as int), nullif(v.new_vaccinations,'') new_vaccination,
sum(cast(v.new_vaccinations as int)) over(partition by d.location order by d.location, d.date) as rolligPeopleVaccinated
from 
dbo.CovidDeaths d join 
dbo.CovidVaccinations v 
on d.location=v.location and d.date=v.date
where nullif(d.continent,'') is not  null
--order by 1,2,3  

select *, ((RollingPeopleVaccinated)/nullif(cast(Population as float),0))*100 as RollingPercentageVaccinated
from #PercentPopulationVaccinated
order by 1,2

-- creating view to store data for later visualization
Create view PercentPopulationVaccinated as
select nullif(d.continent,'') Continent, d.location,d.date,d.population, nullif(v.new_vaccinations,'') new_vaccination,
sum(cast(v.new_vaccinations as int)) over(partition by d.location order by d.location, d.date) as rolligPeopleVaccinated
from 
dbo.CovidDeaths d join 
dbo.CovidVaccinations v 
on d.location=v.location and d.date=v.date
where nullif(d.continent,'') is not  null
--order by 1,2,3  

select * from PercentPopulationVaccinated