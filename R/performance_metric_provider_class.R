#' Class providing object with methods for communicating with flat files
#'
#' @docType class
#' @export
#' @return Object of \code{\link{R6Class}} with methods for communication in the Data directory of this package.
#' @format \code{\link{R6Class}} object.
#' @examples
#' pmi1 <- performance_metric_provider$new(measurement_name = 'Days Until Scheduled'
#' ,measurement_index = 'pm1'
#' ,measurement_service = 'pcv'
#' ,measurement_window = 30
#' ,measurement_calc_date = lubridate::now()
#' ,graph_conforming_fill = '#4ABDAC'
#' ,graph_nonconforming_fill = '#DFDCE3'
#' ,graph_output = NA)
#'
#' pmi1$percent_target_raw(4)
#' pmi1$measurement_value_raw(4)
#' pmi1$percent_target_graph(13)
#'
#' @field measurement_name A simple textual description of the measurement (not currently used in any methods).
#' @field measurement_index Stores a textual index of the measurement within a given service.
#' @field measurement_service Stores an abbreviation of the service target of a given measurement.
#' @field measurement_window The period of time (in days) over which the measurement is calculated (not currently used in any methods).
#' @field measurement_calc_date A date stamp indicating the day on which the measurement is calculated (not currently used in any methods).
#' @field graph_conforming_fill The fill color for the conforming portion of the graph returned by the \code{percent_target_graph} method.
#' @field graph_nonconforming_fill The fill color for the nonconforming portion of the graph returned by the \code{percent_target_graph} method.
#' @field graph_output A placeholder for future development. Currently the graph is returned to the active device. Future versions may return the text of a png or svg as needed.
#' #' @section Methods:
#' \describe{
#'   \item{Documentation}{For full documentation of each method go to https://github.com/lightning-viz/lightining-r/}
#'   \item{\code{new(...)}}{This method is used to create object of this class with fields set as specified above.}
#'   \item{\code{measurement_value_raw(id)}}{This method is used to return an unformatted measurement value.}
#'   \item{\code{percent_target_raw(id)}}{This method is used to return an unformatted proportion of instances in which a measurement target has been met.}
#'   \item{\code{percent_target_graph(id)}}{This method is used to return a doughnut plot representing the proportion of instances in which a measurement target has been met.}

library(R6)

performance_metric_provider <- R6Class("performance_metric_provider"
                              ,public = list(measurement_name = NULL
                                             ,measurement_index = NULL
                                             ,measurement_service = NULL
                                             ,graph_conforming_fill = NULL
                                             ,graph_nonconforming_fill = NULL
                                             ,initialize = function(measurement_name = NA
                                                                    ,measurement_index = NA
                                                                    ,measurement_service = NA
                                                                    ,graph_conforming_fill = NA
                                                                    ,graph_nonconforming_fill = NA) {
                                               self$measurement_name <- measurement_name
                                               self$measurement_index <- measurement_index
                                               self$measurement_service <- measurement_service
                                               self$graph_conforming_fill <- graph_conforming_fill
                                               self$graph_nonconforming_fill <- graph_nonconforming_fill
                                             }
                                             ,get_percent_target_raw = function(id
                                                                                ,measurement_service_val = self$measurement_service
                                                                                ,measurement_index_val = self$measurement_index) {
                                               percent_target_raw(id
                                                                  ,measurement_service_val
                                                                  ,measurement_index_val)
                                             }
                                             ,get_percent_target_graph = function(id
                                                                              ,measurement_service_val = self$measurement_service
                                                                              ,measurement_index_val = self$measurement_index
                                                                              ,conforming_fill_val = self$graph_conforming_fill
                                                                              ,nonconforming_fill_val = self$graph_nonconforming_fill) {
                                               percent_target_graph(id
                                                                    ,measurement_service_val
                                                                    ,measurement_index_val
                                                                    ,conforming_fill_val
                                                                    ,nonconforming_fill_val)

                                             }
                                             ,get_measurement_value_raw  = function(id
                                                                                    ,measurement_service_val = self$measurement_service
                                                                                    ,measurement_index_val = self$measurement_index) {
                                               measurement_value_raw(id
                                                                     ,measurement_service_val
                                                                     ,measurement_index_val)
                                             }
                  )
)
