create_measurement_dimension_set <- function(mpp_group = NA
                                             ,group_id = NA
                                             ,characteristic = NA
                                             ,characteristic_label = NA
                                             ,characteristic_summary_obj = NA
                                             ,characteristic_percent_conforming_obj = NA
                                             ,characteristic_data_quality_obj = NA){

  metric_list <- mpp_group$metric_list
  metric_key <- metric_list[[characteristic_summary_obj]]$measurement_name
  characteristic_summary_value = ifelse(!is.na(characteristic_summary_obj)
                                        ,metric_list[[characteristic_summary_obj]]$get_value(group_id)
                                        ,NA)
  characteristic_sub_label = ifelse(!is.na(characteristic_percent_conforming_obj)
                                    ,paste0('Avg '
                                        ,round(characteristic_summary_value, 0)
                                        ,' Days Until Scheduled')
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