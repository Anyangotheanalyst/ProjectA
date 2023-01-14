
SELECT * 
FROM ProjectA..CovidDeaths
WHERE continent is null
ORDER BY 3,4

--SELECT * 
--FROM ProjectA..Covidvaccination
--ORDER BY 3,4

SELECT location,date,total_cases, new_cases, total_deaths, population 
FROM ProjectA..CovidDeaths
WHERE continent is null
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you get contract covid in your country
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS death_percentage
FROM ProjectA..CovidDeaths
WHERE location ='Germany' AND continent IS NOT null
ORDER BY 1,2

--Looking at total cases vs population
--Percentage of population with covid
SELECT location,date,population, total_cases,(total_cases/population)*100 AS covidpopulation
FROM ProjectA..CovidDeaths
--WHERE location ='Germany'
WHERE continent is null
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT location,population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS percentcovidpopulation
FROM ProjectA..CovidDeaths
--WHERE location ='Germany'
GROUP BY location,population
ORDER BY percentcovidpopulation DESC

--Showing countries with the highest death count per population
SELECT location,MAX(CAST(total_deaths AS INT))  AS highestdeathcount
FROM ProjectA..CovidDeaths
--WHERE location ='Germany'
WHERE continent is null
GROUP BY location
ORDER BY highestdeathcount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT
--Continent with highest death count

SELECT continent,MAX(CAST(total_deaths AS INT))  AS highestdeathcount
FROM ProjectA..CovidDeaths
--WHERE location ='Germany'
WHERE continent is NOT null
GROUP BY continent
ORDER BY highestdeathcount DESC

--GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_newcases, SUM(CAST(new_deaths AS INT)) AS total_newdeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Global_deathpercentage
FROM ProjectA..CovidDeaths
--WHERE location ='Germany' 
WHERE continent IS NOT null
--GROUP BY date
ORDER BY 1,2

--Looking for total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rollingpeople_vaccinated
FROM ProjectA..CovidDeaths dea
JOIN ProjectA..Covidvaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
ORDER BY 2,3

--USE CTE
With popvsvac( continent,location, date, population, new_vaccination,rollingpeople_vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rollingpeople_vaccinated
--(Rollingpeople_vaccinated/population)* 100
FROM ProjectA..CovidDeaths dea
JOIN ProjectA..Covidvaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER BY 2,3
)
SELECT *,(rollingpeople_vaccinated/population)*100 
FROM popvsvac

--Temp Table

DROP TABLE IF EXISTS #Percentpopulationvaccinated
CREATE TABLE #Percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rollingpeople_vaccinated numeric)
INSERT INTO #Percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rollingpeople_vaccinated
--(Rollingpeople_vaccinated/population)* 100
FROM ProjectA..CovidDeaths dea
JOIN ProjectA..Covidvaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER BY 2,3
SELECT *,(rollingpeople_vaccinated/population)*100
FROM #Percentpopulationvaccinated

--Creating views to store data for later
CREATE VIEW Percentpopulationvaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rollingpeople_vaccinated
--(Rollingpeople_vaccinated/population)* 100
FROM ProjectA..CovidDeaths dea
JOIN ProjectA..Covidvaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER BY 2,3

SELECT *
FROM Percentpopulationvaccinated