\name{compressive_properties5}
\alias{compressive_properties5}

\title{Estimation of compressive properties by O'Sullivan et al. (1999)}

\description{
It calculates the compressive parameteres N, lambda and kappa using the pedo-transfer function from O'Sullivan et al. (1999)
}

\usage{ 
compressive_properties5(water.content, soil=c("SandyLoam","ClayLoam"))
}

\arguments{
  \item{water.content}{ a numeric vector containing the values of gravimetric water content, \eqn{\%}} 
  \item{soil}{the the soil texture group 'SandyLoam' or 'ClayLoam'. See exemples.}
}

\value{
  \item{N}{the specific volume at \eqn{p = 1 kPa}, N}
  \item{CI}{the compression index, lambda}
  \item{k}{the recompression index, kappa}
}

\details{
See O'Sullivan et al. (1999).
}

\references{
O'sullivan, M. F., Henshall, J. K., Dickson, J. W., 1999.
A simplified method for estimating soil compaction. 
\emph{Soil and Tillage Research}, 49:325-335.

}
\author{ 
Renato Paiva de Lima <renato_agro_@hotmail.com>
Anderson Rodrigo da Silva <anderson.agro@hotmail.com> 
}
\seealso{
\code{\link{stressTraffic}}
}

\examples{
# EXAMPLE 1
water.content <- 15
compressive_properties5(water.content=water.content, soil="SandyLoam") 
compressive_properties5(water.content=water.content, soil="ClayLoam") 


# EXAMPLE 2 - SandyLoam

water.content <- seq(from=5,to=20,len=20)
out <- compressive_properties5(water.content=water.content, soil="SandyLoam") 
plot(x=water.content ,y=out$N, 
     ylab="N", xlab="Bulk density") # plot for N
plot(x=water.content ,y=out$lambda, 
    ylab="lambda", xlab="Bulk density") # plot for lambda
plot(x=water.content ,y=out$kappa, 
    ylab="kappa", xlab="Bulk density") # plot for kappa


# EXAMPLE 3 - ClayLoam 

water.content <- seq(from=10,to=25,len=20)
out <- compressive_properties5(water.content=water.content, soil="ClayLoam") 
plot(x=water.content ,y=out$N, 
     ylab="N", xlab="Bulk density") # plot for N
plot(x=water.content ,y=out$lambda, 
     ylab="lambda", xlab="Bulk density") # plot for lambda
plot(x=water.content ,y=out$kappa, 
     ylab="kappa", xlab="Bulk density") # plot for rkappa

# End (not run)
}
