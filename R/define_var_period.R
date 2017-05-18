#' Define a tibble period variable (in days)
#'
#' @param event_start_tibble A tibble with a date column representing the start of a period and \code{population_member_id} column.
#' @param event_stop_tibble A tibble with a date column representing the stop of a period and \code{population_member_id} column.
#' @param event_start_var The name of the date column in \code{event_start_tibble}.
#' @param event_stop_var The name of the date column in \code{event_stop_tibble}.
#' @param population_member_id A unique identifier for each 'member' of the population of interest. Must be present in both tibbles.
#' @param period_name The desired name for the period column to be created in the new tibble.
#' @param exclusions A vector of \code{Interval} objects, typically created from \code{list_holidays_and_weekends()}. Defaults is a call to \code{list_holidays_and_weekends()}.
#' @param period_target A numeric value to serve as a threshold value. If provided, a second tibble will be calculated indicating whether or not the period value is less than or equal to the threshold value. Defaults is \code{NA}.
#' @param overwrite_negative A binary value indicating whether or not negative interval values should be set to \code{NA}. Defaults is \code{TRUE}.
#' @export

define_var_period <- function(event_start_tibble
                                 ,event_stop_tibble
                                 ,event_start_var
                                 ,event_stop_var
                                 ,population_member_id
                              ,period_name
                                 ,exclusions = list_holidays_and_weekends()
                                 ,period_target = NA
                                 ,overwrite_negative = TRUE
                              ,jitter = Sys.getenv("OLIVER_REPLICA_JITTER")){

  dots1 <- setNames(list(lazyeval::interp(~ lubridate::interval(x, y)
                                ,x = as.name(event_start_var)
                                ,y = as.name(event_stop_var)
  ))
  ,'interval_raw')

  period_dat <- inner_join(event_start_tibble
                           ,event_stop_tibble) %>%
    select_(population_member_id
            ,event_start_var
            ,event_stop_var) %>%
    mutate_(., .dots = dots1) %>%
    as_data_frame()

  period_dat$interval_delta <- NA

  for (i in 1:nrow(period_dat)){
    period_dat$interval_delta[i] <- sum(exclusions %within% period_dat$interval_raw[i])
  }

  dots2 <- setNames(list(lazyeval::interp(~ x
                                ,x = quote(period_all))
                         ,lazyeval::interp(~ y
                                 ,y = quote(period_days)))
                    ,c(period_name, paste0(period_name, '_days'))
  )

  period_dat_value <- period_dat %>%
    mutate(period_all = as.period(interval_raw, unit = 'days') - days(interval_delta)
           ,period_days = as.numeric(period_all, 'days')
           ,met_target = if (is.na(period_target)) TRUE else period_days <= period_target
           ,negative_interval = int_length(interval_raw) < 0
    ) %>%
    mutate_(., .dots = dots2) %>%
    mutate(period_days = ifelse(overwrite_negative & negative_interval, NA, period_days)
           ,period_days = if(jitter){period_days + rbinom(n = n()
                                                          ,size = period_target
                                                          ,prob = runif(1))} else period_days) %>%
    select_(population_member_id
            ,quote(period_days))

  period_dat_target <- period_dat %>%
    mutate(period_all = as.period(interval_raw, unit = 'days') - days(interval_delta)
           ,period_days = as.numeric(period_all, 'days')
           ,met_target = if (is.na(period_target)) TRUE else period_days <= period_target
           ,negative_interval = int_length(interval_raw) < 0
    ) %>%
    mutate_(., .dots = dots2) %>%
    mutate(met_target = ifelse(overwrite_negative & negative_interval, NA, met_target)) %>%
    select_(population_member_id
            ,quote(met_target)
    )
  return(list(period_dat_target
              ,period_dat_value)
  )

}
