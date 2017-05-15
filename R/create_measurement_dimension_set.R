create_measurement_dimension_set <- function(mpp_group = NA
                                             ,group_id = NA
                                             ,characteristic = NA
                                             ,characteristic_label = NA
                                             ,characteristic_summary_obj = NA
                                             ,characteristic_percent_conforming_obj = NA
                                             ,characteristic_data_quality_obj = NA
                                             ,sub_label_pre = NA
                                             ,sub_label_post = NA){

  # get a metric list 
  metric_list <- mpp_group$metric_list
  metric_key <- metric_list[[characteristic_summary_obj]]$measurement_name
  
  # get and format characteristic_summary_value
  if (!all(pcv_performance_monitoring$metric_list[[characteristic_summary_obj]]$measurement_format == 'percent'
          ,!is.na(characteristic_summary_obj))
      ) {
    characteristic_summary_value <- round(metric_list[[characteristic_summary_obj]]$get_value(group_id)
                                          ,metric_list[[characteristic_summary_obj]]$measurement_rounding)
  } else if (all(pcv_performance_monitoring$metric_list[[characteristic_summary_obj]]$measurement_format == 'percent'
                  ,!is.na(characteristic_summary_obj))
             ) {
    characteristic_summary_value <- sprintf(paste0('%1.'
                                                   ,metric_list[[characteristic_summary_obj]]$measurement_rounding
                                                   ,'f%%')
                                            ,100*metric_list[[characteristic_summary_obj]]$get_value(group_id))
  }
  
  # get and format sub label (if supplied)
  characteristic_sub_label = ifelse(all(!is.na(characteristic_percent_conforming_obj) # valid percent conforming value
                                        ,!is.na(characteristic_summary_value) # valid summary value
                                        ,!is.na(sub_label_pre) # text in front of value
                                        ,!is.na(sub_label_post)) # text after value 
                                    ,paste0(sub_label_pre
                                            ,round(characteristic_summary_value, 0)
                                            ,sub_label_post)
                                    ,NA)
  
  characteristic_percent_conforming_value = ifelse(!is.na(characteristic_percent_conforming_obj)
                                                    ,metric_list[[characteristic_percent_conforming_obj]]$get_value(group_id)
                                                    ,NA)
  
  characteristic_percent_conforming_value_pretty = ifelse(is.null(metric_list[[characteristic_percent_conforming_obj]]$measurement_rounding)
                                                          ,NA
                                                          ,sprintf(paste0('%1.'
                                                                  ,metric_list[[characteristic_percent_conforming_obj]]$measurement_rounding
                                                                  ,'f%%')
                                                           ,100*characteristic_percent_conforming_value)
  )
  
  characteristic_percent_conforming_graph = ifelse(!is.na(characteristic_percent_conforming_obj)
                                                     ,metric_list[[characteristic_percent_conforming_obj]]$get_donut(group_id)
                                                     ,NA)
  
  characteristic_data_quality_value = ifelse(!is.na(characteristic_data_quality_obj)
                                             ,metric_list[[characteristic_data_quality_obj]]$get_value(group_id)
                                             ,NA)
  
  dimensions <- data.frame(characteristic = characteristic
             ,characteristic_label = characteristic_label
             ,characteristic_sub_label = characteristic_sub_label
             ,characteristic_summary_value = characteristic_summary_value
             ,characteristic_percent_conforming_value = characteristic_percent_conforming_value
             ,characteristic_percent_conforming_value_pretty = characteristic_percent_conforming_value_pretty
             ,characteristic_percent_conforming_graph = characteristic_percent_conforming_graph
             ,characteristic_data_quality_value = characteristic_data_quality_value)
  
  return(dimensions)
}