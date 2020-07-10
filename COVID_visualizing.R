library(utils)
library(dplyr)
library(tidyr)
library(lubridate)
library(Hmisc)
library(ggplot2)
library(scales)
##Graph #1 limited country log graph

rdata <- read.csv("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv", na.strings = "", fileEncoding = "UTF-8-BOM")
rdata[[1]] <- as.Date(rdata[[1]], "%d/%m/%Y")
##
rdata <- select(rdata, dateRep, countriesAndTerritories, cases, popData2019)
rdata <- rdata %>% drop_na(dateRep)
rdata <- rdata %>% arrange(countriesAndTerritories,dateRep)
##
rdata <- rdata %>% group_by(countriesAndTerritories) %>% mutate(cum_cases = cumsum(cases))
head(rdata %>% filter(countriesAndTerritories == "China"))
rdata <- ungroup(rdata)
rdata[2] <- lapply(rdata[2], as.character)
rdata[4] <- lapply(rdata[4], as.numeric)
rdata$casesPerMillion <- with(rdata, cum_cases / (popData2019 / 1000000))
##
datag <- rdata %>% group_by(dateRep)
datag <- datag %>% summarise(cases = sum(cases), cum_cases = sum(cum_cases))
datag$popData2019 <- 7669215953
datag$countriesAndTerritories <- 'World'
datag$casesPerMillion <- with(datag, cum_cases / (popData2019 / 1000000))
datag <- datag[names(data)]
##
dtogether <- bind_rows(datag, rdata)
write.csv(dtogether,"D:\\Git\\COVID-Analysis\\dtogether.csv", col.names = TRUE)
##
dtogether <- dtogether %>% filter(dateRep >= "2020-01-22" & dateRep <= "2020-07-06")
##
countrylist <- c('United_States_of_America', 'United_Kingdom', 'South_Korea', 'China', 'World')
dtogether <- dtogether %>% filter(countriesAndTerritories %in% countrylist)
head(dtogether)
##
theme_set(theme_minimal())
ggplot(data=dtogether, aes(x=dateRep, y=casesPerMillion)) +
  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x))) +
  geom_line(aes(color = countriesAndTerritories)) #, linetype = countriesAndTerritories))
##

################################
################################
##Graph #2 world heatmap

library(ggplot2)
library(maps)
library(ggthemes)
library(sf)
library(spData)

lastday = max(rdata$dateRep)
rdata <- rdata %>% filter(dateRep == lastday)
head(rdata)

# Exported datasets and added iso_a2 to associate countries with dataset
# write.csv(rdata,"D:\\Git\\COVID-Analysis\\rdata.csv")
# write.csv(world,"D:\\Git\\COVID-Analysis\\world.csv", col.names = TRUE)

country_data <- read.csv("D:\\Git\\COVID-Analysis\\rdata.csv")
total <- merge(country_data,world,by=c("iso_a2"))

worldmap <- ggplot(data = total) +
  theme_map() +
  coord_cartesian(ylim = c(-50, 90)) + 
  geom_sf(aes(fill = casesPerMillion, geometry = geom)) +
  scale_fill_viridis_c(option = "plasma", trans = "sqrt")
  
worldmap
