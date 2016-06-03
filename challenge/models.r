library(dplyr)
library(lubridate)
library(glmnet)
library(ggplot2)
library(FactoMineR)
library(foreach)
library(doMC)
library(randomForest)
library(rpart)
library(xgboost)

t_start = Sys.time()

registerDoMC(8)

load("qucit-challenge.rda")

# subsample stations
set.seed(1234)
# sids = sample(unique(occup$sid), 10)
sids = 1
occup = occup %>%
  dplyr::filter(sid %in% sids)


rmse <- function(y_pred, y_test) {
  sqrt(mean((y_pred-y_test)^2))
}

# benchmark static
#=====================
err = rmse(0, occup$incr)
perf = tbl_df(data.frame(model="bench_static", rmse=err, stringsAsFactors = F))


# benchmark mean increment
#===========================
occup = occup %>% 
  ungroup() %>% 
  group_by(sid, wday, hour) %>% 
  mutate(incr_mean = c(0, cummean(incr)[-n()])) %>% 
  ungroup()

y_pred = pmin(pmax(-occup$bikes, round(occup$incr_mean)), occup$free_slots)
err = rmse(y_pred, occup$incr)
perf = rbind(perf, list(model="bench_mean", rmse=err))


# my model
#===============
ind = match(occup$sid, stations$sid)
occup = cbind(occup, stations[ind,c("latitude", "longitude")])
ind = match(occup$tms_gmt, weather$tms_gmt)
occup = cbind(occup, weather[ind, c("temperature", "humidity", "wind", "precipitation")])

# occup = occup %>% 
#   mutate(dist = sqrt((latitude-median(occup$latitude))^2+(longitude-median(occup$longitude))^2)) %>% 
#   select(-latitude, -longitude)

fold = year(occup$tms)*52+week(occup$tms)
fold = fold-min(fold)+1
nfold = max(fold)

y_pred = foreach(id = unique(occup$sid), .combine = 'c') %dopar% {
  
  ok_id = occup$sid == id
  y_pred_id = occup$incr_mean[ok_id]
  ok_train = rep(FALSE, length(ok_id))
  ok_pred = rep(FALSE, length(ok_id))
  
  lambda = NULL
  
  t = Sys.time()
  for (ifold in 1:nfold) {
    
    ok_train[ok_pred] = TRUE
    ok_fold = (fold == ifold & !is.na(occup$temperature))
    ok_pred = ok_id & ok_fold
    ok_pred2 = ok_fold[ok_id]
    
    if (!any(ok_train) || !any(ok_pred2))
      next
    
    dy_train = occup$incr[ok_train] - occup$incr_mean[ok_train]
    
    if (mean(dy_train==0)>.97)
      next

    ivar = which(!names(occup) %in% c("sid", "tms_gmt", "latitude", "longitude", "status", "incr", "incr_mean", 
                                      "last_update"))

    # regularized regression
    if (is.null(lambda) || ifold %% 20 == 2) {
      fit <- cv.glmnet(as.matrix(occup[ok_train, ivar]), dy_train)
      lambda = fit$lambda.1se
      cat ("lamda =", lambda, "\n")
    } else {
      fit <- glmnet(as.matrix(occup[ok_train, ivar]), dy_train)
    }
    dy_pred = predict(fit, newx = as.matrix(occup[ok_pred, ivar]), s = lambda)
    
    # fit = xgboost(as.matrix(occup[ok_train, ivar]), label = dy_train, nrounds=2)
    # dy_pred = predict(fit, as.matrix(occup[ok_pred, ivar]))

    # dy_pred = rep(0, sum(ok_pred2))
    
    y_pred_id[ok_pred2] = y_pred_id[ok_pred2] + dy_pred
    
    dt = Sys.time()-t
    cat("step", ifold, "/", nfold, ", end time:",  format(Sys.time()+dt*(nfold-ifold), "%H:%M"), "\n")
    t = Sys.time()
  }
  y_pred_id
}

y_pred = pmin(pmax(-occup$bikes, round(y_pred)), occup$free_slots)
err = rmse(y_pred, occup$incr)
perf = rbind(perf, list(model="my_model", rmse=err))

qplot(model, rmse, data=perf)

cat("Elapsed time:", format(Sys.time()-t_start), "\n")

