% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/compute_dmod.R
\name{.integrate_dmod}
\alias{.integrate_dmod}
\title{Integration function for computing parametric signed or unsigned \eqn{d_{Mod}}{d_Mod} effect sizes
for a single focal group}
\usage{
.integrate_dmod(
  referent_int,
  referent_slope,
  focal_int,
  focal_slope,
  focal_mean_x,
  focal_sd_x,
  referent_sd_y,
  focal_min_x,
  focal_max_x,
  signed = TRUE
)
}
\arguments{
\item{referent_int}{Referent group's intercept.}

\item{referent_slope}{Referent group's slope.}

\item{focal_int}{Focal group's intercept.}

\item{focal_slope}{Focal group's slope.}

\item{focal_mean_x}{Focal group's predictor-score mean.}

\item{focal_sd_x}{Focal group's predictor-score standard deviation.}

\item{referent_sd_y}{Referent group's criterion standard deviation.}

\item{focal_min_x}{Focal group's minimum predictor score.}

\item{focal_max_x}{Focal group's maximum predictor score.}

\item{signed}{Logical argument that indicates whether the function should compute \eqn{d_{Mod_{Signed}}}{d_Mod_Signed} (\code{TRUE}; default) or \eqn{d_{Mod_{Unsigned}}}{d_Mod_Unsigned} (\code{FALSE}).}
}
\value{
A \eqn{d_{Mod_{Signed}}}{d_Mod_Signed} or \eqn{d_{Mod_{Unsigned}}}{d_Mod_Unsigned} effect size, depending on the \code{signed} argument.
}
\description{
This internal function exists to support the \code{\link[=compute_dmod_par]{compute_dmod_par()}} function, but may also be useful as a bare-bones tool for computing signed and unsigned \eqn{d_{Mod}}{d_Mod} effect sizes.
Please note that this function does not include an option for re-scaling its result to compensate for cumulative densities smaller than 1.
}
\details{
The \eqn{d_{Mod_{Signed}}}{d_Mod_Signed} effect size (i.e., the average of differences in prediction over
the range of predictor scores) is computed as
\deqn{d_{Mod_{Signed}}=\frac{1}{SD_{Y_{1}}}\intop f_{2}(X)\left[X\left(b_{1_{1}}-b_{1_{2}}\right)+b_{0_{1}}-b_{0_{2}}\right] dX}{d_Mod_Signed = 1/SD_Y_1 * integrate(f_2(X) * [X * (b_1_1 - b_1_2) + b_0_1 - b_0_2])},
where
\itemize{
\item {\eqn{SD_{Y_{1}}}{SD_Y_1} is the referent group's criterion standard deviation;}
\item {\eqn{f_{2}(X)}{f_2(X)} is the normal-density function for the distribution of focal-group predictor scores;}
\item {\eqn{b_{1_{1}}}{b_1_1} and \eqn{b_{1_{2}}}{b_1_2} are the slopes of the regression of \eqn{Y}{Y} on \eqn{X}{X} for the referent and focal groups, respectively;}
\item {\eqn{b_{0_{1}}}{b_0_1} and \eqn{b_{0_{2}}}{b_0_2} are the intercepts of the regression of \eqn{Y}{Y} on \eqn{X}{X} for the referent and focal groups, respectively; and}
\item {the integral spans all \eqn{X} scores within the operational range of predictor scores for the focal group.}
}

The \eqn{d_{Mod_{Unsigned}}}{d_Mod_Unsigned} effect size (i.e., the average of absolute differences in prediction over
the range of predictor scores) is computed as
\deqn{d_{Mod_{Unsigned}}=\frac{1}{SD_{Y_{1}}}\intop f_{2}(X)\left|X\left(b_{1_{1}}-b_{1_{2}}\right)+b_{0_{1}}-b_{0_{2}}\right|dX.}{d_Mod_Unsigned = 1/SD_Y_1 * integrate(f_2(X) * |X * (b_1_1 - b_1_2) + b_0_1 - b_0_2|).}
}
\examples{
\dontrun{
# Example for computing \eqn{d_{Mod_{Signed}}}{d_Mod_Signed}
.integrate_dmod(referent_int = -.05, referent_slope = .5,
              focal_int = -.05, focal_slope = .3,
              focal_mean_x = -.5, focal_sd_x = 1,
              referent_sd_y = 1, focal_min_x = -Inf, focal_max_x = Inf,
              signed = TRUE)

# Example for computing \eqn{d_{Mod_{Unsigned}}}{d_Mod_Unsigned}
.integrate_dmod(referent_int = -.05, referent_slope = .5,
              focal_int = -.05, focal_slope = .3,
              focal_mean_x = -.5, focal_sd_x = 1,
              referent_sd_y = 1, focal_min_x = -Inf, focal_max_x = Inf,
              signed = FALSE)
}
}
\references{
Nye, C. D., & Sackett, P. R. (2017).
New effect sizes for tests of categorical moderation and differential prediction.
\emph{Organizational Research Methods, 20}(4), 639–664. \doi{10.1177/1094428116644505}
}
\keyword{internal}
