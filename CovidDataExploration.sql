--Covid 19 data exploration--

--Skills used: Joins, CTEs, Temp Tables, Creating Views, Window Functions, Aggregate Functions, Converting Data Types--


Select * 
from PortfolioProject.dbo.CovidDeaths
order by 3,4

--Selecting the data that I will be starting with--

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
order by 1,2

--Looking at total cases vs total deaths and showing the likelihood of death if covid is contracted in my country--

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1,2

--Looking at total cases vs population--
---shows percentage of population that got covid---

select location, date, total_cases, new_cases, population , (total_cases/population) * 100 as PercPopInfected
from PortfolioProject.dbo.CovidDeaths
order by 1,2

--Looking at countries with highest infection rate compared to population--

select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)) * 100 as PercPopInfected
from PortfolioProject.dbo.CovidDeaths
Group by location, population
order by PercPopInfected desc

--Showing Countries with Highest Death Count Per Population--

select location, Max(Cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc



--BREAKING THINGS DOWN BY CONTINENT--

--Showing continents with the highest death count per population

select continent, Max(Cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS--

select sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2

--Looking at total vaccinations vs population--

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject.dbo.CovidDeaths as dea
	join PortfolioProject.dbo.CovidVaccinations as vac
		on dea.location = vac.location
		and dea.date = vac.date

where dea.continent is not null

order by 2,3


--Using CTE to perform calculation on partition by in previous query to show the percent of population vaccinated--

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)

as

(

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject.dbo.CovidDeaths as dea
	join PortfolioProject.dbo.CovidVaccinations as vac
		on dea.location = vac.location
		and dea.date = vac.date

where dea.continent is not null

)

Select *, (RollingPeopleVaccinated/Population) * 100 as PercentVac

from PopVsVac


--Using a temp table to perform calculation on partion by in previous query--

IF OBJECT_ID('tempdb.dbo.#PercentPopulationVaccinated', 'U') IS NOT NULL
  DROP TABLE #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated

(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject.dbo.CovidDeaths as dea
	join PortfolioProject.dbo.CovidVaccinations as vac
		on dea.location = vac.location
		and dea.date = vac.date

--where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population) * 100

from #PercentPopulationVaccinated

--Creating a view to store data for later visualizations--

CREATE VIEW PERCENTPOPULATIONVACCINATED AS 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject.dbo.CovidDeaths as dea
	join PortfolioProject.dbo.CovidVaccinations as vac
		on dea.location = vac.location
		and dea.date = vac.date

where dea.continent is not null


