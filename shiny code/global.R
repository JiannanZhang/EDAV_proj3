library(dplyr)
library(stringr)
library(xts)
library(data.table)
library(plotly)
library(ggplot2)
library(reshape2)
library(choroplethr)
library(choroplethrZip)
library(maptools)
library(ggmap)

####################################### compalin
data_2015_top5 <- read.csv("complain data(1,4,7,10).csv")
data_2015_top5 <- data_2015_top5[ , 2:10]
####################################### Crime
crime <- read.csv("NYPD_7_Major_Felony_Incidents.csv", header = T)
crime <- crime[which(crime$Occurrence.Year == 2015), ]
crime <- na.omit(crime)
crime <- crime[ , c("Occurrence.Date", "Day.of.Week", "Occurrence.Month", "Occurrence.Day", "Occurrence.Year", "Occurrence.Hour", "Offense", "Borough", "XCoordinate", "YCoordinate", "Location.1")]

location <- unlist(strsplit(as.character(crime$Location.1), split=c(", ")))
index1 <- seq(1, length(location), 2)
index2 <- seq(2, length(location), 2)
crime$Lat <- location[index1]
crime$Lat <- unlist(strsplit(crime$Lat, "\\("))[index2]
crime$Long <- location[index2]
crime$Long <- unlist(strsplit(crime$Long, "\\)"))
options(digits=15)
crime$Lat <- as.numeric(crime$Lat)
crime$Long <- as.numeric(crime$Long)

####################################### housing price
home_value = read.csv("home_value.csv")
home_value$Price = home_value$Price/1000
rent_value = read.csv("Med_Rent.csv")
trellis_data = rbind(home_value,rent_value)
trellis_data$Type <- as.character(trellis_data$Type)
trellis_data$RegionName <- as.character(trellis_data$RegionName)

for (i in 1:nrow(trellis_data)) {
        if (trellis_data[i, 2] == "Value") {
                trellis_data[i, 2] <- "Sales"
        }
        
        if (trellis_data[i, 1] == "New York") {
                trellis_data[i, 1] <- "Manhattan"
        }
}


################################### zip map
data(df_pop_zip)
nyc_fips = c(36005, 36047, 36061, 36081, 36085)
popmap <- zip_choropleth(df_pop_zip,
                         county_zoom=nyc_fips,
                         title="2012 New York City ZCTA Population Estimates",
                         legend="Population")
