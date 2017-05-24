#' Class providing object with methods for displaying values of measurement varsets
#'
#' @name measurement_group_class
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

measurement_group <- R6Class("measurement_group",
        public = list(
          measurement_list = vector(mode="numeric", length=0)
          ,measurement_add = function(...) self$measurement_list <- c(self$measurement_list
                                                                      ,list(...))
        )
)
