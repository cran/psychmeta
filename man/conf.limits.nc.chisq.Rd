% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/heterogeneity.R
\name{conf.limits.nc.chisq}
\alias{conf.limits.nc.chisq}
\title{Confidence limits for noncentral chi square parameters (function and documentation from package 'MBESS' version 4.4.3)
Function to determine the noncentral parameter that leads to the observed \code{Chi.Square}-value,
so that a confidence interval for the population noncentral chi-square value can be formed.}
\usage{
conf.limits.nc.chisq(
  Chi.Square = NULL,
  conf.level = 0.95,
  df = NULL,
  alpha.lower = NULL,
  alpha.upper = NULL,
  tol = 1e-09,
  Jumping.Prop = 0.1
)
}
\arguments{
\item{Chi.Square}{the observed chi-square value}

\item{conf.level}{the desired degree of confidence for the interval}

\item{df}{the degrees of freedom}

\item{alpha.lower}{Type I error for the lower confidence limit}

\item{alpha.upper}{Type I error for the upper confidence limit}

\item{tol}{tolerance for iterative convergence}

\item{Jumping.Prop}{Value used in the iterative scheme to determine the noncentral parameters necessary for confidence interval construction using noncentral chi square-distributions (\code{0 < Jumping.Prop < 1})}
}
\value{
\itemize{
     \item{\code{Lower.Limit}: Value of the distribution with \code{Lower.Limit} noncentral value that has at its specified quantile \code{Chi.Square}}
     \item{\code{Prob.Less.Lower}: Proportion of cases falling below \code{Lower.Limit}}
     \item{\code{Upper.Limit}: Value of the distribution with \code{Upper.Limit} noncentral value that has at its specified quantile \code{Chi.Square}}
     \item{\code{Prob.Greater.Upper}: Proportion of cases falling above \code{Upper.Limit}}
}
}
\description{
Confidence limits for noncentral chi square parameters (function and documentation from package 'MBESS' version 4.4.3)
Function to determine the noncentral parameter that leads to the observed \code{Chi.Square}-value,
so that a confidence interval for the population noncentral chi-square value can be formed.
}
\details{
If the function fails (or if a function relying upon this function fails), adjust the \code{Jumping.Prop} (to a smaller value).
}
\author{
Ken Kelley (University of Notre Dame; \email{KKelley@ND.edu}), Keke Lai (University of California--Merced)
}
