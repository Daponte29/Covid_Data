Use [Project1-Covid];



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

 --Percent of population who got Covid in the United States
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
SELECT location, MAX(total_deaths) / MAX(population) AS DeathPercentagePerPopulation
FROM CovidDeaths
GROUP BY location
HAVING MAX(total_deaths) / MAX(population) IS NOT NULL
ORDER BY DeathPercentagePerPopulation DESC;





Select * from CovidDeaths;

