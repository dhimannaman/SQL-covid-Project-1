select * from PORTFOLIOPROJECT.dbo.CovidDeaths 
Where continent is not null
order by 3,4

--select * from PORTFOLIOPROJECT.dbo.covidvaccinations order by 3,4
--select data that we are goind to be using

Select location, date, total_cases, New_cases, Total_deaths, population from PORTFOLIOPROJECT..CovidDeaths order by 1,2


--looking at total cases vs total Deaths
--show likelihood of dying if you contract covid in your country

Select location, date, total_cases, Total_deaths, (total_deaths/total_cases)*100 as PercentPopulationInfect from PORTFOLIOPROJECT..CovidDeaths order by 1,2

--Looking at total cases vs Population

Select location, date, total_cases, population, (total_cases/population)*100 as Totalcasepercentage from PORTFOLIOPROJECT..CovidDeaths 
--where location like '%states%'
Where continent is not null
order by 1,2

--looking at country with highest infection rate compared to population 
Select location, population, MAX(total_cases) as HigestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfect from PORTFOLIOPROJECT..CovidDeaths 
--where location like '%states%'
Where continent is not null
group by population, location
order by PercentPopulationInfect  desc

--Showing country with the highest deathcount per population

Select location,  MAX(cast(total_deaths as int))as TotalDeathCount
from PORTFOLIOPROJECT..CovidDeaths 
--where location like '%states%'
Where continent is not null

group by location
order by TotalDeathcount  desc

--Let's break things down by	continent

--Showing the constients with the highest death count per population
Select continent,  MAX(cast(total_deaths as int))as TotalDeathCount
from PORTFOLIOPROJECT..CovidDeaths 
--where location like '%states%'
Where continent is not null
group by continent
order by TotalDeathcount  desc

--Global Numbers
Select   SUM(new_cases) as totalCases,SUM(cast (new_deaths as int )) as totaldeaths, SUM(cast (new_deaths as int ))/sum(new_cases)*100 as DeathPercentage 
from PORTFOLIOPROJECT..CovidDeaths 
--where location like '%states%'
where continent is not null 
--group by date
order by 1,2

--Looking at total population vs total vaccination

select dea.continent,dea.location,dea.date,population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/)
from 
PORTFOLIOPROJECT..CovidDeaths dea 
join
PORTFOLIOPROJECT..CovidVaccinations vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null 
order by 2,3



--USE CTE

with PopvsVac (continent, location, Date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/)
from 
PORTFOLIOPROJECT..CovidDeaths dea 
join
PORTFOLIOPROJECT..CovidVaccinations vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null 
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac


--TEMP TABLE 
Drop table if exists #percentpopulationvaccinated

create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/)
from 
PORTFOLIOPROJECT..CovidDeaths dea 
join
PORTFOLIOPROJECT..CovidVaccinations vac
on dea.location = vac.location
and dea.date=vac.date
--where dea.continent is not null 
--order by 2,3

select *,(RollingPeoplevaccinated/population)*100 From #percentpopulationvaccinated

--Creating View to store data for later visualizations

create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from 
PORTFOLIOPROJECT..CovidDeaths dea 
join
PORTFOLIOPROJECT..CovidVaccinations vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null 
--order by 2,3

Select * from percentpopulationvaccinated