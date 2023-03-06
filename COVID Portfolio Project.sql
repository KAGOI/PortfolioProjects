--select *
--from [dbo].[CovidDeaths]
--Order by 3,4

--select *
--from [dbo]. CovidVaccinations
--Order by 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
-- Shows what percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentage
FROM CovidDeaths
--WHERE location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate Compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 as PopulationPercentage
FROM CovidDeaths
--WHERE location like '%states%'
Group by location, population
order by PopulationPercentage desc


--LET'S BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Showing the Countries with the Highest Death count per Population
SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc


-- SHOWING THE CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION 
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS 
SELECT date, SUM(new_cases) as TotalNewCases, SUM(CAST(new_deaths as int)) as TotalNewDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from CovidDeaths
Where continent is not null
Group by date
Order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3



-- USE CTE

WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac





--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3



Select *
From PercentPopulationVaccinated