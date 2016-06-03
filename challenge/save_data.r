#' ---
#' title: Qucit challenge: save data
#' author: Adrien Todeschini
#' date: May, 2016
#' ---

require(dplyr)
require(lubridate)

#' # read data
datapath = "/media/data/data/qucit"

#' ## bikeshare stations
stations <- tbl_df(read.csv(file.path(datapath, "bordeaux_bikeshare_stations.csv"), 
                            sep=";", stringsAsFactors=FALSE))
# remove useless var
stations <- stations %>% 
  select(-banking, -movable)
# insert NA
ok <- nchar(stations$extra) == 0
stations$extra[ok] <- NA
stations <- stations %>% mutate(extra = as.factor(extra))

#' ## weather
weather <- tbl_df(read.csv(file.path(datapath, "bordeaux_weather.csv"), 
                           sep=";", stringsAsFactors=FALSE))
# recode vars and sort lines
weather <- weather %>% 
  mutate(tms_gmt = as.POSIXct(tms_gmt)) %>%
  mutate(weather_type = as.factor(weather_type)) %>% 
  arrange(tms_gmt)

#' ## bikeshare occupations
occup <- tbl_df(read.csv(file.path(datapath, "bordeaux_bikeshare_occupations.csv"), 
                         sep=";", stringsAsFactors=FALSE))

# clean corrupted times
ind = which(occup$tms_gmt=="22014-03-10 17:30:00")
occup$tms_gmt[ind] = "2014-03-10 17:30:00"
ind = which(occup$tms_gmt == "0014-03-10 17:30:00")
occup$tms_gmt[ind] = "2014-03-10 17:30:00"

occup <- occup %>% 
  mutate(tms_gmt = as.POSIXct(tms_gmt)) %>% 
  mutate(minute = minute(tms_gmt)) %>% 
  dplyr::filter(minute == 0) %>% # keep only HH:00 times
  select(-minute) %>% 
  dplyr::filter(status != 9) %>% 
  mutate(status = as.factor(status)) %>%
  distinct() %>% 
  mutate(month = month(tms_gmt)) %>% 
  mutate(wday = wday(tms_gmt)) %>% 
  mutate(hour = hour(tms_gmt)) %>% 
  group_by(sid) %>% 
  arrange(tms_gmt) %>% 
  mutate(incr = c(diff(bikes), NA)) %>% # bikes increment at t+1h (diff with next line)
  filter(c(diff(tms_gmt), 0) == 3600) # keep lines with 1h difftime with next line

ok <- nchar(occup$last_update) == 0
occup$last_update[ok] <- NA

# keep stations in occup
stations = stations %>% 
  dplyr::filter(sid %in% unique(occup$sid))

#' # save data
save(stations, weather, occup, file="qucit-challenge.rda")






