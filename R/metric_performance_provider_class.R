#' Class providing object with methods for displaying values of measurement varsets
#'
#' @docType class
#' @export
#' @return Object of \code{\link{R6Class}} with methods for returning values and graphs from measurement objects built with this package.
#' @format \code{\link{R6Class}} object.
#' @examples
#' 
#' organization_acceptance_to_schedule <- define_varset(var_defs = list(referral_period_acceptance_to_schedule[[1]]
#'  ,referral_attr_id_organization)
#'  ,population_member_id = 'id_referral_visit'
#'  ,multi_join_type = 'inner') %>%
#'   group_by(id_organization) %>%
#'   summarise_each(c("mean")) %>%
#'   metric_performance_provider$new(., 'met_target', 'id_organization')
#'   
#'   referral_acceptance_to_schedule$get_value(22)
#'   referral_acceptance_to_schedule$get_donut(22)

library(R6)

metric_performance_provider <- R6Class("metric_performance_provider",
        public = list(
          aggr_varset = NULL
          ,metric_key = NULL
          ,organization_key = NULL
          ,measurement_name = NULL
          ,measurement_format = NULL
          ,measurement_rounding = NULL
          ,initialize = function(aggr_varset = NA
                                 ,metric_key = NA
                                 ,organization_key = NA
                                 ,measurement_name = NA
                                 ,measurement_format = NA
                                 ,measurement_rounding = NA) {
            self$aggr_varset <- aggr_varset
            self$metric_key <- metric_key
            self$organization_key <- organization_key
            self$measurement_name <- measurement_name
            self$measurement_format <- measurement_format
            self$measurement_rounding <- measurement_rounding            
          }
          ,get_value = function(organization_key_value) {
            filter_criteria <- interp(~ which_column == organization_key_value, which_column = as_name(self$organization_key))
            value_out <- self$aggr_varset %>%
              filter_(.dots = filter_criteria) %>%
              select_(self$metric_key) %>%
              as.numeric()
            return(value_out)
          },get_donut = function(organization_key_value) {
            if(all(!is.na(self$get_value(organization_key_value))
                   ,self$get_value(organization_key_value) <= 1
                   ,self$get_value(organization_key_value) >= 0))
              donut_out <- percent_donut_svg(proportion = self$get_value(organization_key_value))
            else
              donut_out <- NA
            return(donut_out)
          }
        )
)