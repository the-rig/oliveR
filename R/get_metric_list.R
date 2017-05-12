get_metric_list <- function(mpp_group = pcv_performance_monitoring, group_id){
  
  
  metric_dim_list <- list(create_measurement_dimension_set(group_id = group_id
                                   ,mpp_group = mpp_group
                                   ,characteristic = 'Days Until Visit is Scheduled'
                                   ,characteristic_label = 'Scheduled Within 3 Days'
                                   ,characteristic_summary_obj = 1
                                   ,characteristic_percent_conforming_obj = 2
                                   ,characteristic_data_quality_obj = 3)
  
  ,create_measurement_dimension_set(group_id = group_id
                                   ,mpp_group = mpp_group
                                   ,characteristic = 'Days Until First Visit, as Scheduled'
                                   ,characteristic_label = 'First Visit (as Scheduled) Within 7 Days'
                                   ,characteristic_summary_obj = 4
                                   ,characteristic_percent_conforming_obj = 5
                                   ,characteristic_data_quality_obj = 6)
  
  ,create_measurement_dimension_set(group_id = group_id
                                   ,mpp_group = mpp_group
                                   ,characteristic = 'Children per Referral'
                                   ,characteristic_label = 'Children per Referral'
                                   ,characteristic_summary_obj = 7)
  
  ,create_measurement_dimension_set(group_id = group_id
                                   ,mpp_group = mpp_group
                                   ,characteristic = 'Percentage of Scheduled Visits, which Were Attended'
                                   ,characteristic_label = 'Visit Attendance Rate'
                                   ,characteristic_summary_obj = 8))

  
  group <- list(group_id = group_id)
  
  metric_list <- list(group, metric_dim_list)
  
  return(metric_list)

}
