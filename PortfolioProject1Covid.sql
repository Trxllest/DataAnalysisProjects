SELECT * 
FROM CovidDeaths
Where continent is not NULL
order by 3,4

-- SELECT * 
-- FROM CovidVaccinations
-- order by 3,4

-- Select Data that we are going to be using 

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract Covid in Canada
SELECT location,date,total_cases,total_deaths, ((total_deaths / total_cases)*100) as deathpercentage
FROM CovidDeaths
WHERE location like '%anada%'
order by 1,2

-- Look at total cases vs population
-- Shows what percentage of population got Covid
SELECT location,date,population,total_cases, ((total_cases/population)*100) as CasePercentage
FROM CovidDeaths
-- WHERE location like '%anada%'
order by 1,2

-- Countries with highest infection rate compared to population
SELECT location,population,MAX(total_cases) as HighestInfectionCount , MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
-- WHERE location like '%anada%'
GROUP BY location,population
order by PercentPopulationInfected DESC


-- Showing with countries with highest death count per population
SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
-- WHERE location like '%anada%'
Where continent is not NULL
group by location 
order by TotalDeathCount DESC

-- Break it down by continent


-- Showing continents with highest death count
SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
-- WHERE location like '%anada%'
Where continent is not NULL
group by continent 
order by TotalDeathCount DESC

-- Global Numbers

SELECT sum(new_cases) as total_cases,sum(new_deaths) as total_deaths,sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null 
--Group by date 
order by 1,2

-- Looking at total population vaccination

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(vac.new_vaccinations) OVER (PARTITION by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not NULL
order by 2,3

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, cast(dea.Date as datetime)) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
GO
-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

SELECT *
FROM PercentPopulationVaccinated
