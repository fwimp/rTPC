#' Estimate the critical thermal maximum of a thermal performance curve
#'
#' @param model nls model object that contains a model of a thermal performance curve
#' @details Critical thermal maximum is calculated by predicting over a temperature range 50 ºC beyond the maximum value in the dataset. The predicted rate value closest to 0 is then extracted. When this is impossible due to the curve formula (i.e the Sharpe-Schoolfield model), the temperature where the rate is 5 percent of the maximum rate is estimated. Predictions are done every 0.001 ºC so the estimate of the critical thermal maximum should be accurate up to 0.001 ºC.
#' @return Numeric estimate of critical thermal maximum (ºC)
#' @concept params
#' @export get_ctmax

get_ctmax <- function(model){

  # capture environment from model - contains data
  x <- model$m$getEnv()

  # get the name of the temperature column
  formula <- stats::as.formula(model$m$formula())
  param_ind <- all.vars(formula[[3]])[! all.vars(formula[[3]]) %in%
                                        names(model$m$getPars())]

  # extract the temperature values
  vals <- x[[param_ind]]

  # new datasets - one for extrapolation and one without
  newdata_extrap <- data.frame(x = seq(min(vals), max(vals) + 50, by = 0.001), stringsAsFactors = FALSE)
  newdata <- data.frame(x = seq(min(vals), max(vals), by = 1), stringsAsFactors = FALSE)

  # rename to be the correct column name
  names(newdata) <- param_ind
  names(newdata_extrap) <- param_ind

  # predict over a whole wide range of data - both extrap and non-extrap
  newdata$preds <- stats::predict(model, newdata = newdata)
  newdata_extrap$preds <- stats::predict(model, newdata = newdata_extrap)

  # remove NaNs
  newdata_extrap <- newdata_extrap[!is.nan(newdata_extrap$preds),]

  # calc topt and rmax
  topt = newdata[newdata$preds == max(newdata$preds, na.rm = TRUE), param_ind]
  rmax = newdata[newdata$preds == max(newdata$preds),'preds']

  # keep just temperatures lower than topt
  newdata_extrap <- newdata_extrap[newdata_extrap[,param_ind] >= topt,]

  # keep just temperatures where rate is <= 0
  newdata_extrap2 <- newdata_extrap[newdata_extrap$preds <= 0,]

  # maximum value that is closest value to 0 for ctmin
  ctmax <- suppressWarnings(min(newdata_extrap2[,param_ind]))

  # if it is infinite - set it to 5% of rate
  newdata_extrap <- newdata_extrap[newdata_extrap$preds <= 0.05 * rmax,]
  if(is.infinite(ctmax)){ctmax <- min(newdata_extrap[,param_ind], na.rm = TRUE)}

  return(ctmax)
}

