library(utils)
library(dplyr)
library(tidyr)
library(lubridate)
library(Hmisc)
##
data <- read.csv("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv", na.strings = "", fileEncoding = "UTF-8-BOM")
data[[1]] <- as.Date(data[[1]], "%d/%m/%Y")
##
data <- select(data, dateRep, countriesAndTerritories, cases, popData2019)
data <- data %>% drop_na(dateRep)
data <- data %>% filter(dateRep >= "2020-01-22" & dateRep <= "2020-07-01")
##
data <- data %>% arrange(countriesAndTerritories,dateRep)
data <- data %>% group_by(countriesAndTerritories) %>% mutate(cum_cases = cumsum(cases))
head(data %>% filter(countriesAndTerritories == "China"))
##
datag <- data %>% group_by(dateRep)
datag <- datag %>% summarise(cases = sum(cases), cum_cases = sum(cum_cases))
datag$popData2019 <- 7669215953
datag$countriesAndTerritories <- 'World'
datag <- datag[names(data)]
describe(datag)
# describe(data)
#
dtogether <- bind_rows(datag, data)
head(dtogether)
##
dtogether$casesPerMillion <- with(dtogether, cum_cases / (popData2019 / 1000000))
countrylist <- c('United_States_of_America', 'United_Kingdom', 'South_Korea', 'China', 'World')
dtogether <- dtogether %>% filter(countriesAndTerritories %in% countrylist)
head(dtogether)
##
library(ggplot2)
library(scales)

theme_set(theme_minimal())
ggplot(data=dtogether, aes(x=dateRep, y=casesPerMillion)) +
  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x))) +
  geom_line(aes(color = countriesAndTerritories)) #, linetype = countriesAndTerritories))



