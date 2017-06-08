#' Class providing object with methods for displaying values of measurement varsets
#'
#' @name measurement_single_value_class
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

measurement_single_value <- R6Class("measurement_single_value",
        public = list(
          aggr_varset = NULL
          ,metric_key = NULL
          ,group_key = NULL
          ,measurement_name = NULL
          ,measurement_format = NULL
          ,measurement_rounding = NULL
          ,measurement_graph = NULL
          ,join_variable_1 = NULL
          ,join_variable_2 = NULL
          ,select_var = NULL
          ,rename_var = NULL
          ,data_out_type = NULL
          ,summary_function = NULL
          ,na_rm = NULL
          ,initialize = function(metric_key = NA
                                 ,group_key = 'id_organization'
                                 ,measurement_name = NA
                                 ,measurement_format = NA
                                 ,measurement_rounding = NA
                                 ,measurement_graph = NA
                                 ,join_variable_1 = NA
                                 ,join_variable_2 = NA
                                 ,select_var = NA
                                 ,rename_var = NA
                                 ,data_out_type = NA
                                 ,summary_function = 'mean'
                                 ,na_rm = TRUE) {
            self$metric_key <- metric_key
            self$group_key <- group_key
            self$measurement_name <- measurement_name
            self$measurement_format <- measurement_format
            self$measurement_rounding <- measurement_rounding
            self$measurement_graph <- measurement_graph
            self$join_variable_1 <- join_variable_1
            self$join_variable_2 <- join_variable_2
            self$select_var <- select_var
            self$rename_var <- rename_var
            self$data_out_type <- data_out_type
            self$summary_function <- summary_function
            self$na_rm <- na_rm
            self$aggr_varset <- summarise_vars(join_variable_1 = self$join_variable_1
                                                ,join_variable_2 = self$join_variable_2
                                                ,select_var = self$select_var
                                                ,rename_var = self$rename_var
                                                ,group_key = self$group_key
                                                ,data_out_type = self$data_out_type
                                                ,summary_function = self$summary_function
                                                ,na_rm = self$na_rm)
          }
          ,get_value = function(group_id) {
            filter_criteria <- interp(~ which_column == group_id
                                      ,which_column = as_name(self$group_key))
            value_out <- self$aggr_varset %>%
              filter_(.dots = filter_criteria) %>%
              select_(self$metric_key) %>%
              as.numeric()
            return(value_out)
          },get_graph = function(group_id) {
            if(all(!is.na(self$get_value(group_id))
                   ,self$get_value(group_id) <= 1
                   ,self$get_value(group_id) >= 0
                   ,is.null(self$measurement_graph))
               )
              graph_out <- percent_donut_svg(proportion = self$get_value(group_id))
            else
              graph_out <- NA
            return(graph_out)
          }
        )
)