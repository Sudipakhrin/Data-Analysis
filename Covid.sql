Select * 
From PortfolioProject..covidDeath
where continent is  not null
order by 3,4

--Select * 
--From PortfolioProject..covidVaccination
--order by 3,4

--Select Data that we are going to be using

use PortfolioProject;

Select Location, date, total_cases, new_cases , total_deaths,population 
From covidDeath
order by 1,2

-- Looking at the total cases vs Total deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT 
    Location, 
    date, 
    total_cases, 
    total_deaths, 
    (CAST(total_deaths AS float)/CAST(total_cases AS float))* 100 as DeathPercentage 
FROM covidDeath 
Where Location like 'Nepal'
ORDER BY 1,2

--Looking at the Total Cases vs Populaton
-- SHows what percentage of population got covid
Select Location, date, population,total_cases  ,(total_cases/population)*100 as PercentPopulationinfected
From covidDeath
Where Location like 'Nepal'
order by 1,2


-- looking at country with highest infection rate compared to population

Select Location, population, MAX(cast(total_cases as int))as HighestInfectionCount,Max((total_cases)/population)*100 as PercentPopulationinfected
From covidDeath
--Where Location like 'Nepal'
Group by location,population
order by PercentPopulationinfected desc



-- Showing the countries with the highest Death Count per population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From covidDeath
--Where Location like 'Nepal'
where continent is not null
Group by location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT



-- Showing the continent with the highest death count

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From covidDeath
--Where Location like 'Nepal'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers

SELECT date, SUM(new_cases) as totalCases, SUM(CAST(new_deaths AS int)) as totalDeaths, 
  CASE WHEN SUM(new_cases) = 0 THEN NULL 
       ELSE SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 
  END AS DeathPercentage
FROM covidDeath
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date, SUM(new_cases)

SELECT  SUM(new_cases) as totalCases, SUM(CAST(new_deaths AS int)) as totalDeaths, 
  CASE WHEN SUM(new_cases) = 0 THEN NULL 
       ELSE SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 
  END AS DeathPercentage
FROM covidDeath
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--Looking at total population vs vaccination
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccination
--, (RollingPeopleVaccination/population)*100
from covidDeath dea
join covidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent,Location,Date,Population,new_Vaccinations,RollingPeopleVaccination)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccination
--, (RollingPeopleVaccination/population)*100
from covidDeath dea
join covidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *,(RollingPeopleVaccination/Population)*100
from PopvsVac


--Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
( 
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccination numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccination
--, (RollingPeopleVaccination/population)*100
from covidDeath dea
join covidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


select *,(RollingPeopleVaccination/Population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
 
Create View PercentPopulationVaccinated as 
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccination
--, (RollingPeopleVaccination/population)*100
from covidDeath dea
join covidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


