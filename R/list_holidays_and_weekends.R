#' Create a vector of 24 hour Intervals \pkg{lubridate} from \code{oliver_replica} write a single file
#'
#' This function is used to generate a vector of holiday and weekend \code{Interval} objects as defined by \pkg{lubridate}. It requires an active internet connection as it makes use of the Enrico service available at \link{http://www.kayaposoft.com/enrico/} to determine holidays for a given locality. This is used to exclude weekends and holidays from \code{Duration} and \code{Period} calculations.
#'
#' @param from_date A character string specifying the start date of the \code{Interval} vector in the format \code{\%m-\%d-\%Y}. Defaults to \code{01-01-2011}
#'
#' @param to_date A character string specifying the stop date of the \code{Interval} vector in the format \code{\%m-\%d-\%Y}. Defaults to \code{01-01-2111}.
#'
#' @param country_filter A character string specifying country of the holidays as required by the Enrico service. Defaults to 'usa'.
#' @param region_filter A character string specifying region, of the country, of the holidays as required by the Enrico service. Defaults to 'Washington'.
#'
#' @return A vector of lubridate \code{Interval} objects.
#'
#' @author Joe Mienko, \email{mienkoja@uw.edu}
#' @export
#' @examples
#'
#' list_holidays_and_weekends()
#'


list_holidays_and_weekends <- function(from_date = '01-01-2011'
                                       ,to_date = '01-01-2111'
                                       ,country_filter = 'usa'
                                       ,region_filter = 'Washington'
                                       ,tz = 'America/Los_Angeles'){

  # TODO: Add a warning message if the country_filter, region_filter, and tz do not align with each other. Would probably involve the search of a lookup table (e.g. https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)

  # connect to the Enrico holiday service
  content_url <- paste0("http://www.kayaposoft.com/enrico/json/v1.0/?action=getPublicHolidaysForDateRange&="
                        ,"&fromDate="
                        ,from_date
                        ,"&toDate="
                        ,to_date
                        ,"&country="
                        ,country_filter
                        ,"&region="
                        ,region_filter)

  # get request to the generated URL
  GET_content <- GET(content_url)

  # Build a vector of holiday dates (holidates) from the content of the GET method
  # this is a parse of the returned JSON from the holiday API
  holidays <- content(GET_content
                      ,as = "text"
                      ,encoding = 'UTF-8') %>%
    as.tbl_json() %>%
    gather_array() %>%
    enter_object("date") %>%
    spread_values(day = jstring("day")
                  ,month = jstring("month")
                  ,year = jstring("year")) %>%
    mutate(holidate = paste0(year
                             ,str_pad(month, 2, pad = "0")
                             ,str_pad(day, 2, pad = "0"))
           ,holidate = ymd(holidate)) %>%
    .$holidate

  # build a vector of weekend intervals
  # We start with a vector of all days
  day_seq <- seq(from = dmy(from_date)
                 ,to = dmy(to_date)
                 ,by = "days")

  # Then filter the weekends by name
  weekend_days <- day_seq[wday(day_seq, label = TRUE) %in%
                            c("Sat", "Sun")]

  # take the holiday vector and make an interval vector out of it
  # (note the addition of 24 hours to the dates)
  holiday_intervals <- interval(ymd_hms(paste0(holidays
                                               ," 00:00:00")
                                        ,tz = tz)
                                ,ymd_hms(paste0(holidays
                                                ," 00:00:00"), tz = tz) + hours(24))

  # repeat for the weekend days to create another vector of intervals
  weekend_intervals <- interval(
    ymd_hms(paste0(weekend_days, " 00:00:00"), tz = tz)
    ,ymd_hms(paste0(weekend_days, " 00:00:00"), tz = tz) + hours(24))

  # bind holidays and intervals together
  interval_df <- rbind(data.frame(interval = holiday_intervals)
                       ,data.frame(interval = weekend_intervals))

  # assign exclusion intervals and return
  day_exclusions <- interval_df$interval

  return(day_exclusions)
}