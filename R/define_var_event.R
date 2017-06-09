#' Define a tibble event variable
#' @export


define_var_event <- function(data
                             ,id
                             ,value_date
                             ,convert_to_ymd = TRUE
                             ,tz = 'America/Los_Angeles'){
  dots <- setNames(list(lazyeval::interp(~ as.POSIXct(x, tz = tz)
                               ,x = as.name(value_date)))
                   ,value_date)
  event <- select_(data
                   ,id
                   ,value_date) %>%
    as_data_frame() %>%
    mutate_(.
            ,.dots = dots) %>%
    mutate(value_date = ifelse(convert_to_ymd, as_date(value_date), value_date))
  return(event)
}