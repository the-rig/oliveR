#' Capture the "percent conforming"
#'
#' This function is designed to be used as a method within an object of class \code{performance_metric_provider}.
#' It assumes the existence of #' a file named \code{network_aggr_performance_metrics.feather} as created by \code{\link{write_network_metric_file}}. It returns the "percent conforming" to a specified target of a given performance measure, as determined by the column name in \code{network_aggr_performance_metrics.feather}.
#'
#' @param id The provider \code{id} as defined in \code{oliver_replica}.

percent_target_raw = function(id
                              ,measurement_service_val = NA
                              ,measurement_index_val = NA) {

  measurement_type = 'pct_tgt'

  network_aggr_performance_metrics <- read_feather(path = 'Data//network_aggr_performance_metrics.feather')

  provider_id <- id

  .dots <- list(~provider_id == id)

  network_aggr_performance_metrics %>%
    filter_(.dots = .dots) %>%
    select(ends_with(paste0(measurement_service_val, '_', measurement_index_val, '_', measurement_type))) %>%
    as.numeric()

}
