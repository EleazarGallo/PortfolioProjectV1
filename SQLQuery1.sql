---owid-covid-data (2)$ = Coviddeaths P2
select *
from [Rooster project]..['owid-covid-data (2)$']


---'owid-covid-data (3)$' = COVIDvacc
select *
from [Rooster project]..['owid-covid-data (3)$']

select *
from [Rooster project]..['owid-covid-data (3)$']
order by 3,4

select *
from [Rooster project]..['owid-covid-data (2)$']
order by 3,4

-- Select data that we are going to be using

select location, date, total_cases, new_cases,total_deaths , population
from [Rooster project]..['owid-covid-data (2)$']
order by 1, 2
--order by location and date

--looking at Total cases vs Total Deaths
--shows death expectency if you contract covid in your country
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Rooster project]..['owid-covid-data (2)$']
order by 1, 2

--location by country
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Rooster project]..['owid-covid-data (2)$']
where location like  '%United States%'
order by 1, 2

--looking at Total Cases vs Population
--this will show what Percentage of population got covid
---336997624
select location, date, total_cases,Population, (total_cases/Population)*100 as PercentagePopulationInfection
from [Rooster project]..['owid-covid-data (2)$']
where location like  '%United States%'
order by 1, 2

--looking at countires with highest Infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectioncount, (max(total_cases)/Population)*100 as PercentagePopulationInfection
from [Rooster project]..['owid-covid-data (2)$']
--where location like  '%United States%'
group by Location, Population
Order by PercentagePopulationInfection

---looking at countires with highest Infection rate compared to population in descending order

select location, Population, Max(total_cases)as HighestInfectioncount, (Max(total_cases/Population))*100 as PercentagePopulationInfection
from [Rooster project]..['owid-covid-data (2)$']
--where location like  '%United States%'
group by Location, Population
Order by PercentagePopulationInfection desc

--will show the countries with highest death count per population
-- cast helps with converting a value into numerical value (integer)

select location, Max(cast(total_deaths as int))as total_deaths_count
from [Rooster project]..['owid-covid-data (2)$']
--where location like  '%United States%'
group by Location
Order by total_deaths_count desc

---ex. will help with removing null continent vlaues

select *
from [Rooster project]..['owid-covid-data (2)$']
where continent is not null
order by 3,4

--added is not null US is now the highest death count 

select location, Max(cast(total_deaths as int))as total_deaths_count
from [Rooster project]..['owid-covid-data (2)$']
--where location like  '%United States%'
where continent is not null
group by Location
Order by totaldeathscount desc

--- Removed Population and replaced it by Continent 
select continent, Max(cast(total_deaths as int))as total_deaths_count
from [Rooster project]..['owid-covid-data (2)$']
--where location like  '%United States%'
where continent is not null
group by continent
Order by totaldeathscount desc

--show contintents with highest death count per popluation
select continent, Max(cast(total_deaths as int))as total_deaths_count
from [Rooster project]..['owid-covid-data (2)$']
--where location like  '%United States%'
where continent is not null
group by continent
Order by totaldeathscount desc


-- world wide numbers
--this is by day 
select date, SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/Sum(new_cases)* 100 as death_percentage
from [Rooster project]..['owid-covid-data (2)$']
--where location like  '%United States%'
where continent is not null
group by date
order by 1, 2

--world wide numbers
--this is total 
select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/Sum(new_cases)* 100 as death_percentage
from [Rooster project]..['owid-covid-data (2)$']
--where location like  '%United States%'
where continent is not null
order by 1, 2

--Joining Coviddeaths P2 and COVIDvacc excell docs
--total population vs vaccinations
select *
from [Rooster project]..['owid-covid-data (2)$'] dea
Join [Rooster project]..['owid-covid-data (3)$'] vacx
on dea.location = vacx.Location
and dea.date = vacx.date

--Total popluation vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vacx.new_vaccinations
from[Rooster project]..['owid-covid-data (2)$'] dea
Join [Rooster project]..['owid-covid-data (3)$'] vacx
on dea.location = vacx.Location
and dea.date = vacx.date
where dea. continent is not null 
order by  2,3 

-- create an additonal calumn that add new vactinations
--bigger range use Bigint
select dea.continent, dea.location, dea.date, dea.population, vacx.new_vaccinations, sum(cast(vacx.new_vaccinations as bigint)) over (partition by dea.location Order by dea.location, dea.date) as Total_vacinated
from[Rooster project]..['owid-covid-data (2)$'] dea
Join [Rooster project]..['owid-covid-data (3)$'] vacx
on dea.location = vacx.Location
and dea.date = vacx.date
where dea.continent is not null 
order by  2,3 

--use CTE 
With PopvsVacx (continent, location, date, population, new_vaccinations, Total_vacinated) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vacx.new_vaccinations, sum(cast(vacx.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as Total_vacinated
from[Rooster project]..['owid-covid-data (2)$'] dea
Join [Rooster project]..['owid-covid-data (3)$'] vacx
on dea.location = vacx.Location
and dea.date = vacx.date
where dea.continent is not null 
)
select *, (Total_vacinated/population)*100
from PopvsVacx

--Table
drop table if exists #PercentpopulationVaccinated
Create table #PercentpopulationVaccinated
(
Continent Nvarchar(255),
Location Nvarchar(255),
date datetime,
population numeric,
new_VACCINATIONS Numeric,
Total_vacinated numeric
)

Insert into #PercentpopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vacx.new_vaccinations, sum(cast(vacx.new_vaccinations as bigint)) over (partition by dea.location Order by dea.location, dea.date) as Total_vacinated
from[Rooster project]..['owid-covid-data (2)$'] dea
Join [Rooster project]..['owid-covid-data (3)$'] vacx
on dea.location = vacx.Location
and dea.date = vacx.date
where dea.continent is not null 

select *, (Total_vacinated/population)*100
from #PercentpopulationVaccinated


--crete a view for storage later for a visualization
Create View PercentPopulationVaccinatedV1 as
select dea.continent, dea.location, dea.date, dea.population, vacx.new_vaccinations, sum(cast(vacx.new_vaccinations as bigint)) over (partition by dea.location Order by dea.location, dea.date) as Total_vacinated
from[Rooster project]..['owid-covid-data (2)$'] dea
Join [Rooster project]..['owid-covid-data (3)$'] vacx
on dea.location = vacx.Location
and dea.date = vacx.date
where dea.continent is not null 

select *
from PercentPopulationVaccinatedV1