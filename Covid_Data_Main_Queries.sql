Use [Project1-Covid];


--Explore 'CovidDeaths' table
Select *
from [Project1-Covid]..CovidDeaths
order by 3,4;

--Select Data in CovidDeaths
Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2;

 --Total Cases VS Total Deaths OR % of people who died in the cases(Globally or whole data set)
 SELECT	location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PercentDeaths
 FROM CovidDeaths
 ORDER BY 1,2;

 --Percent of population who contracted Covid in the United States
 SELECT	location, date, total_cases, total_deaths, (total_cases/population)*100 AS PercentCcontracted
 FROM CovidDeaths
 WHERE location = 'United States'
 ORDER BY 1,2;

 --Date where highest percent contracted in U.S
SELECT date, (total_cases/population)*100 AS HighestPercentContracted
FROM CovidDeaths
WHERE location = 'United States' AND 
      ((total_cases/population)*100) = (SELECT MAX((total_cases/population)*100) 
                                       FROM CovidDeaths
                                       WHERE location = 'United States');

;

--Countries where Highest Infection Rate compared to the Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS HighestPercentContracted
FROM CovidDeaths
GROUP BY population, location
ORDER BY HighestPercentContracted DESC;

-- Countries with Highest Death Count per Population
SELECT location, (MAX(CAST(total_deaths AS int)) / MAX(population))*100 AS DeathPercentagePerPopulation
FROM CovidDeaths
WHERE continent IS NOT NULL --This is to make sure that only countries show and not the World locations
GROUP BY location
HAVING MAX(CAST(total_deaths AS int)) / MAX(population) IS NOT NULL
ORDER BY DeathPercentagePerPopulation DESC;

--Countries Max Total Deaths 
SELECT location , MAX(CAST(total_deaths AS int)) AS MaxTotalDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL
Group by location
HAVING MAX(CAST(total_deaths AS int)) IS NOT NULL
Order by MaxTotalDeaths DESC;

--Let check out Continents 
SELECT location , MAX(CAST(total_deaths AS int)) AS MaxTotalDeaths
FROM CovidDeaths
WHERE continent IS NULL
Group by location
Order by MaxTotalDeaths DESC;

--Determine Total Timeline from the CovidDeath table
SELECT 
    DATEDIFF(YEAR, MIN(date), MAX(date)) AS Years,
    DATEDIFF(MONTH, MIN(date), MAX(date)) % 12 AS Months,
    DATEDIFF(DAY, MIN(date), MAX(date)) % 30 AS Days
FROM CovidDeaths; ---Around 1 Year and 3 Months worth of RawData

---GLOBAL NUMBERS(Daily)
SELECT date, SUM(new_cases) AS Total_Cases , SUM(CAST(new_deaths AS int)) AS Daily_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage_Per_Day
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

---GLOBAL NUMBERS(Total)
SELECT SUM(new_cases) AS Total_Cases , SUM(CAST(new_deaths AS int)) AS Total_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;

----LOOKING AT CovidVaccinations Table Now----------------------

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations 
FROM CovidDeaths CD
JOIN CovidVaccinations CV ON CD.location = CV.location AND CV.date=CD.date
WHERE CD.continent IS NOT NULL
ORDER BY 2,3;

--Total Population VS Vaccinations as a CTE Table
WITH PopVSVac(continent, location, date, population, new_vaccinations, Rolling_Count_Vaccinated_Total)
AS (
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, SUM(CONVERT(int, CV.new_vaccinations)) OVER(PARTITION BY CD.location ORDER BY CD.location, CD.date) AS Rolling_Count_Vaccinated_Total
FROM CovidDeaths CD
JOIN CovidVaccinations CV ON CD.date=CV.date AND CD.location = CV.location
WHERE CD.continent IS NOT NULL
--ORDER BY 2,3;
)
--Percent of Population Vaccinated at each date
SELECT *, (Rolling_Count_Vaccinated_Total/population)*100 AS Percent_Population_Vaccinated
FROM PopVSVac;


---CREATE VIEWS for visualizations

CREATE VIEW Percent_Population_Vaccinated AS
WITH PopVSVac(continent, location, date, population, new_vaccinations, Rolling_Count_Vaccinated_Total)
AS (
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, SUM(CONVERT(int, CV.new_vaccinations)) OVER(PARTITION BY CD.location ORDER BY CD.location, CD.date) AS Rolling_Count_Vaccinated_Total
FROM CovidDeaths CD
JOIN CovidVaccinations CV ON CD.date=CV.date AND CD.location = CV.location
WHERE CD.continent IS NOT NULL
--ORDER BY 2,3;
)
--Percent of Population Vaccinated at each date
SELECT *, (Rolling_Count_Vaccinated_Total/population)*100 AS Percent_Population_Vaccinated
FROM PopVSVac;

--Test Percent_Population_Vaccinated VIEW
SELECT * FROM Percent_Population_Vaccinated;

