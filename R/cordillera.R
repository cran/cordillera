#' Print method for the OPTICS Cordillera 
#'
#' Prints the raw and normalized OPTICS Cordillera
#' 
#' @param x an object of class optics
#' @param ... additional arguments passed to print
#' 
#' @export
print.cordillera <- function(x,...)
    {
      out <- c(raw=x$raw,normed=x$normed)
      print(out)
    }

#' @export
summary.cordillera <- function(object,...)
    {
      out <- list(raw=object$raw,normed=object$normed,normalization=object$norm,minpts=object$optics$minPts,epsilon=object$optics$eps)
      class(out) <- "summary.cordillera"
      out
    }

#' @export
print.summary.cordillera <- function(x,...)
    {
        cat("\n")
        cat("  OPTICS Cordillera values with minpts=",x$minpts,"and epsilon=",x$epsilon,"\n")
        cat("\n")
        cat("   Raw OC:",x$raw,"\n","  Normalization:",x$normalization,"\n","  Normed OC:",x$normed,"\n")
        cat("\n")
    }

#' Plot method for OPTICS Cordilleras 
#'
#' Plots the reachability plot and adds the cordillera to it (as a line). In this plot the cordillera is proportional to the real value. 
#' 
#' @param x an object of class "cordillera"
#' @param colbp color of the barplot.
#' @param coll color of the cordillera line
#' @param liwd width of the cordillera line
#' @param legend draw legend
#' @param ylim ylim for the barplots
#' @param ... additional arguments passed to barplot or lines
#'
#' @importFrom graphics barplot plot legend par
#' 
#' @export
plot.cordillera <- function(x,colbp="lightgrey",coll="black",liwd=1.5,legend=FALSE,ylim,...)
  {
            tmp <- x$reachplot
            rang <- c(0,min(x$optics$eps,max(tmp[is.finite(tmp)])))
            if(missing(ylim)) ylim <- c(0,max(rang))
            indtmp <- x$optics$order
            bp <- graphics::barplot(tmp,names.arg=indtmp,col=colbp,border=graphics::par("bg"),ylim=ylim,...)
            newpoints <- rep(c(max(tmp),min(tmp)),length.out=length(tmp))
            graphics::lines(x=bp,y=tmp,col=coll,lwd=liwd,...)
            if(legend) graphics::legend("topright",legend="OC",col=coll,lty=1)
     }


#' The OPTICS Cordillera 
#'
#' Calculates the OPTICS Cordillera as described in Rusch et al. (2017). Based on optics in dbscan package.
#'
#' @param X numeric matrix or data frame representing coordinates of points, or a symmetric matrix of distance of points or an object of class \link{dist}. Passed to \code{\link[dbscan]{optics}}, see also there.  
#' @param q The norm used for the Cordillera. Defaults to 2. 
#' @param minpts The minimum number of points that must make up a cluster in OPTICS (corresponds to k in the paper). It is passed to \code{\link[dbscan]{optics}} where it is called minPts. Defaults to 2.
#' @param epsilon The epsilon parameter for OPTICS (called epsilon_max in the paper). Defaults to 2 times the maximum distance between any two points.
#' @param distmeth The distance to be computed if X is not a symmetric matrix (those from \code{\link{dist}} are available) or a dist object (otherwise ignored). Defaults to Euclidean distance. 
#' @param dmax The winsorization value for the highest allowed reachability. If used for comparisons this should be supplied. If no value is supplied, it is NULL (default), then dmax is taken from the data as minimum of epsilon or the largest reachability.
#' @param rang A range of values for making up dmax. If supplied it overrules the dmax parameter and rang[2]-rang[1] is returned as dmax in the object. If no value is supplied rang is taken to be (0, dmax) taken from the data. Only use this when you know what you're doing, which would mean you're me (and even then we should be cautious). 
#' @param digits The precision to round the raw Cordillera and the norm factor. Defaults to 10.
#' @param scale Should X be scaled if it is an asymmetric matrix or data frame? Can take values TRUE or FALSE or a numeric value. If TRUE or 1, standardisation is to mean=0 and sd=1. If 2, no centering is applied and scaling of each column is done with the root mean square of each column. If 3, no centering is applied and scaling of all columns is done as X/max(standard deviation(allcolumns)). If 4, no centering is applied and scaling of all columns is done as X/max(rmsq(allcolumns)). If FALSE, 0 or any other numeric value, no standardisation is applied. Defaults to FALSE. 
#' @param ... Additional arguments to be passed to \code{\link[dbscan]{optics}}
#' 
#' @return A list with the elements
#'      \itemize{
#'        \item $raw... The raw cordillera
#'        \item $norm... The normalization constant
#'        \item $normfac... The normalization factor (the number of times that dmax is taken)
#'        \item $dmaxe... The effective maximum distance used for maximum structure (either dmax or epsilon or rang[2]-rang[1]). 
#'        \item $normed... The normed cordillera (raw/norm)
#'        \item $optics... The optics object
#' }
#' @section Warning: It may happen that the (normed) cordillera cannot be calculated properly (e.g. division by zero, infinite raw cordillera, q value to high etc.). A warning will be printed and the normed Cordillera is either 0, 1 (if infinity is involved) or NA. In that case one needs to check one or more of the following: reachability values returned from optics, minpts, eps, the raw cordillera, dmax and the normalization factor normfac.
#'
#' @importFrom dbscan optics
#' @importFrom stats as.dist dist sd

