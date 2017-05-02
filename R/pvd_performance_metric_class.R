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

performance_metric <- R6Class("performance_metric_provider"
                              ,public = list(measurement_name = NULL
                                             ,measurement_index = NULL
                                             ,measurement_service = NULL
                                             ,measurement_window = NULL
                                             ,measurement_calc_date = NULL
                                             ,graph_conforming_fill = NULL
                                             ,graph_nonconforming_fill = NULL
                                             ,graph_output = NULL
                                             ,initialize = function(measurement_name = NA
                                                                    ,measurement_index = NA
                                                                    ,measurement_service = NA
                                                                    ,measurement_window = NA
                                                                    ,measurement_calc_date = NA
                                                                    ,graph_conforming_fill = NA
                                                                    ,graph_nonconforming_fill = NA
                                                                    ,graph_output = NA) {
                                               self$measurement_name <- measurement_name
                                               self$measurement_index <- measurement_index
                                               self$measurement_service <- measurement_service
                                               self$measurement_window <- measurement_window
                                               self$measurement_calc_date <- measurement_calc_date
                                               self$graph_conforming_fill <- graph_conforming_fill
                                               self$graph_nonconforming_fill <- graph_nonconforming_fill
                                               self$graph_output <- graph_output
                                             }
                                             ,percent_target_raw = function(id) {

                                               network_aggr_performance_metrics <- read_feather(path = 'Data//network_aggr_performance_metrics.feather')
                                               provider_id <- id

                                               .dots <- list(~provider_id == id)

                                               network_aggr_performance_metrics %>%
                                                 filter_(.dots = .dots) %>%
                                                 select(pct_lteq_3days_to_schedule) %>%
                                                 as.numeric()
                                             }
                                             ,percent_target_graph = function(id = NA
                                                                              ,output = NA
                                                                              ,measurement_service = self$measurement_service
                                                                              ,measurement_index = self$measurement_index
                                                                              ,conforming_alpha = 1
                                                                              ,nonconforming_alpha = .25
                                                                              ,conforming_fill = self$graph_conforming_fill
                                                                              ,nonconforming_fill = self$graph_nonconforming_fill
                                                                              ,thickness_out = 4
                                                                              ,thickness_in = 3){
                                               network_aggr_performance_metrics <- read_feather(path = 'Data//network_aggr_performance_metrics.feather')

                                               provider_id <- id

                                               .dots <- list(~provider_id == id)

                                               plot <- network_aggr_performance_metrics %>%
                                                 filter_(.dots = .dots) %>%
                                                 select(ends_with(paste0(measurement_service, '_', measurement_index))) %>%
                                                 add_totals_col() %>%
                                                 gather(key, value, -Total) %>%
                                                 filter(key != 'id') %>%
                                                 mutate(fraction = value/Total) %>%
                                                 arrange(fraction) %>%
                                                 mutate(ymax = cumsum(fraction)
                                                        ,ymin = lag(fraction
                                                                    ,default = 0)) %>%
                                                 ggplot(aes(fill=key
                                                            ,ymax=ymax
                                                            ,ymin=ymin
                                                            ,xmax=thickness_out
                                                            ,xmin=thickness_in)) +
                                                 scale_fill_manual(values = c(conforming_fill
                                                                              ,nonconforming_fill)) +
                                                 geom_rect(alpha = c(conforming_alpha
                                                                     ,nonconforming_alpha)) +
                                                 coord_polar(theta='y') +
                                                 xlim(c(0
                                                        ,thickness_out)) +
                                                 theme_void() +
                                                 guides(fill = 'none')

                                               return(plot)

                                             }
                                             ,measurement_value_raw = function(id) {

                                               network_aggr_performance_metrics <- read_feather(path = 'Data//network_aggr_performance_metrics.feather')

                                               provider_id <- id

                                               .dots <- list(~provider_id == id)

                                               network_aggr_performance_metrics %>%
                                                 filter_(.dots = .dots) %>%
                                                 select(avg_time_to_schedule) %>%
                                                 as.numeric()
                                             }
                  )
)

# pmi1 <- performance_metric$new(measurement_name = 'Days Until Scheduled'
#                                ,measurement_index = 'pm1'
#                                ,measurement_service = 'pcv'
#                                ,measurement_window = 30
#                                ,measurement_calc_date = lubridate::now()
#                                ,graph_conforming_fill = '#4ABDAC'
#                                ,graph_nonconforming_fill = '#DFDCE3'
#                                ,graph_output = NA)
#
# pmi1$measurement_value_raw(4)
# pmi1$percent_target_raw(4)
# pmi1$percent_target_graph(13)
