#' Load data from \code{oliver_replica} into workspace
#'
#' Takes a vector of feather tables created with \code{\link{create_flat_files}} and loads them into \code{.GlobalEnv}.
#'
#' @param tables A list of feather tables that which have been written to the \code{Data} directory with \code{\link{create_flat_files}}.
#' defaults to c('report_businessmetrics_memberbreakdown', 'report_businessmetrics_provideractivity', 'report_businessmetrics_rollup'
#' ,'report_pcvmetrics_servicereferrals', 'report_pcvmetrics_visitreports', 'Organizations')
#'
#' @return \eqn{n} tibbles/data frames where \eqn{n} is equal to \code{length(tables)}.
#'
#' @author Joe Mienko, \email{mienkoja@uw.edu}
#' @seealso \code{\link{create_flat_files}}
#' @export
#' @examples
#' load_flat_files()

load_flat_files <- function(tables = c('report_businessmetrics_memberbreakdown'
                                       ,'report_businessmetrics_provideractivity'
                                       ,'report_businessmetrics_rollup'
                                       ,'report_pcvmetrics_servicereferrals'
                                       ,'report_pcvmetrics_visitreports'
                                       ,'Organizations')
                            ){
  for (i in tables) {
    assign(tables[tables %in% i]
           ,read_feather(paste0('Data/', i, '.feather'))
           ,envir=.GlobalEnv)
  }
}
