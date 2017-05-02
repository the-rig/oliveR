#' Define a tibble period varset
#' 
#' A function to join a list of tibbles, by a single \code{population_member_id}, using either the \code{inner_join} or \code{left_join} functions from \pkg{dplyr}.
#' 
#' @param var_defs A list of tibble variables (events, periods, or attributes). 
#' @param population_member_id A unique identifier for each 'member' of the population of interest. Must be present in each tibble. 
#' @param multi_join_type The name of the join you wish to make. Currently limited to \code{'inner'} or \code{'left'}. Defaults is \code{'inner'}.
#' @export

define_varset <- function(var_defs = list()
                          ,population_member_id = 'id_referral_visit'
                          ,multi_join_type = 'inner'){
  
  if(multi_join_type == 'inner'){
    varset <- var_defs %>%
      Reduce(function(...) inner_join(...,by = population_member_id), .) %>%
      select_(.dots = interp(~-one_of(x), x = population_member_id))
  } else if (multi_join_type == 'left') {
    varset <- var_defs %>%
      Reduce(function(...) left_join(...,by = population_member_id), .) %>%
      select_(.dots = interp(~-one_of(x), x = population_member_id))
  }
  
  return(varset)
  
}
