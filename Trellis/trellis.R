# setwd("C:\\Users\\oweni\\Downloads\\Zillow price")

library(ggplot2)
library(reshape2)

home_value = read.csv("home_value.csv")
home_value$Price = home_value$Price/1000
rent_value = read.csv("Med_Rent.csv")
data = rbind(home_value,rent_value)

ggplot(data, aes(Room, Price)) +
  geom_point(aes(color = Type ))+
  facet_wrap(~RegionName, ncol=3)+coord_flip()+
  ggtitle("Comparison of Home Value and Lease")
