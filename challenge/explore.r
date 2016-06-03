require(ggplot2)
id = 2

oc = occup %>% dplyr::filter(sid==id)
qplot(tms_gmt, incr, data=oc)
qplot(incr, data=oc, facets = wday ~ hour)
qplot(hour, incr, data=oc %>% mutate(hour=as.factor(hour)), facets = wday ~ month, geom = "boxplot")
