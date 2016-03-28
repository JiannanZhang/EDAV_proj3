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
city_data = read.csv("NYC_data.csv")
city_data = city_data[city_data$population>0,]


met33 = quantile(city_data$metro,probs = 0.33)
met67 = quantile(city_data$metro,probs = 0.67)

city_data$metro_convenience = "inconvenient"
city_data$metro_convenience[city_data$metro>=met67] = "convenient"
city_data$metro_convenience[city_data$metro<met67 & city_data$metro>=met33] = "intermediate"

crime33 = quantile(city_data$crime_rate,probs = 0.33)
crime67 = quantile(city_data$crime_rate,probs = 0.67)

city_data$security = "unsafe"
city_data$security[city_data$crime_rate>=crime67] = "safe"
city_data$security[city_data$crime_rate<crime67 & city_data$crime_rate>=crime33] = "intermediate"

complain = read.csv("complain data(1,4,7,10).csv")

library(dplyr)
group_comp = group_by(complain,zip)
complain_zip = summarize(group_comp,complain = n())
names(complain_zip)[1] = "zip_code"
city_data = left_join(city_data,complain_zip, by = "zip_code")
city_data$Borough = as.character(city_data$Borough)
# default values
max_complain = max(city_data$complain)
min_complain = 0

max_pop = max(city_data$population)
min_pop = 0

transportation = c("convenient","inconvenient","intermediate")

safety = c("safe","unsafe","intermediate")

borough = c("Manhattan","Staten Island", "Bronx","Queens","Brooklyn")

max_price = max(city_data$price)
min_price = -1

plot_data = subset(city_data,population>=min_pop & population<=max_pop &
                           complain>=min_complain & complain<=max_complain &
                           metro_convenience %in% transportation &
                           security %in%  safety & Borough %in% borough)

# find the center of the plot
zip_mapping = read.csv("zip_mapping.csv")

if(dim(plot_data)[1]>0){
        zip = data.frame(zip_code = plot_data$zip_code)
        zip = left_join(zip , zip_mapping , by = "zip_code")
        center = c(mean(zip$long),mean(zip$lat))
}

################################
zip.map <- readShapeSpatial("tl_2010_36_zcta510.shp")
## this is the variable we will be plotting
zip.map@data$noise <- rnorm(nrow(zip.map@data))
## put the lab point x y locations of the zip codes in the data frame for easy retrieval
labelpos <- data.frame(do.call(rbind, lapply(zip.map@polygons, function(x) x@labpt)))
names(labelpos) <- c("x","y")                        
zip.map@data <- data.frame(zip.map@data, labelpos)

#shapefile <- readShapeSpatial('tr48_d00.shp',
#                              proj4string = CRS("+proj=longlat +datum=WGS84"))
# convert to a data.frame for use with ggplot2/ggmap and plot

data <- fortify(zip.map)


