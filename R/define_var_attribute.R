#' Define a tibble attribute variable
#' @export

define_var_attribute <- function(data
                               ,id
                               ,value
                               ,jitter = Sys.getenv("OLIVER_REPLICA_JITTER")){

  # need to force the data object into a data frame so I can play with it in matrix notation
  # in the lapply call below
  data <- data %>% as_data_frame()

  # calculate the mean of the available data
  mean_value <- lapply(data[,value], mean, na.rm = TRUE)

  # set names for the df
  dots <- setNames(list(lazyeval::interp(~ x
                               ,x = as.name(value)))
                   ,value)

  # initialize the attr table
  attribute <- select_(data
                       ,id
                       ,value) %>%
    as_data_frame() %>%
    mutate_(.
            ,.dots = dots) %>%
    rename_(., .dots = setNames(value, "attr_values"))

  # if jitter=TRUE...
  if (jitter) {
    # apply jitter for logical values
    if (lapply(data[, value], class) == 'logical') {
      attribute <- attribute %>%
        mutate(
          attr_values = runif(n())
          ,attr_values = ifelse(attr_values > mean_value, TRUE, FALSE)
        )
      
    # apply jitter for integer and double values
    } else if (any(lapply(data[, value], class) == 'integer' ,
                   lapply(data[, value], class) == 'double')) {
      attribute <- attribute %>%
        mutate(attr_values = attr_values + rbinom(
          n = n()
          ,size = round(as.numeric(mean_value)
                       , digits = 0)
          ,prob = runif(1)
        ))
    }
  }

  return(attribute)

}
