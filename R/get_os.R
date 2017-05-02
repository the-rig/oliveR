#' Return the current operating system
#'
#' A function that was shamelessly stolen from an r-bloggers posting \link{https://www.r-bloggers.com/identifying-the-os-from-r/}. It may someday be used to test for the operating system of a database user and utilize different \pkg{keyringr} functions based on the returned value. 
#'
#' @author Joe Mienko, \email{mienkoja@uw.edu}
#' @seealso \code{\link{db_connect}}
#' @export
#' @examples
#' library(dplyr)
#' library(RPostgreSQL)
#' library(feather)
#'
#' get_os()

get_os <- function(){
  sysinf <- Sys.info()
  if (!is.null(sysinf)){
    os <- sysinf['sysname']
    if (os == 'Darwin')
      os <- "osx"
  } else { ## mystery machine
    os <- .Platform$OS.type
    if (grepl("^darwin", R.version$os))
      os <- "osx"
    if (grepl("linux-gnu", R.version$os))
      os <- "linux"
  }
  tolower(os)
}