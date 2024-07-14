SELECT *
FROM Project1..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM Project1..CovidVoccation
--ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM Project1..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Looking ay countries with Highest Infection Rate compared to Population
SELECT location,date,population,total_cases,(CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 AS PercentPopulationInfection
FROM Project1..CovidDeaths
WHERE location like '%states%'
AND continent is not null
ORDER BY PercentPopulationInfection desc

 --Showing Countries with Highest Death Count per population
SELECT location,Max(cast(total_deaths as float)) as TotalDeathCount
FROM Project1..CovidDeaths
--WHERE location like '%states%'
WHERE continent is  null
GROUP BY location
ORDER BY TotalDeathCount desc

--GLOBLE NUMBERS
SELECT SUM(cast(new_cases as int))as total_new_cases,SUM(cast(new_deaths as int))as total_new_deathes,SUM(cast(new_deaths as int))/NULLIF(SUM(cast(new_cases as float)),0)*100 AS DeathPercentage
FROM Project1..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2 

SELECT *
FROM Project1..CovidDeaths dea
JOIN Project1..CovidVoccation vac
    ON dea.location = vac.location
	and dea.date = vac.date

--Looking at Total Population vs Vaccinations
with PopvsVac (Continent,Location, date,population,new_vaccinations, RollingpeopleVaccinated)
as(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER by dea.location,dea.date) AS RollingpeopleVaccinated
FROM Project1..CovidDeaths dea
JOIN Project1..CovidVoccation vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *,(RollingpeopleVaccinated/population)*100
From PopvsVac

--TEMP TABLE

DROP Table if exists #percentpopulationVaccinated
CREATE TABLE #percentpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinaions numeric,
RollingpeopleVaccinated numeric
)

INSERT INTO #percentpopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER by dea.location,dea.date) AS RollingpeopleVaccinated
FROM Project1..CovidDeaths dea
JOIN Project1..CovidVoccation vac
    ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

Select *,(RollingpeopleVaccinated/population)*100
From #percentpopulationVaccinated

--Creating View to store data for later visualization

USE Project1
GO
Create View percentpopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER by dea.location,dea.date) AS RollingpeopleVaccinated
FROM Project1..CovidDeaths dea
JOIN Project1..CovidVoccation vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
GO
