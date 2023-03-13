select * from PortfolioProjects..CovidDeaths

select * from PortfolioProjects..CovidVaccinations

--select  Data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths,population
from PortfolioProjects..CovidDeaths
 where continent is null
order by 1,2

--Looking at Total Cases vs Total Deaths
-- Shows the likely hood of dying if you contract covid19

select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths 
-- where location like '%Afri%' and
where continent is null
order by 1,2


--Looking for Total Cases vs Population
-- Shows what percentage of population infected with covid
select Location, date, total_cases,population, (total_cases/population)*100 as InfectedPopulationpercentage
from PortfolioProjects..CovidDeaths 
where continent like '%Afri%'and
 location is null
order by 1,2

-- Looking at countries with Highest infection rate compared to population 
select Location ,population, Max(total_cases) as HighestInfection, max((total_cases/population))*100 as InfectedPopulationpercentage 
from PortfolioProjects..CovidDeaths 
 -- where location like '%Afri%' and
 where continent is null
 Group by Location ,population
order by InfectedPopulationpercentage desc

-- Countries with Highest Death count per population

select Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
from PortfolioProjects..CovidDeaths 
 -- where location like '%Afri%'
 where continent is null
 Group by Location
order by TotalDeathCount desc

-- SHOWING CONTINETS WITH HIGHEST BREAKDOWN

select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
from PortfolioProjects..CovidDeaths 
 -- where location like '%Afri%'
 where continent is not null
 Group by continent
order by TotalDeathCount desc

--Global numbers

select date, SUM(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths 
-- where location like '%Afri%' and
where continent is not null
Group by date
order by 1,2

-- TOtal cases for the whole continent
select SUM(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths 
-- where location like '%Afri%' and
where continent is not null
-- Group by date
order by 1,2

--Joining two tables coviddeath and covidvaccination as well as looking at total_population vs vaccination

select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) As TotalNopeoplevaccinated 
-- (TotalNopeoplevaccinated/population)*100 
 from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
on dea.location = vac.location and 
dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TotalNopeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) As TotalNopeopleVaccinated 
-- (TotalNopeoplevaccinated/population)*100 
 from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
on dea.location = vac.location and 
dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select *,(TotalNopeoplevaccinated/population)*100 from PopvsVac

--TEMP TABLE
-- you can use the drop table code if you made a mistake and you want to redo the whole sql code
Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
TotalNopeoplevaccinated numeric
)
 
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) As TotalNopeopleVaccinated 
-- (TotalNopeoplevaccinated/population)*100 
 from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
on dea.location = vac.location and 
dea.date = vac.date
-- where dea.continent is not null

select *,(TotalNopeoplevaccinated/population)*100 from #PercentPopulationVaccinated

--Creating Views

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) As TotalNopeoplevaccinated 
-- (TotalNopeoplevaccinated/population)*100 
 from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
on dea.location = vac.location and 
dea.date = vac.date
where dea.continent is not null
-- order by 2,3

Create view wholecontinent as
select SUM(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths 
-- where location like '%Afri%' and
where continent is not null
-- Group by date
-- order by 1,2

