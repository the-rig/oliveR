#' Define a tibble event variable
#' @export


define_var_event <- function(data
                             ,id
                             ,value_date
                             ,convert_to_ymd = TRUE
                             ,tz = 'America/Los_Angeles'){
  dots1 <- setNames(list(lazyeval::interp(~ as.POSIXct(x, tz = tz)
                               ,x = as.name(value_date)))
                   ,value_date)
  dots2 <- setNames(list(lazyeval::interp(~ as_date(x, tz = tz)
                                         ,x = as.name(value_date)))
                   ,value_date)


  if(convert_to_ymd) {
    event <- select_(data
                     ,id
                     ,value_date) %>%
      as_data_frame() %>%
      mutate_(.
              ,.dots = dots1) %>%
      mutate_(.
              ,.dots = dots2)
  } else {
    event <- select_(data
                     ,id
                     ,value_date) %>%
      as_data_frame() %>%
      mutate_(.
              ,.dots = dots1)
  }


  return(event)
}