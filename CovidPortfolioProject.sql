--select * from CovidDeaths
--select * from CovidVaccinations

--select location,date,total_cases,new_cases,total_deaths,population 
--from CovidDeaths
--order by 1,2


/* looking at total cases vs total deaths */

--SELECT 
--    location,
--    date,
--    total_cases,
--    total_deaths,
--    total_deaths/total_cases*100 AS death_percentage
--FROM 
--    CovidDeaths
--where location like '%morocco%'
--ORDER BY 
--    location, date;


/* looking at total cases vs population */

--SELECT 
--    location,
--    date,
--    population,
--    total_cases,
--    total_cases/population*100 AS total_cases_percentage
--FROM 
--    CovidDeaths
--where location like '%morocco%'
--ORDER BY 
--    date;


/* looking at countries with highest infection rate compared to popilation */

--SELECT 
--    location,
--    population,
--    max(total_cases) as HighestInfectionCount,
--    max(total_cases)/population*100 AS PercentPopulationInfected
--FROM 
--    CovidDeaths
--group by location,population
--order by PercentPopulationInfected desc


/* Showing countries with highest death count */

--SELECT 
--    location,
--    max(total_deaths) as TotalDeathsCount
--FROM 
--    CovidDeaths 
--where continent	is not null
--group by location
--order by TotalDeathsCount desc


/* Showing continents with highest death count */


--SELECT 
--    location,
--    max(total_deaths) as TotalDeathsCount
--FROM 
--    CovidDeaths 
--where continent	is  null
--group by location
--order by TotalDeathsCount desc



/* Showing continents with highest death count per population */

--SELECT 
--    location,population,
--    max(total_deaths) as TotalDeathsCount,
--	max(total_deaths)/population*100 as TotalDeathsPerPopulationCount
--FROM 
--    CovidDeaths 
--where continent	is  null
--group by location,population
--order by TotalDeathsPerPopulationCount desc


/*	Global Numbers (values/world)	*/

/*
select --date,
	   sum(new_cases) as total_cases,
	   sum(new_deaths) as total_deaths,
	   CASE WHEN SUM(new_cases) <> 0 THEN SUM(new_deaths) / SUM(new_cases) * 100 ELSE 0 END AS DeathPercentage
from CovidDeaths 
where continent is not null
--group by date
--order by date
*/



/* Looking at total population vs vaccination */
---------------------------------------------------
--select distinct location,population 
--from CovidDeaths 
--where continent <> 'null'
--order by location
-----------------------------------------------------
--select location,sum(new_vaccinations) as TotalVaccinations
--from  CovidVaccinations 
--where continent <> 'null'
--group by location
--order by location
------------------------------------------------------------------
--select CovidVaccinations.location,population,sum(new_vaccinations) as TotalVaccinations
--from CovidVaccinations
--join CovidDeaths
--on CovidVaccinations.location=CovidDeaths.location 
--and CovidVaccinations.date=CovidDeaths.date
--where CovidVaccinations.continent is not null
--group by CovidVaccinations.location,population
--order by location
--------------------------------------------------------------------------
--select 
--	dea.continent,
--	dea.location,
--	dea.date,
--	dea.population,
--	vac.new_vaccinations,
--	sum(vac.new_vaccinations) over(partition by dea.location order by dea.location,dea.date) 
--		as RollingPeopleVaccinated
--	--, (RollingPeopleVaccinated/population)*100
--from CovidDeaths dea
--join CovidVaccinations vac
--on dea.location=vac.location 
--and dea.date=vac.date
--where dea.continent is not null
--order by 1,2,3
-------------------------------------------------------------------
/*
problem in (RollingPeopleVaccinated/population)*100 
solutions:
	-CTE
	or
	-temp table (temporaire)
	or 
	-view (permanent)
*/
----------------------------------------------------------
-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac





-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)



Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

alter View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from PercentPopulationVaccinated