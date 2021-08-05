SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4


--SELECT Data that we are going to be using


SELECT Location, date, total_cases,new_cases,total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- TOTAL CASES VS TOTAL DEATHS


SELECT Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- This shows the likelihood of death in your country
-- The Death Percentage in the US trending down 1.7% and dropping


SELECT Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Mexico%'
ORDER BY 1,2

-- The Death Percentage in the Mexico is 8 times higher than the US
-- @ 8.4%


SELECT Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Canada%'
ORDER BY 1,2

-- The Death Percentage is almost the same as the US
-- @ 1.8%

--TOTAL CASES VS POP
-- Percentage of the pop that got Covid-19
-- USA
SELECT Location, date, total_cases,Population,(total_cases/Population)*100 AS Confirmed
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2


-- Ten percent of the population has been confirmed to have covid per data of test cases

SELECT Location,Population,MAX(total_cases) AS HighInfectCount,
MAX((total_cases/population))*100 AS PercentPopInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopInfected DESC

-- Countries with highest mortality rate per population

SELECT Location,MAX(cast(total_deaths AS int)) AS TDCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TDCount DESC

-- Most covid deaths are unfortunately in the US


-- Covid Deaths per Contintent
SELECT location,MAX(cast(total_deaths AS int)) AS TDCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TDCount DESC


SELECT continent,MAX(cast(total_deaths AS int)) AS TDCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TDCount DESC


--Global Numbers	
SELECT date,SUM(new_cases)as TCases, SUM(cast(new_deaths as int))as Tdeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DPercentage
FROM PortfolioProject..CovidDeaths 
--WHERE location like '%state%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


--Global Numbers	
SELECT SUM(new_cases)as TCases, SUM(cast(new_deaths as int))as Tdeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DPercentage
FROM PortfolioProject..CovidDeaths 
--WHERE location like '%state%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(CONVERT(INT,vax.new_vaccinations ))
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPPlVax
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVax vax
	ON dea.location = vax.location
	AND dea.date =vax.date
WHERE dea.continent is not null AND dea.continent LIKE '%Europe%'
ORDER BY 1,2,3

-- USE CTE

WITH PopvsVax(continent,location, date,population,new_vaccinations,RollingPPlVax)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(CONVERT(INT,vax.new_vaccinations ))
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPPlVax
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVax vax
	ON dea.location = vax.location
	AND dea.date =vax.date
WHERE dea.continent is not null AND dea.continent LIKE '%Europe%'
--ORDER BY 2,3
)
SELECT *,(RollingPPlVax/population)*100 
FROM PopvsVax

-- TEMP TABLE
DROP TABLE if exists #PercentPopVaxxed
CREATE TABLE #PercentPopVaxxed
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vax numeric,
rollingPeopleVaxxed numeric
)

INSERT INTO #PercentPopVaxxed
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(CONVERT(INT,vax.new_vaccinations ))
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPPlVax
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVax vax
	ON dea.location = vax.location
	AND dea.date =vax.date
WHERE dea.continent is not null AND dea.continent LIKE '%Europe%'
--ORDER BY 2,3

--Test Table works
SELECT *,(rollingPeopleVaxxed/population)*100 
FROM #PercentPopVaxxed


--CREATE A VIEW TO STORE DATA FOR LATER VISUALIZATIONS
CREATE VIEW PercentPopVaxxed as
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(CONVERT(INT,vax.new_vaccinations ))
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPPlVax
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVax vax
	ON dea.location = vax.location
	AND dea.date =vax.date
WHERE dea.continent is not null AND dea.continent LIKE '%Europe%'
--ORDER BY 2,3


