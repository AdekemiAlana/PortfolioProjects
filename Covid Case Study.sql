4Select *
From PortfolioProject.dbo.CovidDeaths
where continent is not null
Order by 3,4

Select *
From PortfolioProject.dbo.CovidVaccinations
Order by 3,4


--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
where location like '%canada%'
order by 1,2



--Looking at the total cases vs Population
-- Shows what percentage of population got covid

Select location, date, Population, total_cases,
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulationInfected
from PortfolioProject..covidDeaths
--where location like '%canada%'
order by 1,2


-- Looking at countries with Highest infection rates compared to population
Select location, Population, MAX(total_cases) as HighestInfectionCount,
MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentPopulationInfected
from PortfolioProject..covidDeaths
--where location like '%canada%'
Group by location, population
order by PercentPopulationInfected desc



-- Showing Countries with the Highest Death Count by Location

Select location, MAX(cast(total_deaths as int)) as TotaldeathCount
--MAX((CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentPopulationdeaths
from PortfolioProject..covidDeaths
--where location like '%canada%'
where continent is not null
Group by location
order by TotalDeathCount desc



--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing the continent with the Highest Death Count


Select continent, MAX(cast(total_deaths as int)) as TotaldeathCount
--MAX((CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentPopulationdeaths
from PortfolioProject..covidDeaths
--where location like '%canada%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--Select location, MAX(cast(total_deaths as int)) as TotaldeathCount
--MAX((CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentPopulationdeaths
--from PortfolioProject..covidDeaths
--where location like '%canada%'
--where continent is null
--Group by location
--order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--SUM((CONVERT(float, new_deaths))) / SUM((CONVERT(float, new_cases)) * 100 as Deathpercentage
from PortfolioProject.dbo.CovidDeaths
--where location like '%canada%'
where new_cases <> 0 and continent is not null
Group by date
order by 1,2


Select  SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--SUM((CONVERT(float, new_deaths))) / SUM((CONVERT(float, new_cases)) * 100 as Deathpercentage
from PortfolioProject.dbo.CovidDeaths
--where location like '%canada%'
where  continent is not null
order by 1,2



-- Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations  vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3



Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeoplevaccinated
--, (RollingPeoplevaccinated/population)*100 .................Newly created table cannot be used for operators
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations  vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

with PopvsVac (continent, location, Date, Population, new_vaccinations, RollingPeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeoplevaccinated
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations  vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
From PopvsVac



-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeoplevaccinated
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations  vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeoplevaccinated/Population)*100
From #PercentPopulationVaccinated





-- Creating View to store data for later visualization
Drop view if exists PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeoplevaccinated
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations  vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select*
From PercentPopulationVaccinated