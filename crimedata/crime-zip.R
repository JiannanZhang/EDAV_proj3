# google API
library("ggmap")

# generate a single example address
lonlat_sample <- as.numeric(geocode("the hollyood bowl"))
lonlat_sample  # note the order is longitude, latitiude

res <- revgeocode(lonlat_sample, output="more")
# can then access zip and neighborhood where populated
res$postal_code
res$neighborhood

crime$zip = 0

sample = crime

for(i in 1:dim(sample)[1]){
  res = revgeocode(c(sample[i,]$Long,sample[i,]$Lat), output="more")
  sample[i,]$zip = as.numeric(as.character(res$postal_code))
}

setwd("C:\\Columbia Courses\\Visualization\\crimedata")

library(maptools)
##substitute your shapefiles here
state.map <- readShapeSpatial("maps/st24_d00.shp")
zip.map <- readShapeSpatial("maps/zt24_d00.shp")
## this is the variable we will be plotting
zip.map@data$noise <- rnorm(nrow(zip.map@data))
## put the lab point x y locations of the zip codes in the data frame for easy retrieval
labelpos <- data.frame(do.call(rbind, lapply(zip.map@polygons, function(x) x@labpt)))
names(labelpos) <- c("x","y")                        
zip.map@data <- data.frame(zip.map@data, labelpos)


# raster
library("raster")

x <- getData('GADM', country='USA', level=1)
class(x)
# [1] "SpatialPolygonsDataFrame"
# attr(,"package")
# [1] "sp"

set.seed(1)
# sample random points
p <- spsample(x, n=300, type="random")
p <- SpatialPointsDataFrame(p, data.frame(id=1:300))

proj4string(x)
# [1] " +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"
proj4string(p)
# [1] " +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"

plot(x)
plot(p, col="red" , add=TRUE)

res <- over(p, x)
table(res$NAME_1)