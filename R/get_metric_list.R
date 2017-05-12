get_metric_list <- function(mpp_group = pcv_performance_monitoring, group_id){
  
  metric_list <- mpp_group$metric_list
  
  measurement_names <- vector(mode = 'list', length = 0)
  measurements <- vector(mode = 'list', length = 0)
  providers <- vector(mode = 'list', length = 0)
  
  group <- list(group_id = group_id)
  
  for (i in 1:length(metric_list)){
    
    measurement_names[[i]] <- metric_list[[i]]$measurement_name
    
    # apply formatting to value 
    
    value <- metric_list[[i]]$get_value(group_id)
    
    if (metric_list[[i]]$measurement_format == 'percent')
      value <- sprintf(paste0('%1.'
                              ,pcv_performance_monitoring$metric_list[[2]]$measurement_rounding
                              ,'f%%')
                       ,100*value)
    else 
      value <- sprintf(paste0('%.'
                              ,pcv_performance_monitoring$metric_list[[2]]$measurement_rounding
                              ,'f')
                       ,value)
    
    
    # build list 
    measurements[[i]] <- list(value = value
                              ,graph = metric_list[[i]]$get_donut(group_id)) # will add graph in a later push 
    
    names(measurements) <- measurement_names
    
  }
  
  metric_list_parsed <- list(group, measurements)
  
  return(metric_list_parsed)

}
