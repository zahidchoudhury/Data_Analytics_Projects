select *
from PortfolioProject..Covid_death$
where continent is not null
order by 3,4

--select *
--from PortfolioProject..Covid_Vacination$
--order by 3,4

--select data that we are going to use

select location, date, total_cases, new_cases,total_deaths, population
from PortfolioProject..Covid_death$
order by 1,2

--Looking at Total cases vs total deaths
--shows likeliohood of dying in India
select location, date, total_cases, new_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..Covid_death$
--Where location like '%india%'
order by 1,2

--Looking at Total cases vs population
select location, date, total_cases,population, new_cases,(total_cases/population)*100 as total_case_Percentage
from PortfolioProject..Covid_death$
--Where location like '%india%'
order by 1,2

--Looking at countries with highest infection compared to population
select location,population ,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..Covid_death$
Group by location, population
--Where location like '%india%'
order by PercentPopulationInfected DESC

--Break things down by continent WITH HIGHEST DEATH
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..Covid_death$
where continent is  null
Group by continent
order by TotalDeathCount DESC

--correct method for continent
--need to remove income tab
select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..Covid_death$
where continent is null 
Group by location
order by TotalDeathCount DESC

--only continents
select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..Covid_death$
where continent is null
Group by location
order by TotalDeathCount DESC


--SHOWING WITH HIGHEST DEATH
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..Covid_death$
where continent is not null
Group by location
order by TotalDeathCount DESC


--showing continets with higghest death 
select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..Covid_death$
where continent is not null
Group by continent
order by TotalDeathCount DESC


--Global Numbers
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as Death_Percentage
From PortfolioProject..Covid_death$
where continent is not null
group by date
order by 1,2


--COVID VACINATION

select * 
From PortfolioProject..Covid_Vacination$

--JOIN
select * 
From PortfolioProject..Covid_death$ dea
JOIN PortfolioProject..Covid_Vacination$ vac
	on dea.location = vac.location
	and dea.date = vac.date

--total population vs vaccination
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccination--, (RollingPeopleVaccination/population)*100
--to add cce or temp table
From PortfolioProject..Covid_death$ dea
JOIN PortfolioProject..Covid_Vacination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CCE
With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccination)
as
(
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccination--, (RollingPeopleVaccination/population)*100
--to add cce or temp table
From PortfolioProject..Covid_death$ dea
JOIN PortfolioProject..Covid_Vacination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccination/population)*100 as VaccinationnPercentDay
From PopvsVac


--
--
--USING TEMP TABLE

DROP table if exists #PercentPopulationVaccinaton
create table #PercentPopulationVaccinaton
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccination numeric
)
INSERT into #PercentPopulationVaccinaton
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccination
From PortfolioProject..Covid_death$ dea
JOIN PortfolioProject..Covid_Vacination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVaccination/population)*100 as VaccinationnPercentDay
From #PercentPopulationVaccinaton


--view
--creating view to store data for later stage - visulization
Create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccination
From PortfolioProject..Covid_death$ dea
JOIN PortfolioProject..Covid_Vacination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
From PercentPopulationVaccinated