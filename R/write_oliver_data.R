#' Get data from \code{oliver_replica} write a single file
#'
#' This function is used to select all records from a view or a table within the specified schema within \code{oliver_replica}. For now, the files are written in a \pkg{feather} format in the \code{Data} directory of the package.
#'
#' #' The following dependencies are required in order to create a valid string:
#'
#' #' \itemize{
#'   \item The presence of an open SSH tunnel to the oliver replica as partially decribed in the \code{\link{create_ssh_command}} documentation.
#'   \item A valid username and password on the oliver replica database. Can be set by contacting \email{mattbro@uw.edu}.
#' }
#'
#' @param data_name A character string specifying the name of the table or view being accessed from the oliver replica.
#' @param con An object of class \code{src_postgres} which specifies a connection to the oliver replica.
#' @param schema A character string specifying the name of the schema holding the table or view from the oliver replica. The default value is \code{static}.
#'
#' @return A single feather file.
#'
#' @author Joe Mienko, \email{mienkoja@uw.edu}
#' @seealso \code{\link{create_ssh_command}}, \code{\link{create_flat_files}}
#' @export
#' @examples
#' library(dplyr)
#' library(RPostgreSQL)
#' library(feather)
#'
#' con <- src_postgres(
#'   dbname = 'oliver_replica',
#'   host = '127.0.0.1',
#'   user = 'mienkoja',
#'   password = 'mypassword'
#' )
#'
#' write_oliver_data(data_name = 'report_businessmetrics_memberbreakdown', con = con)

write_oliver_data <- function(data_name, con, schema){
  df <- dbGetQuery(con$con, paste0('select * from ', schema, '.\"', data_name, '\"'))
  path <- paste0('Data//', data_name, '.feather')
  write_feather(df, path)
}
