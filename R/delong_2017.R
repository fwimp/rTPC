#' DeLong enzyme-assisted Arrhenius model for fitting thermal performance curves
#'
#' @param temp temperature in degrees centigrade
#' @param c potential reaction rate
#' @param eb baseline energy needed for the reaction to occur (eV)
#' @param ef temperature dependence of folding the enzymes used in the metabolic reaction, relative to the melting temperature (eV)
#' @param tm melting temperature in degrees centigrade
#' @param ehc temperature dependence of the heat capacity between the folded and unfolded state of the enzymes, relative to the melting temperature (eV)
#' @return a numeric vector of rate values based on the temperatures and parameter values provided to the function
#' @references DeLong, John P., et al. The combined effects of reactant kinetics and enzyme stability explain the temperature dependence of metabolic rates. Ecology and evolution 7.11 (2017): 3940-3950.
#' @details Equation:
#' \deqn{rate = c \cdot exp\frac{-(e_b-(e_f(1-\frac{temp + 273.15}{t_m})+e_{hc} \cdot ((temp + 273.15) - t_m - (temp + 273.15) \cdot ln(\frac{temp + 273.15}{t_m}))))}{k \cdot (temp + 273.15)}}{%
#' rate = c.exp(-(eb-(ef.(1-((temp + 273.15)/tm))+ehc.((temp + 273.15)-tm-((temp + 273.15).log((temp + 273.15)/tm)))))/(k.(temp + 273.15)))}
#'
#' where \code{k} is Boltzmann's constant with a value of 8.62e-05 and \code{tm} is actually \code{tm - 273.15}
#'
#' Start values in \code{get_start_vals} are derived from the data or sensible values from the literature.
#'
#' Limits in \code{get_lower_lims} and \code{get_upper_lims} are derived from the data or based extreme values that are unlikely to occur in ecological settings.
#'
#' @note Generally we found this model easy to fit.
#' @concept model
#' @examples
#' # load in ggplot
#' library(ggplot2)
#'
#' # subset for the first TPC curve
#' data('chlorella_tpc')
#' d <- subset(chlorella_tpc, curve_id == 1)
#'
#' # get start values and fit model
#' start_vals <- get_start_vals(d$temp, d$rate, model_name = 'delong_2017')
#' # fit model
#' mod <- nls.multstart::nls_multstart(rate~delong_2017(temp = temp, c, eb, ef, tm,ehc),
#' data = d,
#' iter = c(4,4,4,4,4),
#' start_lower = start_vals - 10,
#' start_upper = start_vals + 10,
#' lower = get_lower_lims(d$temp, d$rate, model_name = 'delong_2017'),
#' upper = get_upper_lims(d$temp, d$rate, model_name = 'delong_2017'),
#' supp_errors = 'Y',
#' convergence_count = FALSE)
#'
#' # look at model fit
#' summary(mod)
#'
#' # get predictions
#' preds <- data.frame(temp = seq(min(d$temp), max(d$temp), length.out = 100))
#' preds <- broom::augment(mod, newdata = preds)
#'
#' # plot
#' ggplot(preds) +
#' geom_point(aes(temp, rate), d) +
#' geom_line(aes(temp, .fitted), col = 'blue') +
#' theme_bw()
#' @export delong_2017

delong_2017 <- function(temp, c, eb, ef, tm, ehc){
    k <- 8.62e-05

    return( c*exp(-(eb-(ef*(1-((temp + 273.15)/(tm + 273.15)))+ehc*((temp + 273.15)-(tm + 273.15)-((temp + 273.15)*log((temp + 273.15)/(tm + 273.15))))))/(k*(temp + 273.15))))
  }

delong_2017.starting_vals <- function(d){
  # split data into post topt and pre topt
  post_topt <- d[d$x >= mean(d[d$y == max(d$y, na.rm = TRUE),'x']),]
  pre_topt <- d[d$x <= mean(d[d$y == max(d$y, na.rm = TRUE),'x']),]

  c =  14.45
  eb = 0.58
  ef = 2.215

  # if post topt is only 2 rows, then add another point in the middle just for getting a start value
  if(nrow(post_topt) == 2){
    post_topt <- rbind(post_topt, c(mean(post_topt$x), mean(post_topt$y)))
  }

  fit <- suppressWarnings(stats::lm(log(y) ~ x+I(x^2), post_topt))
  roots <- suppressWarnings(polyroot(stats::coef(fit)))
  tm = suppressWarnings(as.numeric(max(Re(roots))))
  ehc = 0.085

  return(c(c = c, eb = eb, ef = ef, tm = tm, ehc = ehc))
}

delong_2017.lower_lims <- function(d){
  c =  0
  eb = 0
  ef = 0
  tm = 0
  ehc = 0

  return(c(c = c, eb = eb, ef = ef, tm = tm, ehc = ehc))
}

delong_2017.upper_lims <- function(d){
  c =  14.45 * 500
  eb = 0.58 * 100
  ef = 2.215 * 100
  ehc = 0.085 * 100
  tm = max(d$x, na.rm = TRUE) * 100

  return(c(c = c, eb = eb, ef = ef, tm = tm, ehc = ehc))
}
