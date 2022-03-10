SELECT * FROM CovidDeath
ORDER BY 3,4

SELECT * FROM CovidVaccination
ORDER BY 3,4

--SELECT DATA THAT I AM GOING TO BE USING
 SELECT Location,date,total_cases,new_cases,total_deaths,population
 FROM CovidDeath
 ORDER BY 1,2

 --LOOKING AT TOTAL_CASES VS TOTAL_DEATHS
SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
 FROM CovidDeath
 ORDER BY 1,2

 --LOOKING AT GEORGIA'S DATA
 SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
 FROM CovidDeath
 WHERE Location = 'Georgia'
 ORDER BY 1,2

 --LOOKING AT TOTAL_CASES VS POPULATION
 SELECT Location,date,total_cases,population,(total_cases/population)*100 AS CasePercentage
 FROM CovidDeath
 WHERE Location = 'Georgia'
 ORDER BY 1,2


 --LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
 SELECT Location,MAX(total_cases) AS HighestInfectionCount,population,MAX((total_cases/population))*100 AS PercentPoulationInfected
 FROM CovidDeath
 GROUP BY Location,population
 ORDER BY PercentPoulationInfected DESC

 --SHOWING COUNTRIES HIGHEST DEATH COUNT PER POPULATION
 SELECT Location,MAX(CAST(total_deaths AS bigint)) AS TotalDeathCount
 FROM CovidDeath
 WHERE continent IS NOT NULL
 GROUP BY Location
 ORDER BY TotalDeathCount DESC

 --BREAKING DATA DOWN BY CONTINENTS
 SELECT continent,MAX(CAST(total_deaths AS bigint)) AS TotalDeathCount
 FROM CovidDeath
 WHERE continent IS NOT NULL AND location NOT IN ('Upper middle income','High income','Lower middle income','Low income')
 GROUP BY continent
 ORDER BY TotalDeathCount DESC

 --GLOBAL NUMBERS
 SELECT date,SUM(new_cases) AS SumOfNewCases,SUM(CAST(new_deaths as BIGINT)) AS SumOfNewDeaths,SUM(CAST(new_deaths as BIGINT))/SUM(new_cases)*100 AS DeathPercentage
 FROM CovidDeath
 WHERE continent IS NOT NULL
 GROUP BY date
 ORDER BY 1,2


 SELECT SUM(new_cases) AS SumOfNewCases,SUM(CAST(new_deaths as BIGINT)) AS SumOfNewDeaths,SUM(CAST(new_deaths as BIGINT))/SUM(new_cases)*100 AS DeathPercentage
 FROM CovidDeath
 WHERE continent IS NOT NULL
 ORDER BY 1,2


 --JOINING COVID DEATHS AND COVID VACCINATIONS
SELECT * FROM CovidDeath AS D
JOIN CovidVaccination AS V
ON D.location = V.location AND D.date = V.date

--lOOKING AT TOTAL POPULATION VS TOTAL VACCINATION
SELECT D.continent,D.location,D.date,D.population,V.new_vaccinations FROM CovidDeath AS D
JOIN CovidVaccination AS V
ON D.location = V.location AND D.date = V.date
WHERE D.continent IS NOT NULL
ORDER BY 1,2,3

SELECT D.continent,D.location,D.date,D.population,V.new_vaccinations,
SUM(CAST(V.new_vaccinations AS BIGINT)) OVER(PARTITION BY D.location ORDER BY D.location,D.date) AS RollingPeopleVacced
FROM CovidDeath AS D
JOIN CovidVaccination AS V
ON D.location = V.location AND D.date = V.date
WHERE D.continent IS NOT NULL
ORDER BY 2,3

--USING CTE TO SHOWCASE HOW MANY PEOPLE IS VACCINATED COMPARED TO POPULATION (VACCINATED VS POPULATION) 
WITH PopVSVacc	(Continent,location,date,population,new_vaccinations,RollingPeopleVacced)
AS
(
SELECT D.continent,D.location,D.date,D.population,V.new_vaccinations,
SUM(CAST(V.new_vaccinations AS BIGINT)) OVER(PARTITION BY D.location ORDER BY D.location,D.date) AS RollingPeopleVacced
FROM CovidDeath AS D
JOIN CovidVaccination AS V
ON D.location = V.location AND D.date = V.date
WHERE D.continent IS NOT NULL
)

SELECT *,(RollingPeopleVacced/population)*100 FROM PopVSVacc


--TEMP TABLE

CREATE TABLE #PercentPoulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVacced numeric)

INSERT INTO #PercentPoulationVaccinated
SELECT D.continent,D.location,D.date,D.population,V.new_vaccinations,
SUM(CAST(V.new_vaccinations AS BIGINT)) OVER(PARTITION BY D.location ORDER BY D.location,D.date) AS RollingPeopleVacced
FROM CovidDeath AS D
JOIN CovidVaccination AS V
ON D.location = V.location AND D.date = V.date
WHERE D.continent IS NOT NULL

SELECT *,(RollingPeopleVacced/population)*100 FROM #PercentPoulationVaccinated

-- CREATING VIEW FOR DATA 
CREATE VIEW GlobalNumbers AS
 SELECT SUM(new_cases) AS SumOfNewCases,SUM(CAST(new_deaths as BIGINT)) AS SumOfNewDeaths,SUM(CAST(new_deaths as BIGINT))/SUM(new_cases)*100 AS DeathPercentage
 FROM CovidDeath
 WHERE continent IS NOT NULL

 SELECT * FROM GlobalNumbers
 


