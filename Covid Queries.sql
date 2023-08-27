/*

Queries used for Tableau Project

*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Covid Project]..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From [Covid Project]..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [Covid Project]..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Covid Project]..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Covid Project]..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc

select *
from [Covid Project]..CovidDeaths
order by 3,4;

--select * 
--from [Covid Project]..CovidVaccinations
--order by 3,4

--Select data that I'm going to use

Select location, date, total_cases,new_cases, total_deaths, population
from [Covid Project]..CovidDeaths
where continent is not NULL
order by 1,2;

--Total Deaths vs Totl Cases Percentage
--Shows likelihood of fatality if Covid is contracted in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Covid Project]..CovidDeaths
where  continent is not NULL
--where location like '%states%'
order by 1,2;

--Total Cases vs Population
--Shows percentage of Population that has Gotten Covid
select location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
from [Covid Project]..CovidDeaths
--where location like '%states%'
order by 1,2;

--Countries with highest infection rate compared to their population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as 
PercentPopulationInfected
from [Covid Project]..CovidDeaths
--where location like '%states%'
where  continent is not NULL
Group by location, population
order by PercentPopulationInfected desc;

--Countries with the highest amount of moortalities

select location, MAX(cast(total_deaths as int)) as MortalityCount
from [Covid Project]..CovidDeaths
--where location like '%states%'
where  continent is not NULL
Group by location
order by MortalityCount desc;

--Continent total mortalities  

select location, MAX(cast(total_deaths as int)) as MortalityCount
from [Covid Project]..CovidDeaths
where  continent is NULL
Group by location
order by MortalityCount desc;

--Global Numbers Section
--Removing the date keyword will tell you the total death percentage across the world
Select date, SUM(new_cases) as CasesGlobal, SUM(cast(new_deaths as int)) as DeathsGlobal,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
from [Covid Project]..CovidDeaths
where  continent is not NULL
GROUP by date
order by 1,2;


--total population vs vaccinations using CTE 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Covid Project]..CovidDeaths as dea
JOIN [Covid Project]..CovidVaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not NULL
--order by 2,3 
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--Creating View to use in Power BI for visualizations

Create View RollingPeopleVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Covid Project]..CovidDeaths as dea
JOIN [Covid Project]..CovidVaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not NULL;

