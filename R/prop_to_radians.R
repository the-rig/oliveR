#' Convert a proportion to radians
#'
#' A function that converts a proportion to radians as required by some of the parameters of \code{layer_arcs} in \pkg{ggvis}. 
#'
#' @author Joe Mienko, \email{mienkoja@uw.edu}
#' @seealso \code{\link{ggvis_donut}}
#' @export
#' @examples
#' 
#' prop_to_radians(.5) == pi
#' 

prop_to_radians <- function(proportion){
  degrees <- proportion*360.0
  radians <- degrees*pi/180.0
  return(radians)
}