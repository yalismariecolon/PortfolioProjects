
/*
Yalismarie Colon

COVID-19 Data Exploration

Skills Used: JOINS, CTE, TEMP TABLES, AGGREGATE FUNCTIONS, CONVERTING DATA TYPES

Data: The dataset is from https://ourworldindata.org/covid-deaths. The dataset includes data from January 2020 to November 2022. 

Goal: Explore 2020-2022 COVID-19 Data through data exploration questions. 
I decided to focus on the insights for the United States. However, I also explored data globally and regionally. 

*/

/* VIEWING THE DATASETS */

--Covid Deaths Data

Select *
From CovidDeaths$
Where continent is not null
order by 3,4


Select location, date, total_Cases, new_cases, total_deaths, population
From CovidDeaths$
Where continent is not null
order by 1,2

/* 
DATA EXPLORATION - COVID DEATHS DATA
*/

/* How many COVID-19 cases in the United States and how many deaths? What is the percentage death rate?*/
--Shows the likelihood of dying in the United States if you contract COVID-19

SELECT location,date,total_Cases,total_deaths,(total_deaths/total_cases) *100 AS DeathPercentage
FROM CovidDeaths$
WHERE location LIKE '%states%' 
ORDER BY 1,2

-- By April 30 2021, the United States COVID-19 cases totaled 32,346,971 with a 1.78% death rate
--32,346,971 people were already infected by COVID-19 since January 2020 in the United States
--By the end of April 2021 total death count was 576,232

/*What percentage of the population contracted COVID-19?*/
--Shows what percentage of the United States population was infected with COVID-19
SELECT location, date,population, total_Cases,(total_cases/population) *100 as PercentPopulationInfected
FROM CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2

-- 0.32% of the United States population contracted COVID-19 as of November 23, 2022

/* Which Countries have the highest infection rate?*/
-- Shows Countries with the highest infection rate compared to their population

SELECT location, population, MAX(total_Cases) as HighestInfectionCount, MAX((total_cases/population)) *100 as PercentPopulationInfected
FROM CovidDeaths$
--Where location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc

-- Andorra has the highest infection rate at 17.12% compared to their population.
-- The United States has an infection rate of 9.77%, was in 9th place.

*/ Which Country has the highest death count? */
--Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast (total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
--Where location like '%states%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount desc

--The United States had the highest total death count followed by Brazil.

------------------- LET'S BREAK THINGS DOWN BY CONTINENT---------------------

/* Which continent has the highest death count?*/
--Showing continents with Highest Death Count per population

SELECT continent, MAX(cast (total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
--Where location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--North America had the highest death count.


------------------ GLOBAL NUMBERS -------------------------------------------

/* What is the global death percentage?*/

SELECT SUM(New_Cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

--The global death percentage is 2.11%

/* What percentage of the population is vaccinated? */
--Shows percentage of population that has recieved at least one Covid vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Using Table Common Expression (CTE) to perform calculation on PARTITION BY in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--New_vaccinations tracks how many people are vaccinated that day for each country. 
--RollingPeopleVaccinated provides a rolling count of the vaccines administered. 

-- Using a Temp Table to further explore the data

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime, 
Population numeric,
New_Vaccination numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS  RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



/* Which continents have the highest vaccination count?*/

SELECT 
	Continent, MAX(New_vaccinations) as highest_vaccination_count
FROM percentpopulationvaccinated
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY highest_vaccination_count

--Asia had the highest vaccination count followed by North America. 