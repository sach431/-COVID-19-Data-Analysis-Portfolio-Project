select * from PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--select * from PortfolioProject..CovidVaccinations
--order by 3,4
-- select data that we are going to using

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Lokking at total cases vs total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

-- Looking at total caes vs population
-- show what  percenatge of population got covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulatonInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population

Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulatonInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by PercentPopulatonInfected desc

-- Showing Countries With Highest Death count per Population

Select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
group by location
order by TotalDeathCount desc


--Let's break things down by contient

-- Showing continent with the highest death count per population 

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Number

Select sum(new_cases), sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
--Group by date
order by 1,2


--Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as Rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--using ETC

with popvsvac(continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as Rollingpeoplevaccinated
--(Rollingpeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
select *, (Rollingpeoplevaccinated/population)*100
from popvsvac


--Temp Table
Drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as Rollingpeoplevaccinated
--(Rollingpeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--Where dea.continent is not null
order by 2,3
select *, (Rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated


--Creating view to store data for later visualizations
USE PortfolioProject;
GO

CREATE VIEW dbo.PercentPopulationVaccinated AS
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (
        PARTITION BY dea.location ORDER BY dea.date
    ) AS RollingVaccinated
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
GO


select * from PercentPopulationVaccinated