#' Parse SQL from file. 
#'
#' Parse raw SQL from a file. The main purpose of this function is to get rid of comments which R does not 
#' handle very well within the DBI or RODBC packages (or their wrappers (e.g. dplyr)). 
#' 
#' @param filename A connection object or a character string. 
#' @param silent logical. Warn if a text file is missing a final EOL or if there are embedded nulls. Defaults to TRUE. 
#' 
#' @return A character vector of length the number of lines read.
#'
#' @author Joe Mienko, \email{mienkoja@uw.edu}
#' @export
#' @examples
#' fname <- tempfile("sql",fileext=".sql")
#' cat("--query 6
#'     select a6.column1, --trailing comments
#'     a6.column2, ---test triple -
#'     count(a6.column3) as counts, --/* funny comment */
#'     a6.column3 - a6.column4 ---test single - 
#'     /*count the number of occurences in table 1; 
#'     test another comment style
#'     */
#'     from data.table a6 /* --1st weirdo comment */
#'     /* --2nd weirdo comment */
#'     group by a6.column1\n", file=fname)
#' read_sql(fname)


read_sql <- function(filename, silent = TRUE) {
  q <- readLines(filename, warn = !silent)
  q <- q[!grepl(pattern = "^\\s*--", x = q)] # remove full-line comments
  q <- sub(pattern = "--.*", replacement="", x = q) # remove midline comments
  q <- paste(q, collapse = " ")
  return(q)
}

