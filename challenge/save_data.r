
require(dplyr)
require(lubridate)

# Read data
stations <- tbl_df(read.csv("bordeaux_bikeshare_stations.csv", sep=";", stringsAsFactors=FALSE))
stations <- stations %>% 
  select(-banking, -movable)
ok <- nchar(stations$extra) == 0
stations$extra[ok] <- NA
stations <- stations %>% mutate(extra = as.factor(extra))

weather <- tbl_df(read.csv("bordeaux_weather.csv", sep=";", stringsAsFactors=FALSE))
weather <- weather %>% 
  mutate(tms_gmt = as.POSIXct(tms_gmt)) %>%
  mutate(weather_type = as.factor(weather_type)) %>% 
  arrange(tms_gmt)

occup <- tbl_df(read.csv("bordeaux_bikeshare_occupations.csv", sep=";", stringsAsFactors=FALSE))
ind = which(occup$tms_gmt=="22014-03-10 17:30:00")
occup$tms_gmt[ind] = "2014-03-10 17:30:00"
ind = which(occup$tms_gmt == "0014-03-10 17:30:00")
occup$tms_gmt[ind] = "2014-03-10 17:30:00"
occup <- occup %>% 
  mutate(tms_gmt = as.POSIXct(tms_gmt)) %>% 
  mutate(minute = minute(tms_gmt)) %>% 
  dplyr::filter(minute == 0) %>% 
  select(-minute) %>% 
  dplyr::filter(status != 9) %>% 
  mutate(status = as.factor(status)) %>%
  distinct() %>% 
  mutate(month = month(tms_gmt)) %>% 
  mutate(wday = wday(tms_gmt)) %>% 
  mutate(hour = hour(tms_gmt)) %>% 
  group_by(sid) %>% 
  arrange(tms_gmt) %>% 
  mutate(incr = c(diff(bikes), NA)) %>% 
  filter(c(diff(tms_gmt), 0) == 3600)

ok <- nchar(occup$last_update) == 0
occup$last_update[ok] <- NA

stations = stations %>% 
  dplyr::filter(sid %in% unique(occup$sid))

save(stations, weather, occup, file="qucit-challenge.rda")






