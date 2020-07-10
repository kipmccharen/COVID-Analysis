library(utils)
library(dplyr)
library(tidyr)
library(lubridate)
library(Hmisc)
library(ggplot2)
library(scales)
##Graph #1 limited country log graph

rdata <- read.csv("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv", na.strings = "", fileEncoding = "UTF-8-BOM") #load online source
rdata[[1]] <- as.Date(rdata[[1]], "%d/%m/%Y") # convert raw date to actual date value
#%%
rdata <- select(rdata, dateRep, countriesAndTerritories, cases, popData2019) # limit columns
rdata <- rdata[!is.na(rdata$dateRep), ] #drop where no date 
rdata <- rdata %>% arrange(countriesAndTerritories,dateRep) #sort by date
#%%
datag <- rdata %>% group_by(dateRep) %>% summarise(cases = sum(cases)) #created new df grouping by date, sum for whole world
datag$popData2019 <- 7669215953 #add world population value
datag$countriesAndTerritories <- 'World' #give name "world"
datag <- datag[names(datag)] #reorder to match first dataset
#%%
dtogether <- bind_rows(datag, rdata) #combine country data and world data
#%%
dtogether <- dtogether %>% group_by(countriesAndTerritories) %>% mutate(cum_cases = cumsum(cases)) #group by country and accumulate case sum
dtogether <- ungroup(dtogether) #ungroup
dtogether$casesPerMillion <- dtogether$cum_cases / (dtogether$popData2019 / 1000000) #calculate cases per million pop
#%%
df_viz_limit <- dtogether %>% filter(dateRep >= "2020-01-22") # & dateRep <= "2020-07-06")
countrylist <- c('United_States_of_America', 'United_Kingdom', 'South_Korea', 'China', 'World')
df_viz_limit <- df_viz_limit %>% filter(countriesAndTerritories %in% countrylist)
head(dtogether)
#%%
theme_set(theme_minimal())
ggplot(data=df_viz_limit, aes(x=dateRep, y=casesPerMillion)) +
  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x))) +
  geom_line(aes(color = countriesAndTerritories)) #, linetype = countriesAndTerritories))
#%%

################################
################################
##Graph #2 world heatmap

library(ggplot2)
library(maps)
library(ggthemes)
library(sf)
library(spData)

## Reduced existing dataset to latest date
lastday = max(dtogether$dateRep)
dtogether <- dtogether %>% filter(dateRep == lastday)
#head(rdata)

## Exported datasets and added iso_a2 to associate countries with dataset
# write.csv(rdata,"D:\\Git\\COVID-Analysis\\rdata.csv")
# write.csv(world,"D:\\Git\\COVID-Analysis\\world.csv", col.names = TRUE)

country_matching <- read.csv("D:\\Git\\COVID-Analysis\\rdata.csv", stringsAsFactors = FALSE)
country_matching <- select(country_matching, countriesAndTerritories, iso_a2)
country_matching$iso_a2[country_matching$countriesAndTerritories=='Namibia'] <- 'NA'

total <- merge(country_matching,world,by=c("iso_a2"))
total <- merge(total,dtogether,by=c("countriesAndTerritories"))

worldmap <- ggplot(data = total) +
  theme_map() +
  coord_cartesian(ylim = c(-50, 90)) + 
  geom_sf(aes(fill = casesPerMillion, geometry = geom)) +
  scale_fill_viridis_c(option = "plasma", trans = "sqrt")
  
worldmap
