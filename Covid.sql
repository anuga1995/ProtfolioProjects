-- Display rows and columns of the table

Select * from Project.coviddeaths
where continent is not null
order by 3,4;

-- Totalcases and Death Percentage at the location India
Select location, date, Population, total_cases, (total_cases/population)* 100 as DeathPercentage
from Project.coviddeaths
where location like '%India%'
order by 1,2;

-- Totalcases and Death Percentage at the location USA
Select location, date, Population, total_cases, (total_cases/population)* 100 as DeathPercentage
from Project.coviddeaths
where location like '%States%'
order by 1,2;


-- Covidcases at location greater than 100000
Select location, date, Population, total_cases, (total_cases/population)* 100 as DeathPercentage
from Project.coviddeaths
where total_cases > '100000'
order by 1,2;

-- Highest number of infection location wise
Select location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/Population)) as PercentPopulationInfected
From Project.coviddeaths
Group by location, Population
Order by  PercentPopulationInfected desc;

-- Total Death count continent wise.
Select  continent, MAX(cast(total_deaths as float)) as DeathCount
from Project.coviddeaths
where continent is not null
Group by continent
order by DeathCount desc;

-- Total number of cases against the population
Select continent, Max(total_cases/Population) * 100 as GlobalCases
from Project.coviddeaths
where continent is not null
group by  continent
order by Globalcases desc;

-- Death in India due to covid outbreak
SELECT location, 
  continent,
  SUM(total_deaths) AS total_deaths, 
  population, 
  ROUND(SUM(total_deaths) / population * 1000000, 2) AS deaths_per_million
FROM Project.coviddeaths
WHERE location = 'India' AND continent IS NOT NULL
GROUP BY location, continent, population;

-- Continent with highest number of deaths
SELECT continent,
  SUM(total_deaths) AS total_deaths, 
  MAX(population) AS max_population
FROM Project.coviddeaths
  Where continent is not null
GROUP BY continent
ORDER BY total_deaths DESC, 
  max_population DESC
LIMIT 5;

-- Global death percentage 
SELECT continent,
  SUM(total_deaths) / SUM(total_cases) * 100 AS global_death_percentage
FROM Project.coviddeaths
where continent is not null
group by continent
order by 2;

-- Global death count based on newcases and new deaths
Select Sum(new_cases) as total_new_cases, Sum(cast(new_deaths as float)) as totat_new_deaths, Sum(cast(new_deaths as float))/sum(new_cases) * 100 as GlobalDeathPercent
from Project.coviddeaths
where continent is not null;

-- Global Numbers
Select date, Sum(new_cases) as total_new_cases, Sum(cast(new_deaths as float)) as totat_new_deaths, Sum(cast(new_deaths as float))/sum(new_cases) * 100 as GlobalDeathPercent
from Project.coviddeaths
where continent is not null
Group by date
order by 1,2;

--  daily new COVID-19 deaths for a specific location
SELECT location, date, new_deaths
FROM Project.coviddeaths
WHERE location = 'United States';

-- Daily new COVID-19 deaths and the 7-day moving average for the India:
SELECT location, date, new_deaths, AVG(new_deaths) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS avg_deaths_last_7_days
FROM Project.coviddeaths
WHERE location = 'India';

-- Daily new COVID-19 deaths and the 7-day moving average for all countries/regions:
SELECT location, date, new_deaths, AVG(new_deaths) OVER (PARTITION BY location ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS avg_deaths_last_7_days
FROM Project.coviddeaths;

-- The top 5 countries/regions with the highest number of COVID-19 deaths per million population as of March 1, 2023, and their 7-day moving average of daily new COVID-19 deaths:
SELECT location, total_deaths_per_million, new_deaths, AVG(new_deaths) OVER (PARTITION BY location ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS avg_deaths_last_7_days
FROM Project.coviddeaths
WHERE date = '2021-03-01' and continent is not null
ORDER BY total_deaths_per_million DESC
LIMIT 5;

-- The total number of COVID-19 deaths and the average daily new COVID-19 deaths for each country/region with a population greater than 100 million, and order the results by the average daily new deaths in descending order:
SELECT location, SUM(total_deaths) AS total_deaths, AVG(new_deaths) AS avg_new_deaths
FROM Project.coviddeaths
WHERE population > 100000000 and continent is not null
GROUP BY location
HAVING AVG(new_deaths) > 500
ORDER BY avg_new_deaths DESC;

-- The list of countries/regions that have had at least one day with zero new COVID-19 cases after their first reported case:
SELECT location
FROM Project.coviddeaths
WHERE new_cases = 0 AND date > (SELECT MIN(date) FROM Project.coviddeaths WHERE new_cases > 0 AND location = coviddeaths.location)
GROUP BY location;
  
  -- The total number of patients in intensive care by continent:
SELECT continent, SUM(icu_patients) AS total_icu_patients
FROM Project.coviddeaths
GROUP BY continent
order by total_icu_patients;

-- countries have been the hardest hit in terms of the case fatality rate.
SELECT 
  location, 
  date, 
  total_cases, 
  total_deaths, 
  total_cases_per_million, 
  total_deaths_per_million,
  (total_deaths*100.0/total_cases) AS case_fatality_rate
FROM Project.coviddeaths
WHERE continent = 'Asia'
ORDER BY case_fatality_rate DESC
LIMIT 10;

--  the country with the highest number of people fully vaccinated per hundred as of the latest date in the table:
SELECT location, people_fully_vaccinated_per_hundred
FROM Project.covidvaccination
WHERE date = (SELECT MAX(date) FROM Project.covidvaccination)
ORDER BY people_fully_vaccinated_per_hundred DESC;

-- the daily new people vaccinated for each continent, as of the latest available date:
SELECT continent, date, new_vaccinations
FROM Project.covidvaccination
WHERE date = (SELECT MAX(date) FROM Project.covidvaccination) and continent is not null
ORDER BY continent, date;

-- Percent of people vaccinated
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From Project.coviddeaths dea
Join Project.covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

-- the estimated total number of people over 65 who have been vaccinated
SELECT 
    location, 
     aged_65_older, 
    people_vaccinated, 
    (people_vaccinated * aged_65_older / 100) as estimated_vaccinated_65_plus
FROM 
   Project.covidvaccination
ORDER BY 
    estimated_vaccinated_65_plus DESC;
    






