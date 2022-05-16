USE covid_portfolio
SELECT * FROM covid_portfolio..CovidDeaths

SELECT * FROM covid_portfolio..CovidVaccination
order by 3,4

-- Select Data that I am going to use
Select location, date, total_cases, new_cases, total_deaths, population
from covid_portfolio..CovidDeaths
order by date

-- Looking at total cases vs total deaths
Select location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as DeathPercentage
from covid_portfolio..CovidDeaths
where location like 'Madagascar'
order by date

-- Looking at countries with highest infection rate compared to population
Select location, max(total_cases) as HighestInfection, population, MAX((total_cases/population))*100 as Ratio
from covid_portfolio..CovidDeaths
GROUP BY location, population
order by ratio desc

-- Showing continent with the highest death count
SELECT CONTINENT, MAX(cast(total_deaths as int)) as death_count
from covid_portfolio..CovidDeaths
where continent is not null
GROUP BY continent
order by death_count

-- Global Numbers of Total Deaths sorted by Date
SELECT date, SUM(CAST(total_deaths AS INT))
from covid_portfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER By date

-- Show Vaccination Percentage in comparison to population

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Aggregate)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.location order by dea.date, dea.location) as Aggregate
FROM covid_portfolio..CovidDeaths dea
JOIN covid_portfolio..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null)
Select*, (Aggregate/Population)*100 as vaccination_percentage From PopvsVac

-- Create View to store data for visualization
CREATE VIEW PercentagePopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.location order by dea.date, dea.location) as Aggregate
FROM covid_portfolio..CovidDeaths dea
JOIN covid_portfolio..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

