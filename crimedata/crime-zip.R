setwd("C:/Users/oweni/OneDrive/Documents/GitHub/EDAV_proj3/crimedata")

#################################################
library(maptools)
zip.map <- readShapeSpatial("maps/tl_2010_36_zcta510.shp")
zips = read.csv("zip_map.csv")
# select the zip codes in NYC
ny.zip = zip.map[zip.map@data$ZCTA5CE10 %in% zips$ZIP.CODE,]

# convert crime cord to sp data
crime_df <- structure(list(longitude = crime$Long, latitude = crime$Lat),
                           .Names = c("longitude","latitude"), class = "data.frame",row.names =c(NA,-74098L))
xy <- crime_df[,c(1,2)]
crime_sp <- SpatialPointsDataFrame(coords = xy, data = crime_df,
                               proj4string = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"))

proj4string(ny.zip) = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")
proj4string(ny.zip)
# [1] " +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"
proj4string(crime_sp)
# [1] " +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"

plot(ny.zip)
plot(crime_sp, col="red" , add=TRUE)
res = over(ny.zip, crime_sp)


require(GISTools)
counts = poly.counts(crime_sp,ny.zip)


library("ggmap")
res$zip = 0

for(i in 1:dim(res)[1]){
  if(!is.na(res[i,1])){
    re = revgeocode(c(res$longitude[i],res$latitude[i]), output="more")
    res[i,]$zip = as.numeric(as.character(re$postal_code))
  }
}


# count = counts
for(i in 1:length(counts)){
  names(counts)[i] = res[names(counts)[i],]$zip
}

df = data.frame(zip = names(counts), cnt = counts)

write.csv(df,"crime counts.csv",row.names = F)

####################################
# transportation

metro = read.csv("metro_data.csv")

# convert metro cord to sp data
metro_df <- structure(list(longitude = metro$long, latitude = metro$lat),
                      .Names = c("longitude","latitude"), class = "data.frame",row.names =c(NA,-1904L))
xy <- metro_df[,c(1,2)]
metro_sp <- SpatialPointsDataFrame(coords = xy, data = metro_df,
                                   proj4string = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"))



plot(ny.zip)
plot(metro_sp, col="red" , add=TRUE)
res = over(ny.zip, metro_sp)

for(i in 1:dim(res)[1]){
  if(!is.na(res[i,1])){
    re = revgeocode(c(res$longitude[i],res$latitude[i]), output="more")
    res[i,]$zip = as.numeric(as.character(re$postal_code))
  }
}

counts = poly.counts(metro_sp,ny.zip)
# count = counts
for(i in 1:length(counts)){
  names(counts)[i] = res[names(counts)[i],]$zip
}

df = data.frame(zip = names(counts), cnt = counts)
df = df[df$cnt>0,]

write.csv(df,"metro counts.csv",row.names = F)

###################################
