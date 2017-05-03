#' Define a tibble attribute variable
#' @export

define_var_attribute <- function(data
                               ,population_member_id
                               ,value){
  
  dots <- setNames(list(lazyeval::interp(~ x
                               ,x = as.name(value)))
                   ,value)
  attribute <- select_(data
                       ,population_member_id
                       ,value) %>%
    as_data_frame() %>%
    mutate_(.
            ,.dots = dots) %>%
    rename_(., .dots = setNames(value, "attr_values"))
  return(attribute)
}
