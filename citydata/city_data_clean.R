setwd("C:/Users/oweni/OneDrive/Documents/GitHub/EDAV_proj3/citydata")
city_data = read.csv("NYC_data.csv")
city_data = city_data[city_data$population>0,]

# library(ggplot2)
# analysis to set thresholds
# ggplot(city_data,aes(x = metro))+geom_histogram(stat = "bin",binwidth=1)+
#   ggtitle("Distribution of Number of Metro stations")

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
