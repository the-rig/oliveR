create_measurement_dimension_set <- function(mpp_group = NA
                                             ,group_id = NA
                                             ,characteristic = NA
                                             ,characteristic_label = NA
                                             ,characteristic_summary_obj = NA
                                             ,characteristic_percent_conforming_obj = NA
                                             ,characteristic_data_quality_obj = NA
                                             ,sub_label_pre = NA
                                             ,sub_label_post = NA
                                             ,primary_measure = NA
                                             ,secondary_measure = NA){

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

  if (!is.na(primary_measure)){
    value_raw <- mpp_group$measurement_list[[primary_measure]]$get_value(group_id)
  }


  if (mpp_group$measurement_list[[primary_measure]]$measurement_format == 'days') {
    value_round <- round(mpp_group$measurement_list[[primary_measure]]$get_value(group_id)
                         ,mpp_group$measurement_list[[primary_measure]]$measurement_rounding)
    #value <- paste0(value_round, ' Days')
    value <- paste0(value_round)

  } else if (mpp_group$measurement_list[[primary_measure]]$measurement_format == 'numeric') {
    value_round <- round(mpp_group$measurement_list[[primary_measure]]$get_value(group_id)
                         ,mpp_group$measurement_list[[primary_measure]]$measurement_rounding)
    value <- value_round
  } else if (mpp_group$measurement_list[[primary_measure]]$measurement_format == 'percent') {
    value <- sprintf(paste0('%1.'
                                ,measurement_list[[primary_measure]]$measurement_rounding
                                ,'f%%')
                         ,100*value_raw)
  } else {
    value <- NA
  }


  if (!is.na(secondary_measure)){

    sub_value <- mpp_group$measurement_list[[secondary_measure]]$get_value(group_id)

    if (mpp_group$measurement_list[[secondary_measure]]$measurement_format == 'percent') {
      sub_value <- sprintf(paste0('%1.'
                                  ,measurement_list[[secondary_measure]]$measurement_rounding
                                  ,'f%%')
                           ,100*sub_value)
    } else{
      sub_value <- sub_value
    }
  } else{
    sub_value <- NA
  }


  # if(any(!is.na(sub_label_pre), !is.na(sub_label_post))){
  #   sub_value <- paste0(sub_label_pre, sub_value, sub_label_post)
  # } else
  #   sub_value <- 'NA'
  #
  # if (any(stringr::str_detect(value, 'NA')
  #         ,stringr::str_detect(value, 'NaN'))) {
  #
  #   value <- NA
  #
  # }
  # else if (any(stringr::str_detect(sub_value, 'NA')
  #                 ,stringr::str_detect(sub_value, 'NaN'))
  #            ) {
  #
  #   sub_value <- NA
  #
  # }

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
                           ,value = ifelse(any(stringr::str_detect(value, 'NA')
                                               ,stringr::str_detect(value, 'NaN'))
                                           ,'NA'
                                           ,value)
                           ,label = mpp_group$measurement_list[[primary_measure]]$measurement_name
                           ,sublabel = ifelse(any(stringr::str_detect(sub_value, 'NA')
                                                   ,stringr::str_detect(sub_value, 'NaN'))
                                              ,'NA'
                                              ,sub_value)
                           ,threshold = FALSE
                           ,template = 'default'
  )

  return(dimensions)
}