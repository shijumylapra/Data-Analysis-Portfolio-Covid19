select * from CovidPotfolio..CovidDeaths order by 4 asc

select location,date,total_cases,new_cases,total_deaths,population from CovidPotfolio..CovidDeaths 
where continent is not null order by 1,2

select location,date,total_cases,new_cases,total_deaths ,((total_deaths/total_cases)*100)AS 'Death Percentage' from CovidPotfolio..CovidDeaths
where location like '%canada%' and
continent is not null order by 1,2

select location,date,population,total_cases ,((total_cases/population)*100)AS 'Death Percentage' from CovidPotfolio..CovidDeaths
where location like '%canada%'
and continent is not null
order by 1,2

select location,date,population,total_cases ,((total_cases/population)*100)AS 'Death Percentage' from CovidPotfolio..CovidDeaths order by 1,2

select location,population, MAX(total_cases)AS 'Infection Count' ,(max(total_cases/population)*100)AS '% Population Infected' from CovidPotfolio..CovidDeaths 
group by location,population
order by 1,2

select location,population,date,MAX(total_cases)AS 'Infection Count' ,(max(total_cases/population)*100)AS '% Population Infected' from CovidPotfolio..CovidDeaths
group by location,population,date
order by '% Population Infected' Desc

select location, MAX(cast(total_deaths as int)) AS 'Total Death Count' from CovidPotfolio..CovidDeaths where continent is not null
group by location
order by 'Total Death Count' desc

select location, MAX(cast(new_deaths as int)) AS 'Total Death Count' from CovidPotfolio..CovidDeaths where continent is null and
location not in ('World', 'European Union', 'International') 
group by location
order by 'Total Death Count' desc

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount From CovidPotfolio..CovidDeaths
Where continent is null  and location not in ('World', 'European Union', 'International') Group by location
order by TotalDeathCount desc

Select Location, Population, MAX(total_cases) as 'Infection Count',  Max((total_cases/population))*100 as '% Population Infected'
From CovidPotfolio..CovidDeaths  Group by Location, Population order by '% Population Infected' desc



Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidPotfolio..CovidDeaths Group by Location, Population, date
order by PercentPopulationInfected desc

select location, MAX(cast(total_deaths as int)) AS 'Total Death Count' from CovidPotfolio..CovidDeaths where continent is null group by location
order by 'Total Death Count' desc

select continent, MAX(cast(total_deaths as int)) AS 'Total Death Count' from CovidPotfolio..CovidDeaths where continent is not null group by continent
order by 'Total Death Count' desc
 
select date,total_cases,total_deaths ,((total_deaths/total_cases)*100)AS 'Death Percentage' from CovidPotfolio..CovidDeaths 
where continent is not null 
Group by date
order by 1,2

select sum(new_cases) as TotalCases ,SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 AS 'Death Percentage'
from CovidPotfolio..CovidDeaths 
where continent is not null 
--Group by date
order by 1,2





select sum(new_cases) as NewCases ,SUM(cast(new_deaths as int)) as NewDeaths, SUM(new_cases)/SUM(cast(new_deaths as int))*100 AS 'Death Percentage'
from CovidPotfolio..CovidDeaths 
where continent is not null 
order by 1,2

-- Total Population vs Total Vaccination

select CD.continent,CD.location,CD.date,CD.population, CV.new_vaccinations from CovidPotfolio..CovidDeaths CD join CovidPotfolio..CovidVaccinations CV
on CD.location=Cv.location and cd.date=cv.date

select CD.continent,CD.location,CD.date,CD.population, CV.new_vaccinations, SUM(convert(int,CV.new_vaccinations)) OVER
(Partition by CD.location ORDER BY CD.location,CD.date) as VaccinatedpeopleCount
from CovidPotfolio..CovidDeaths CD join CovidPotfolio..CovidVaccinations CV 
on CD.location=Cv.location and cd.date=cv.date where CD.continent is not null order by 2,3

-- With CTE

With PVSV (X_continent,X_location,X_date,X_population,X_new_vaccinations,X_VaccinatedpeopleCount)
as
( select CD.continent,CD.location,CD.date,CD.population, CV.new_vaccinations, SUM(convert(int,CV.new_vaccinations)) OVER
(Partition by CD.location ORDER BY CD.location,CD.date) as VaccinatedpeopleCount
from CovidPotfolio..CovidDeaths CD join CovidPotfolio..CovidVaccinations CV 
on CD.location=Cv.location and cd.date=cv.date where CD.continent is not null --order by 2,3
)
 SELECT *,(X_VaccinatedpeopleCount/X_population)*100 from PVSV;


drop table if exists peopleVaccinated
create table peopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
VaccinatedpeopleCount numeric
)
insert into peopleVaccinated
 select CD.continent,CD.location,CD.date,CD.population, CV.new_vaccinations, SUM(convert(int,CV.new_vaccinations)) OVER
(Partition by CD.location ORDER BY CD.location,CD.date) as VaccinatedpeopleCount
from CovidPotfolio..CovidDeaths CD join CovidPotfolio..CovidVaccinations CV 
on CD.location=Cv.location and cd.date=cv.date where CD.continent is not null --order by 2,3
SELECT *,(VaccinatedpeopleCount/population)*100 from peopleVaccinated;


--Create view to store date for later visualization
create view Percentage_people_vaccinated as
select death.continent,death.location,death.date,death.population, vacci.new_vaccinations, SUM(convert(int,vacci.new_vaccinations)) OVER
(Partition by death.location ORDER BY death.location,death.date) as VaccinatedpeopleCount
from CovidPotfolio..CovidDeaths death join CovidPotfolio..CovidVaccinations vacci 
on death.location=vacci.location and death.date=vacci.date where death.continent is not null --order by 2,3


select * from Percentage_people_vaccinated
