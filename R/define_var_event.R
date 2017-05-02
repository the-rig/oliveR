#' Define a tibble event variable
#' @export


define_var_event <- function(data
                                ,population_member_id
                                ,value_date){
  dots <- setNames(list(lazyeval::interp(~ as.POSIXct(x, tz = 'America/Los_Angeles')
                               ,x = as.name(value_date)))
                   ,value_date)
  event <- select_(data
                   ,population_member_id
                   ,value_date) %>%
    as_data_frame() %>%
    mutate_(.
            ,.dots = dots)
  return(event)
}