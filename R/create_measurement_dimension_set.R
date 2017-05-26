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
  measurement_list <- mpp_group$measurement_list
  metric_key <- measurement_list[[characteristic_summary_obj]]$measurement_name

  # get and format characteristic_summary_value
  if (all(pcv_performance_monitoring$measurement_list[[characteristic_summary_obj]]$measurement_format == 'percent'
                 ,!is.na(characteristic_summary_obj)
                 ,!is.na(measurement_list[[characteristic_summary_obj]]$get_value(group_id)))
             ) {
    characteristic_summary_value <- sprintf(paste0('%1.'
                                                   ,measurement_list[[characteristic_summary_obj]]$measurement_rounding
                                                   ,'f%%')
                                            ,100*measurement_list[[characteristic_summary_obj]]$get_value(group_id))
  }  else if (all(pcv_performance_monitoring$measurement_list[[characteristic_summary_obj]]$measurement_format == 'days'
                  ,!is.na(characteristic_summary_obj)
                  ,!is.na(measurement_list[[characteristic_summary_obj]]$get_value(group_id)))
  ) {
    characteristic_summary_value <- paste0(round(measurement_list[[characteristic_summary_obj]]$get_value(group_id)
                                                 ,measurement_list[[characteristic_summary_obj]]$measurement_rounding)
                                           , ' Days')
  } else {
    characteristic_summary_value <- round(measurement_list[[characteristic_summary_obj]]$get_value(group_id)
                                          ,measurement_list[[characteristic_summary_obj]]$measurement_rounding)
  }

  characteristic_percent_conforming_value = ifelse((!is.na(characteristic_percent_conforming_obj))
                                                    ,measurement_list[[characteristic_percent_conforming_obj]]$get_value(group_id)
                                                    ,NA)

  if(all(!is.null(measurement_list[[characteristic_percent_conforming_obj]]$measurement_rounding)
         ,!is.nan(characteristic_percent_conforming_value)
         ,!is.na(characteristic_percent_conforming_value))
  ){
    characteristic_percent_conforming_value_pretty <- sprintf(paste0('%1.'
                                                                     ,measurement_list[[characteristic_percent_conforming_obj]]$measurement_rounding
                                                                     ,'f%%')
                                                              ,100*characteristic_percent_conforming_value)
  } else {
    characteristic_percent_conforming_value_pretty <- NA
  }

  characteristic_percent_conforming_graph = ifelse(!is.na(characteristic_percent_conforming_obj)
                                                     ,measurement_list[[characteristic_percent_conforming_obj]]$get_graph(group_id)
                                                     ,NA)

  if (all(!is.na(characteristic_summary_value)
          ,!is.nan(characteristic_summary_value))){

    characteristic_data_quality_value <- ifelse(!is.na(characteristic_data_quality_obj)
                                               ,measurement_list[[characteristic_data_quality_obj]]$get_value(group_id)
                                               ,NA)
  } else {
    characteristic_data_quality_value <- NA
  }

  # get and format sub label (if supplied)


  if (all(!is.na(characteristic_summary_value)
          ,!is.nan(characteristic_summary_value))){

    characteristic_sub_label = ifelse(all(!is.na(characteristic_percent_conforming_obj) # valid percent conforming value
                                          ,!is.na(characteristic_summary_value) # valid summary value
                                          ,!is.na(sub_label_pre) # text in front of value
                                          ,!is.na(sub_label_post)) # text after value
                                      ,paste0(sub_label_pre
                                              ,characteristic_percent_conforming_value_pretty
                                              ,sub_label_post)
                                      ,NA)
  } else {
    characteristic_sub_label = NA
  }

  dimensions <- data.frame(characteristic = characteristic
                           ,characteristic_label = characteristic_label
                           ,characteristic_sub_label = characteristic_sub_label
                           ,characteristic_summary_value = characteristic_summary_value
                           ,characteristic_percent_conforming_value = characteristic_percent_conforming_value
                           ,characteristic_percent_conforming_value_pretty = characteristic_percent_conforming_value_pretty
                           ,characteristic_percent_conforming_graph = characteristic_percent_conforming_graph
                           ,characteristic_data_quality_value = characteristic_data_quality_value
                           ,measurement_missing = ifelse(is.na(characteristic_summary_value) |
                                                           is.nan(characteristic_summary_value), TRUE, FALSE)
  )

  return(dimensions)
}