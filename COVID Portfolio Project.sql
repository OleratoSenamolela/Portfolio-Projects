SELECT * 
FROM CovidProject.cd
-- WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT * 
FROM CovidProject.cv
-- WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject.cd
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths  (Likelihood of dying with Covid)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM CovidProject.cd
WHERE location LIKE "South Africa" AND continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Total Cases vs Population (Population that contracted covid)

SELECT location, date, population, total_cases, (total_cases/population)*100 AS contraction_percentage
FROM CovidProject.cd
WHERE location LIKE "South Africa" AND continent IS NOT NULL
ORDER BY 1,2 ;

-- Countries with Highest Cases

SELECT location, population, MAX(total_cases) AS highest_cases, Max((total_cases/population))*100 AS contraction_percentage
FROM CovidProject.cd
-- WHERE location LIKE "South Africa" AND continent IS NOT NULL
GROUP BY location, population
ORDER BY contraction_percentage DESC;

-- Countries with the Highest Death Count per Population

SELECT location, population, SUM(total_deaths) AS total_death_count
FROM CovidProject.cd
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY total_death_count DESC;

-- Continents with Highest Deaths Aggregated by Continent

SELECT location, MAX(CAST(total_deaths AS SIGNED)) AS total_death_count
FROM CovidProject.cd
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- Global Statistics

SELECT date, 
                SUM(new_cases) AS TotalGlobalCases, 
                SUM(new_deaths) AS TotalGlobalDeaths ,
                (SUM(new_deaths)/SUM(new_cases))*100 AS GlobalDeathPercentage
FROM CovidProject.cd
-- WHERE location LIKE "South Africa" 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- JOINT TABLES
--  Total Population vs Vaccination

SELECT  cv.continent, cv.location, cv.date, cd.population, cv.new_vaccinations
FROM CovidProject.cv 
JOIN CovidProject.cd ON cv.location = cd.location AND cv.date = cd.date
WHERE cv.continent IS NOT NULL
ORDER BY 3,1,2;

SELECT  cv.continent, 
                cv.location, 
                cv.date, 
                cd.population, 
                cv.new_vaccinations, 
                SUM(CONVERT(cv.new_vaccinations, SIGNED)) OVER (Partition by cv.location ORDER BY location, date) AS cumulative_vaccinations
                -- (cumulative_vaccinations/population)*100
FROM CovidProject.cv 
JOIN CovidProject.cd ON cv.location = cd.location AND cv.date = cd.date
WHERE cv.continent IS NOT NULL
ORDER BY  2,3;

-- USING CTE

WITH population_vs_vaccination (Continent, Location, Date, Population, new_vaccination, cumulative_vaccinations) AS
    (SELECT  cv.continent, 
                 cv.location, 
                 cv.date, cd.population, 
                 cv.new_vaccinations, 
                 SUM(CONVERT(cv.new_vaccinations, SIGNED)) OVER (Partition by cv.location ORDER BY location, date) AS cumulative_vaccinations
                 -- (cumulative_vaccinations/population)*100
    FROM CovidProject.cv 
    JOIN CovidProject.cd ON cv.location = cd.location AND cv.date = cd.date
    WHERE cv.continent IS NOT NULL
    -- ORDER BY  2,3
    )
SELECT *, (cumulative_vaccinations/population)*100 Vaccinated_population_percentage
FROM population_vs_vaccination;

-- Temporary Table

DROP TABLE IF EXISTS VanccinatedPopulationPercentage;
CREATE TABLE VanccinatedPopulationPercentage 
(Continent NVARCHAR(255), 
Location NVARCHAR(255),
dates DATETIME,
Population NUMERIC,
New_vaccination NUMERIC,
cumulative_vaccinations NUMERIC
);

INSERT INTO VanccinatedPopulationPercentage
SELECT  cv.continent, 
                cv.location, 
                cv.date, 
                cd.population, 
                cv.new_vaccinations, 
                SUM(CONVERT(cv.new_vaccinations, SIGNED)) OVER (Partition by cv.location ORDER BY location, date) AS cumulative_vaccinations
                -- (cumulative_vaccinations/population)*100
FROM CovidProject.cv 
JOIN CovidProject.cd ON cv.location = cd.location AND cv.date = cd.date
WHERE cv.continent IS NOT NULL;
-- ORDER BY  2,3

SELECT *, (cumulative_vaccinations/Pupulation)*100 AS Vaccinated_population_percentage
FROM VanccinatedPopulationPercentage;

--  Creating View for later Visualisations

CREATE VIEW VanccinatedPopulationPercentage AS 
SELECT  cv.continent, 
                cv.location, 
                cv.date, 
                cd.population, 
                cv.new_vaccinations, 
                SUM(CONVERT(cv.new_vaccinations, SIGNED)) OVER (Partition by cv.location ORDER BY location, date) AS cumulative_vaccinations
                -- (cumulative_vaccinations/population)*100 AS Vaccinated_population_percentage
FROM CovidProject.cv 
JOIN CovidProject.cd ON cv.location = cd.location AND cv.date = cd.date
WHERE cv.continent IS NOT NULL;
-- ORDER BY  2,3

SELECT * 
FROM CovidProject.VanccinatedPopulationPercentage;

