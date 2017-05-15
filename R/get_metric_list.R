get_metric_list <- function(mpp_group = pcv_performance_monitoring, group_id){

  missing_list <- vector(mode="numeric"
                         ,length=0)
  missing_list_add <- function(...) missing_list <- c(missing_list
                                                      ,list(...))

  x <- data.frame(id = group_id)
  
  x$acceptance_to_schedule <- create_measurement_dimension_set(group_id = group_id
                                   ,mpp_group = mpp_group
                                   ,characteristic = 'Days Until Visit is Scheduled'
                                   ,characteristic_label = 'Scheduled Within 3 Days'
                                   ,characteristic_summary_obj = 1
                                   ,characteristic_percent_conforming_obj = 2
                                   ,characteristic_data_quality_obj = 3
                                   ,sub_label_pre = 'Avg. '
                                   ,sub_label_post = ' Days Until Scheduled')

  missing_list <- missing_list_add(x$acceptance_to_schedule$measurement_missing)
  
  x$acceptance_to_first_visit <- create_measurement_dimension_set(group_id = group_id
                                   ,mpp_group = mpp_group
                                   ,characteristic = 'Days Until First Visit, as Planned'
                                   ,characteristic_label = 'Visit Planned Within 7 Days'
                                   ,characteristic_summary_obj = 4
                                   ,characteristic_percent_conforming_obj = 5
                                   ,characteristic_data_quality_obj = 6
                                   ,sub_label_pre = 'Avg. '
                                   ,sub_label_post = ' Days Until First Visit')
  
  missing_list <- missing_list_add(x$acceptance_to_first_visit$measurement_missing)
  
  x$child_count_value = create_measurement_dimension_set(group_id = group_id
                                   ,mpp_group = mpp_group
                                   ,characteristic = 'Children per Referral'
                                   ,characteristic_label = 'Children per Referral'
                                   ,characteristic_summary_obj = 7
                                   ,characteristic_percent_conforming_obj = NA
                                   ,characteristic_data_quality_obj = NA)
  
  missing_list <- missing_list_add(x$child_count_value$measurement_missing)
  
  x$attendance_per_scheduled_visit = create_measurement_dimension_set(group_id = group_id
                                   ,mpp_group = mpp_group
                                   ,characteristic = 'Percentage of Scheduled Visits, which Were Attended'
                                   ,characteristic_label = 'Visit Attendance Rate'
                                   ,characteristic_summary_obj = 8
                                   ,characteristic_percent_conforming_obj = NA
                                   ,characteristic_data_quality_obj = NA)
  
  missing_list <- missing_list_add(x$attendance_per_scheduled_visit$measurement_missing)
  
  if (sum(unlist(missing_list)) == length(unlist(missing_list))){
    x$id <- 'no data available'
  } 
  
  return(x)
  
}
