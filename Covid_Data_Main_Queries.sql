Use [Project1-Covid];



Select *
from [Project1-Covid]..CovidDeaths
order by 3,4;


Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2;
