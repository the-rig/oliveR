#' Get data from \code{oliver_replica} and write to multiple files
#'
#' Using a connection to \code{oliver_replica}, materialize flat files for use in various reports.
#' For now, the files are written in a \code{feather} format in the \code{Data} directory of the package.
#' This function is a wrapper for \code{\link{write_oliver_data}}.
#'
#' The following dependencies are required in order to create a valid string as shown in the example below:
#' \itemize{
#'   \item The presence of an open SSH tunnel to the oliver replica as partially decribed in the \code{\link{create_ssh_command}} documentation.
#'   \item A valid username and password on \code{oliver_replica}. This can be set by contacting \email{mattbro@uw.edu}.
#' }
#'
#' @param con An object of class \code{src_postgres} which specifies a connection to the oliver replica.
#' @param tables A vector of table or view names that will be queried from the oliver replica and written to feather files in the \code{Data} directory.
#' Defaults to \code{c('report_businessmetrics_memberbreakdown', 'report_businessmetrics_provideractivity', 'report_businessmetrics_rollup', 'report_pcvmetrics_servicereferrals', 'report_pcvmetrics_visitreports')}.
#' @param schemas A vector of schema names associated with the \code{table} parameter. Defaults to \code{c(rep('static', 5), 'staging')}.
#'
#' @return \eqn{n} feather files to the \code{Data} directory of the package, where \eqn{n} is equal to \code{length(tables)}.
#'
#' @author Joe Mienko, \email{mienkoja@uw.edu}
#' @seealso \code{\link{load_flat_files}}, \code{\link{write_oliver_data}}
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
#' create_flat_files(con = con)

create_flat_files <- function(con
                              ,tables = c('report_businessmetrics_memberbreakdown'
                                          ,'report_businessmetrics_provideractivity'
                                          ,'report_businessmetrics_rollup'
                                          ,'report_pcvmetrics_servicereferrals'
                                          ,'report_pcvmetrics_visitreports'
                                          ,'Organizations')
                              ,schemas = c(rep('static', 5), 'staging')
){
  for (i in 1:length(tables)){
    write_oliver_data(data_name = tables[i], con = con, schema = schemas[i])
  }
}
