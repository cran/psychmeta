% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/methods_confint.R
\name{confint}
\alias{confint}
\title{Confidence interval method for objects of classes deriving from \code{lm_mat}}
\arguments{
\item{object}{Matrix regression object.}

\item{parm}{a specification of which parameters are to be given confidence intervals, either a vector of numbers or a vector of names. If missing, all parameters are considered.}

\item{level}{Confidence level}

\item{...}{further arguments passed to or from other methods.}
}
\description{
Confidence interval method for objects of classes deriving from \code{lm_mat}
Returns lower and upper bounds of confidence intervals for regression coefficients.
}
