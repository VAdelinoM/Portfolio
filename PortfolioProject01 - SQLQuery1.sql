select *
From PortfolioProject1..CovidDeaths
where continent is not null
order by 3,4

--select *
--From PortfolioProject1..CovidVaccinations
--order by 3,4


-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows what percentage of population got Covid

Select Location, date, total_cases, population, (Convert(float, total_cases)/CONVERT(float, population))*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths
--Where location like '%spain%' and continent is not null
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(cast(total_cases as float)) as HighesInfectionCount, 
MAX(cast(total_cases as float) / cast(population as float))*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths
--Where location like '%spain%' and 
where continent is not null
Group by location, population
order by PercentPopulationInfected desc


-- Showing Countries with the Highest Death COunt per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location like '%spain%' and continent is not nullç
where continent is not null
Group by location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location like '%spain%' and continent is not nullç
where continent is null
Group by location
order by TotalDeathCount desc


-- Showing the Continents  with the highest death count

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location like '%spain%' and continent is not null
where continent is not null
Group by continent
order by TotalDeathCount desc




-- GLOBAL NUMBERS 

Select date, -- By eliminating "Date" from here "SELECT", from "GROUP BY" and "ORDER BY" you get the total.
	SUM(new_cases) as total_cases, 
	SUM(CAST(new_deaths as int)) as total_deaths, 
    CASE
		WHEN SUM(new_cases) = 0 THEN 0 -- To stop division by cero
		ELSE SUM(CAST(new_deaths as int))/SUM(new_cases)*100 
	END as DeathPercentage
From PortfolioProject1..CovidDeaths
--Where continent is not null
Group by Date, total_cases
HAVING 
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0 -- To stop division by cero
        ELSE SUM(CAST(new_deaths as int)) / SUM(new_cases) * 100 
    END > 0 -- It filters everything with over cero.

Order by date, total_cases;




-- Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(TRY_CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(TRY_CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac







-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(TRY_CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualization

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(TRY_CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select *
From PercentPopulationVaccinated