#' @keywords clustering multivariate
#' 
#' @examples
#' data(iris)
#' res<-princomp(iris[,1:4])
#' #2 dim goodness-of-clusteredness with clusters of at least 2 points
#' #With a matrix of points
#' cres2<-cordillera(res$scores[,1:2])
#' cres2
#' summary(cres2)
#' plot(cres2)
#'
#' #with a dist object 
#' dl0 <- dist(res$scores[,1:2],"maximum") #maximum distance
#' cres0<-cordillera(dl0)
#' cres0
#' summary(cres0)
#' plot(cres0)
#'
#' #with any symmetric distance/dissimilarity matrix 
#' dl1 <- cluster::daisy(res$scores[,1:2],"manhattan") 
#' cres1<-cordillera(dl1)
#' cres1
#' summary(cres1)
#' plot(cres1)
#' 
#' #4 dim goodness-of-clusteredness with clusters of at least 20
#' #points for PCA
#' cres4<-cordillera(res$scores[,1:4],minpts=20,epsilon=13,scale=3) 
#' #4 dim goodness-of-clusteredness with clusters of at least 20 points for original
#' #data
#' cres<-cordillera(iris[,1:4],minpts=20,epsilon=13,dmax=cres4$dmaxe,scale=3)
#' #There is more clusteredness for the original result
#' summary(cres4) 
#' summary(cres) 
#' plot(cres4) #cluster structure only a bit intelligible
#' plot(cres) #clearly two well separated clusters
#' 
#' ###############################################################################
#' # Example from Rusch et al. (2018) with original data, PCA and Sammon mapping #
#' ###############################################################################
#' 
#' #data preparation
#' data(CAClimateIndicatorsCountyMedian)
#' sovisel <- CAClimateIndicatorsCountyMedian[,-c(1,2,4,9)]
#' #normalize to [0,1]
#' sovisel <- apply(sovisel,2,function(x) (x-min(x))/(max(x)-min(x))) 
#' rownames(sovisel)  <- CAClimateIndicatorsCountyMedian[,1]
#' dis <- dist(sovisel)
#' 
#' #hyper parameters
#' dmax=1.22
#' q=2
#' minpts=3
#'
#' #original data directly
#' cdat <- cordillera(sovisel,distmeth="euclidean",minpts=minpts,epsilon=10,q=q,
#'                    scale=0)
#' #equivalently
#' #dis2=dist(sovisel)
#' #cdat2 <- cordillera(dis2,minpts=minpts,epsilon=10,q=q,scale=FALSE) 
#'
#' #PCA in 2-dim
#' pca1 <- princomp(sovisel)
#' pcas <- scale(pca1$scores[,1:2])
#' cpca <- cordillera(pcas,minpts=minpts,epsilon=10,q=q,dmax=dmax,scale=FALSE)
#'
#' #Sammon mapping in 2-dim
#' sam <- MASS::sammon(dis)
#' samp <- scale(sam$points)
#' csam <- cordillera(samp,epsilon=10,minpts=minpts,q=q,dmax=dmax,scale=FALSE)
#'
#' #results
#' cdat
#' cpca
#' csam
#' 
#' par(mfrow=c(3,1))
#' plot(cdat)
#' plot(cpca)
#' plot(csam)
#' par(mfrow=c(1,1))
#' 
#' @export
cordillera <- function(X,q=2,minpts=2,epsilon,distmeth="euclidean",dmax=NULL,rang,digits=10,scale=FALSE,...)
{
     #if X is a dist object, take it; otherwise if a matrix or data frame X calculate a dist object. If X is a symmetric matrix turn it into a distance object; reason is that dbscan:optics does not give the same result for dist(x) and as.matrix(dist(x))
    if(is.data.frame(X)) X <- as.matrix(X) 
    if(!inherits(X,"dist"))
        {
         if(!isSymmetric(X))
           {
           #if X is unsymmetric matrix or data frame, calculate distance object
             if(scale*1!=0)
               {
                   X <- scale(X,center=isTRUE(scale*1==1),scale=isTRUE(scale*1==1 | scale*1==2))
                   if(scale==3) X <- X/max(apply(X,2,sd))
                   if(scale==4) X <- X/max(attr(scale(X,center=FALSE),"scaled:scale"))
               }
               confs <- dist(X,method=distmeth)
           } else
               if(isSymmetric(X))
               {
                   confs <- as.dist(as.matrix(X))
               } else
                   stop("Input must be either a matrix or data frame of points, a symmetric matrix of distances or a dist object.")
        } else
            confs <- X 
       if(missing(epsilon)) epsilon <- 2*max(confs) #default epsilon
       optres <- dbscan::optics(confs,minPts=minpts,eps=epsilon,...)
       res <- optres$order
       tmp <- optres$reachdist[res]
       tmp[is.na(tmp)] <- Inf
       if(is.null(dmax)) dmax <- min(epsilon,max(tmp[is.finite(tmp)])) #This sets the dmax to max reachability if max < eps or eps if eps < max
       if(missing(rang)) rang <- c(0,dmax) #This sets the range to (0,dmax)
       maxi <- min(max(tmp[is.finite(tmp)]),max(rang)) #definition of reachabilities from paper
       tmp[tmp>maxi] <- maxi #winsorization effect 
       reachdiff <- diff(tmp) #the distance in reachability from one point to the next, basically length of the the reachability plot  -> the longer the "better"
       if(!isTRUE(all.equal(length(unique(dim(as.matrix(X))[1])),1))) stop("Argument X is neither (symmetric) matrix, data frame or distance object.")
       n <- unique(dim(as.matrix(X))[1])
       avgsidist <- round(sum(abs(reachdiff)^q,na.rm=TRUE),digits) #raw cordillera; round to three digits
       mdif <- abs(max(rang)-min(rang)) #dmaxe
       normfac <- 2*ceiling((n-1)/minpts) #the norm factor 
       normi <- round(mdif^q*normfac,digits=digits) #the normalization constant for even division
       if(!isTRUE(all.equal((n-1)%%minpts,0))) normi <- round(normi - mdif^q,digits=digits) #the correction to the upper bound if n-1/p is not fully met
       struc <- (avgsidist/normi)^(1/q) #the normed cordillera
       if(!is.finite(struc) || (normi < 1e-8)) warning(paste("I encountered a numeric problem. Most likely there was a division by a value near zero. Check whether there is something odd with these values (e.g., they are below 1e-8): Raw cordillera",avgsidist,", normalization constant",normi,"."))
       normstruc <- min(abs(struc),1) #if someone supplied a range that is to small we output 1. Also a warning? 
       if(is.na(normstruc)) normstruc <- avgsidist^(1/q)
       out <- list("reachplot"=tmp,"raw"=avgsidist^(1/q),"raw^q"=avgsidist,"norm"=normi,"normfac"=normfac,"dmaxe"=mdif,"normed"=normstruc,"optics"=optres)
        #mdif=dmax if dmax is supplied but not rang
        #mdif=epsilon if dmax>epsilon and rang not supplied
        #mdif=rang[2]-rang[1] if rang is supplied
       class(out) <- "cordillera"
       out
    }

