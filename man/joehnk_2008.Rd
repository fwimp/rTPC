% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/joehnk_2008.R
\name{joehnk_2008}
\alias{joehnk_2008}
\title{Jöhnk model for fitting thermal performance curves}
\usage{
joehnk_2008(temp, rmax, topt, a, b, c)
}
\arguments{
\item{temp}{temperature in degrees centigrade}

\item{rmax}{the rate at optimum temperature}

\item{topt}{optimum temperatute (ºC)}

\item{a}{parameter with no biological meaning}

\item{b}{parameter with no biological meaning}

\item{c}{parameter with no biological meaning}
}
\value{
a numeric vector of rate values based on the temperatures and parameter values provided to the function
}
\description{
Jöhnk model for fitting thermal performance curves
}
\details{
Equation:
\deqn{rate=r_{max} \bigg(1 + a \bigg(\bigg(b^{temp-t_{opt}} -1\bigg) - \frac{ln(b)}{ln(c)}(c^{temp-t_{opt}} -1)\bigg)\bigg)}{%
rate = rmax.(1 + a.((b^(temp - topt) - 1) - (log(b)/log(c)).(c^(temp - topt) - 1)))}

Start values in \code{get_start_vals} are derived from the data or sensible values from the literature.

Limits in \code{get_lower_lims} and \code{get_upper_lims} are based on extreme values that are unlikely to occur in ecological settings.
}
\note{
Generally we found this model easy to fit.
}
\examples{
# load in ggplot
library(ggplot2)

# subset for the first TPC curve
data('chlorella_tpc')
d <- subset(chlorella_tpc, curve_id == 1)

# get start values and fit model
start_vals <- get_start_vals(d$temp, d$rate, model_name = 'joehnk_2008')
# fit model
mod <- nls.multstart::nls_multstart(rate~joehnk_2008(temp = temp, rmax, topt, a, b, c),
data = d,
iter = c(3,3,3,3,3),
start_lower = start_vals - 10,
start_upper = start_vals + 10,
lower = get_lower_lims(d$temp, d$rate, model_name = 'joehnk_2008'),
upper = get_upper_lims(d$temp, d$rate, model_name = 'joehnk_2008'),
supp_errors = 'Y',
convergence_count = FALSE)

# look at model fit
summary(mod)

# get predictions
preds <- data.frame(temp = seq(min(d$temp), max(d$temp), length.out = 100))
preds <- broom::augment(mod, newdata = preds)

# plot
ggplot(preds) +
geom_point(aes(temp, rate), d) +
geom_line(aes(temp, .fitted), col = 'blue') +
theme_bw()

}
\references{
Joehnk, Klaus D., et al. Summer heatwaves promote blooms of harmful cyanobacteria. Global change biology 14.3: 495-512 (2008)
}
\concept{model}
