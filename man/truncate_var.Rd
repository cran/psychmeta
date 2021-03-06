% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/truncate.R
\name{truncate_var}
\alias{truncate_var}
\title{Truncation function for variances}
\usage{
truncate_var(a = -Inf, b = Inf, mean = 0, sd = 1)
}
\arguments{
\item{a}{Quantile (i.e., cut score) below which scores should be censored from the distribution.}

\item{b}{Quantile (i.e., cut score) above which scores should be censored from the distribution.}

\item{mean}{Scalar mean or vector of means.}

\item{sd}{Scalar standard deviation or vector of standard deviations.}
}
\value{
A vector of truncated variances
}
\description{
This function computes the variance of a normal distributions that has been truncated at one or both ends.
}
\examples{
truncate_var(a = -1, b = 3, mean = 0, sd = 1)
truncate_var(a = 1, b = Inf, mean = 0, sd = 1)
truncate_var(a = c(-1, 1), b = c(3, Inf), mean = 0, sd = 1)
}
\keyword{univar}
