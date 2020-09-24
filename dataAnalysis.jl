using Plots, DataFrames, JSON3, CSV, Dates

url = "https://data.cdc.gov/resource/r8kw-7aab.csv"
download(url, "covid.csv")
covidData = CSV.read("covid.csv", missingstring="NA", delim=",", decimal='.', copycols=true)
covidData = dropmissing(covidData)[:, ["end_week", "state", "covid_deaths", "pneumonia_deaths", "influenza_deaths", "pneumonia_influenza_or_covid_19_deaths", "total_deaths"]]
names(covidData)
dateFormat = Dates.DateFormat("d U")
covidData.day = Dates.format.(covidData.end_week, "d")
covidData.month = Dates.format.(covidData.end_week, "U")
for column in ["covid_deaths", "pneumonia_deaths", "influenza_deaths", "pneumonia_influenza_or_covid_19_deaths", "total_deaths"]
    print(column)
    covidData[column] = [tryparse(Int,x) for x in  covidData[:, column]]
end
deathsByStateOverTime = covidData[covidData.state .== "California", :] |> 
x -> select(x, :month, :covid_deaths, :pneumonia_deaths, :influenza_deaths, :total_deaths ) |>
data -> filter(:x => x -> !(ismissing(x) || isnothing(x) || isnan(x)), data) |>
x -> aggregate(x, :month, sum) 