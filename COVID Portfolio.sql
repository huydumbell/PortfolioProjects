Select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--Select * from PortfolioProjects..CovidVaccination
--order by 3,4

--Select data that we are going to use
Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at total cases vs total deaths
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
	-- Shows likelihood of dieing if you contract covid in Vietnam
where location like'%Viet%'
order by 1,2

--Looking at  total cases vs population
--Show what percentage of population got covid
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select  Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

--Show the countries with Highest Death Count per Population
Select  Location, MAX(cast (total_deaths  as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT
Select  continent, MAX(cast (total_deaths  as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--Showing continents with the Highest Death Count
Select  continent, MAX(cast (total_deaths  as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMEBERS
Select 
--	date,
	SUM(new_cases) as TotalCases, 
	sum(CAST(new_deaths as int)) as TotalDeaths, 
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
	-- Shows likelihood of dieing if you contract covid in Vietnam: where location like'%Viet%'
where continent is not null
--group by date
order by 1,2


-- Looking at TotalPopulation VS Vaccinations
Select 
		dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations,
		sum(convert (int, vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated,

from PortfolioProject..CovidDeaths dea
Join PortfolioProjects..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--	USE CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as 
(
Select 
		dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations,
		sum(convert (int, vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths dea
Join PortfolioProjects..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
Select *, (RollingPeopleVaccinated/Population) * 100 
from PopVsVac

--Temp Table

Drop Table if exists #PercentPopulationVaccinated 
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select 
		dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations,
		sum(convert (int, vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths dea
Join PortfolioProjects..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3

Select *, (RollingPeopleVaccinated/Population) * 100 
from #PercentPopulationVaccinated



--Creating view to store data to later visualizations

Create View PercentPopulationVaccinated as
Select 
		dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations,
		sum(convert (int, vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths dea
Join PortfolioProjects..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

SELECT * FROM sys.views WHERE name = 'PercentPopulationVaccinated'

select * from PercentPopulationVaccinated

drop view PercentPopulationVaccinated