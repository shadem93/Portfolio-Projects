-- Select data from both tables ordered by column 3 (location) and 4 (date)
Select *
from PorfolioProject.dbo.Covid_deaths
Where continent is not null
ORDER BY 3,4
;
SELECT *
FROM PORFOLIOPROJECT.DBO.COVID_VACCINES
ORDER BY 3,4
;


-- Select data we are using
SELECT location,date,total_cases_per_million,new_cases_per_million,total_deaths_per_million,population
FROM PorfolioProject.dbo.Covid_deaths
ORDER BY 1,2;



-- Loooking into Total Cases vs Total Deaths UK (Percent of dying of people dying of covid in the world countries)
-- SHOWS THE LIKELIHOOD OF DYING IF YOU GET COVID IN YOUR COUNTRY - i did it specficially for the uk
SELECT location,date,total_cases_per_million,total_deaths_per_million,(total_deaths_per_million/total_cases_per_million)*100 AS DeathPercentage
FROM PorfolioProject.dbo.Covid_deaths
--where location like '%king%'
ORDER BY 1,2;



-- Total cases vs population
-- Shows total % of population in the UK that has gotten covid
SELECT location,date,population,total_cases_per_million,(total_cases_per_million/population)*100 AS Percent_population_infected
FROM PorfolioProject.dbo.Covid_deaths
--where location like '%king%'
ORDER BY 1,2;



-- WHich countient has the highest infection rate compared to population

SELECT continent,MAX(total_cases_per_million) AS Highestinfectioncount,MAX((total_cases_per_million)) AS Percent_population_infected
FROM PorfolioProject.dbo.Covid_deaths
--where location like '%king%'
Where continent is not null
GROUP BY continent
ORDER BY Percent_population_infected desc;

-- WHich country has the highest infection rate compared to population

SELECT location, population,MAX(total_cases_per_million) AS Highestinfectioncount,MAX((total_cases_per_million/population))*100 AS Percent_population_infected
FROM PorfolioProject.dbo.Covid_deaths
--where location like '%king%'
GROUP BY location,population
ORDER BY Percent_population_infected desc;

-- Which continent has the highest death rate (Location column also includes the contient data)
SELECT location, MAX(cast(total_deaths as INT)) AS HighestDeathcount
FROM PorfolioProject.dbo.Covid_deaths
--where location like '%king%'
Where continent is null
GROUP BY location
ORDER BY HighestDeathcount desc;

-- Which continent has the highest death rate 
SELECT continent, MAX(cast(total_deaths as INT)) AS HighestDeathcount
FROM PorfolioProject.dbo.Covid_deaths
--where location like '%king%'
Where continent is not null
GROUP BY continent
ORDER BY HighestDeathcount desc;

-- Which country has the highest death rate

SELECT location, MAX(cast(total_deaths as INT)) AS HighestDeathcount
FROM PorfolioProject.dbo.Covid_deaths
--where location like '%king%'
Where continent is not null
GROUP BY location
ORDER BY HighestDeathcount desc;

--Global numbers
Select sum(new_cases) as TotalCases,sum(cast(new_deaths as INT)) as TotalDeaths, 
sum(cast(new_deaths as INT))/sum((new_cases))*100 as GlobalDeathPercentage

FROM PorfolioProject.dbo.Covid_deaths
--where location like '%king%'
Where continent is not null
--group by date
Order by 1,2;


-- VACCINATIONS
SELECT *
FROM PORFOLIOPROJECT.DBO.COVID_VACCINES
ORDER BY 3,4
;

-- Looking at the total population vs vaccination (Join Covid deaths table to vaccination table)
SELECT *
FROM PORFOLIOPROJECT.DBO.Covid_deaths dea
JOIN PORFOLIOPROJECT.DBO.COVID_VACCINES vac
 ON dea.location=vac.location
 and dea.date=vac.date;

 -- Looking at the total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (partition by dea.location) as RollingPeopleVaccinated
FROM PORFOLIOPROJECT.DBO.Covid_deaths dea
    JOIN PORFOLIOPROJECT.DBO.COVID_VACCINES vac
         ON dea.location=vac.location
            and dea.date=vac.date
Where dea.continent is not null
Order by dea.location,dea.date
;

-- use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PORFOLIOPROJECT.DBO.Covid_deaths dea
    JOIN PORFOLIOPROJECT.DBO.COVID_VACCINES vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp table
drop table if exists #PercentagePopulationVaccinated
Create table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (partition by dea.location) as RollingPeopleVaccinated
FROM PORFOLIOPROJECT.DBO.Covid_deaths dea
    JOIN PORFOLIOPROJECT.DBO.COVID_VACCINES vac
         ON dea.location=vac.location
            and dea.date=vac.date
Where dea.continent is not null
Order by 2,3

SELECT*,(rollingpeoplevaccinated/population)*100
from #PercentagePopulationVaccinated
;

--Creating view to store data for later visulisations 

Create view PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (partition by dea.location) as RollingPeopleVaccinated
FROM PORFOLIOPROJECT.DBO.Covid_deaths dea
    JOIN PORFOLIOPROJECT.DBO.COVID_VACCINES vac
         ON dea.location=vac.location
            and dea.date=vac.date
Where dea.continent is not null
--Order by 2,3
;
select * from PercentagePopulationVaccinated
