# To activiate a particular database to use
USE myproject1;

# Returns all the fields in the tables 
SELECT * FROM covidvaccinations2;
SELECT * FROM coviddeaths;

# This selects the data we are going to be working with from the coviddeaths2 table
SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    coviddeaths
ORDER BY 1,2;

# This shows the percentage of total deaths vs total cases and this was rounded up to 1 decimal place
SELECT 
    location,
    Date,
    total_cases,
    total_deaths,
    ROUND((total_deaths/total_cases)*100,1) AS PercentageOfDeaths
FROM
    coviddeaths
WHERE location like '%Africa%'
ORDER BY 1,2;

#This shows the percentage of of population has got covid and this was rounded up to 1 decimal place
#This was ordered by PrecentageOfDeath in Descending order.
SELECT 
    location,
    Date,
    total_cases,
    population,
    ROUND((total_cases / population) * 100, 1) AS PercentageOfDeaths
FROM
    coviddeaths
WHERE
    location LIKE '%states%'
ORDER BY 5 DESC;

# This shows the countries with the highest infection count overall and the percentage of its population
SELECT 
    location,
    total_cases,
    population,
    ROUND(MAX((total_cases / population) * 100), 1) AS InfectionRate
FROM
    coviddeaths
GROUP BY location
ORDER BY 4 DESC;


# This shows the countries with the highest death case and the percentage of it population
# The total_deaths field in the table has a data type TEXT, so this has to change to integer using the CAST function

SELECT 
    location,
    MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeath,
    population,
    ROUND(MAX((total_deaths / population) * 100),
            1) AS DeathRate
FROM
    coviddeaths
GROUP BY location
ORDER BY 2 DESC;


# This shows the continent with the highest death count and the percentage of it population
# The total_deaths field in the table has a data type TEXT, so this has to change to integer using the CAST function
SELECT 
    continent,
    MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeath,
    population,
    ROUND(MAX((total_deaths / population) * 100),
            1) AS DeathRate
FROM
    coviddeaths
WHERE
    continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC;

#This fill up any empty space to Null in the field name 'continent'
UPDATE coviddeaths
SET continent = NULL
where continent = '';

#This shows the count of new cases, new deaths and % of new deaths vs new cases for EACH DAY globally. 

 SELECT 
    Date,
    SUM(new_cases) AS TotalCase,
    SUM(CAST(new_deaths AS SIGNED)) AS TotalDeath,
    ROUND((SUM(CAST(new_deaths AS SIGNED))/SUM(new_cases)) * 100,
            1) AS DeathRate
FROM
    coviddeaths
WHERE
    continent IS NOT NULL
GROUP BY date
ORDER BY 1 DESC; 

#This shows the count of new cases, new death and  % of new deaths vs new cases globally 

 SELECT 
    SUM(new_cases) AS TotalCase,
    SUM(CAST(new_deaths AS SIGNED)) AS TotalDeath,
    ROUND((SUM(CAST(new_deaths AS SIGNED)) / SUM(new_cases)) * 100,
            1) AS DeathRate
FROM
    coviddeaths
WHERE
    continent IS NOT NULL
ORDER BY 1 DESC; 

#This join the tables; coviddeaths and covidvaccinaction2
SELECT 
    *
FROM
    coviddeaths dea
        JOIN
    covidvaccinations2 vac ON dea.location = vac.location
        AND dea.date = vac.date;

#This shows the count and percentage of people in the world that are vaccinanted

SELECT 
    SUM(vac.total_vaccinations),
    SUM(dea.population),
    Round((SUM(vac.total_vaccinations) / SUM(dea.population)) * 100,1) AS PercantageOfVaccainted
FROM
    coviddeaths dea
        JOIN
    covidvaccinations2 vac ON dea.location = vac.location
        AND dea.date = vac.date;
# This show total population and new vaccinations
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations
FROM
    coviddeaths dea
        JOIN
    covidvaccinations2 vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY 1 , 2 , 3;
        
#This fill up any empty space  to Null in the field name 'new_vaccinations'
UPDATE covidvaccinations2 
SET 
    new_vaccinations = NULL
WHERE
    new_vaccinations = '';

#  This show the change in datatype for new_vaccinatios and a rolling count of new_vaccinations for each location. 
SELECT 
    dea.continent,
    dea.location,
    CAST(dea.date as date),
    dea.population,
    CAST(vac.new_vaccinations as signed),
    SUM(CAST(vac.new_vaccinations as signed)) OVER (PARTITION BY location order by dea.location, dea.date) AS RollingSumOfVaccination
FROM
    coviddeaths dea
        JOIN
    covidvaccinations2 vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
    AND dea.location = 'albania'
ORDER BY dea.location,dea.date;

#  This show the change in datatype for the field, new_vaccinatios, and a rolling sum of new_vaccinations for each location. 
SELECT 
    dea.continent,
    dea.location,
    CAST(dea.date as date),
    dea.population,
    CAST(vac.new_vaccinations as signed),
    SUM(CAST(vac.new_vaccinations as signed)) OVER (PARTITION BY location order by dea.location, dea.date) AS RollingSumOfVaccination
FROM
    coviddeaths dea
        JOIN
    covidvaccinations2 vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
    AND dea.location = 'albania'
ORDER BY 2 , 3,5;

#This shows a rolling sum of new_vaccinations for each location as a
# percentage of total new vaccination of that location. I have used CTE, beacuse we can't perform calculation on the field, RollingSumOfVaccination
WITH POPvsVACC (continent, location,Date, population, new_vaccination,RollingSumOfVaccination)
AS
(SELECT 
    dea.continent,
    dea.location,
    CAST(dea.date as date) AS Date,
    dea.population,
    CAST(vac.new_vaccinations as signed) AS new_vaccinations,
    SUM(CAST(vac.new_vaccinations as signed)) OVER (PARTITION BY location order by dea.location, dea.date) AS RollingSumOfVaccination
FROM
    coviddeaths dea
        JOIN
    covidvaccinations2 vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
    AND dea.location = 'albania')
    SElECT *, ROUND((RollingSumOfVaccination/population)*100,1) AS PercentageRolling 
    FROM POPvsVACC;
-- ORDER BY 2,3,5; this is a comment because ORDER BY can not be used in a CTE

#This shows a rolling sum of new_vaccinations for each location as a
#percentage of total new vaccination of that location. I have used temp table, beacuse we can't perform calculation on the field, RollingSumOfVaccination

DROP TABLE IF EXISTS POPvsVACC2;

CREATE TABLE #POPvsVACC2
(
Continent Varchar(255),
Location Varchar(255),
Date Datetime,
Population int,
new_vaccination int, 
RollingSumOfVaccinatuon int, 
PercentageRolling int);

INSERT INTO POPvsVACC2
SELECT 
    dea.continent,
    dea.location,
    CAST(dea.date as date) AS Date,
    dea.population,
    CAST(vac.new_vaccinations as signed) AS new_vaccinations,
    SUM(CAST(vac.new_vaccinations as signed)) OVER (PARTITION BY location order by dea.location, dea.date) AS RollingSumOfVaccination
FROM
    coviddeaths dea
        JOIN
    covidvaccinations2 vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;
    #AND dea.location = 'albania'
    
SELECT * FROM POPvsVACC2;

#creating views to hold frequently used data
CREATE OR REPLACE VIEW POPvsVACC3 AS
SELECT 
    location,
    MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeath,
    population,
    ROUND(MAX((total_deaths / population) * 100),
            1) AS DeathRate
FROM
    coviddeaths
GROUP BY location
ORDER BY 2 DESC;

SELECT * FROM POPvsVACC3;
