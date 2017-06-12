build_all_metrics <- function(
    dbname = Sys.getenv("OLIVER_REPLICA_DBNAME"),
    host = Sys.getenv("OLIVER_REPLICA_HOST"),
    user = Sys.getenv("OLIVER_REPLICA_USER"),
    password = Sys.getenv("OLIVER_REPLICA_PASSWORD"),
    port = Sys.getenv("OLIVER_REPLICA_PORT"),
    jitter = Sys.getenv("OLIVER_REPLICA_JITTER"),
    measurement_window = 180,
    measurement_window_start = 20170301,
    tz = 'America/Los_Angeles'
)
{

  # define measurement variables

  message('building attribute variables', appendLF = FALSE)

  referral_attr_id_organization <- measurement_variable$new(name = 'referral_attr_id_organization'
                                                            ,data_in = import_referral_organization
                                                            ,type = 'attr'
                                                            ,id_col = 'id_referral_visit'
                                                            ,value_col1 = 'id_organization'
                                                            ,jitter = FALSE)

  message(' . ', appendLF = FALSE)

  referral_attr_child_count <- measurement_variable$new(name = 'referral_attr_child_count'
                                                        ,data_in = import_referral_child_record_count
                                                        ,type = 'attr'
                                                        ,id_col = 'id_referral_visit'
                                                        ,value_col1 = 'child_count_attr')

  message(' . ', appendLF = FALSE)

  referral_visit_attendance <- measurement_variable$new(name = 'referral_visit_attendance'
                                                        ,data_in = import_visit_reports
                                                        ,type = 'attr'
                                                        ,id_col = 'id_referral_visit'
                                                        ,value_col1 = 'visitation_attended')

  message(' done')

  ## define Events

  message('building event variables', appendLF = FALSE)

  referral_event_acceptance <- measurement_variable$new(name = 'referral_event_acceptance'
                                                        ,data_in = import_referral_acceptance_events
                                                        ,type = 'event'
                                                        ,id_col = 'id_referral_visit'
                                                        ,value_col1 = 'dt_referral_acceptance')

  message(' . ', appendLF = FALSE)

  referral_event_scheduling <- measurement_variable$new(name = 'referral_event_scheduling'
                                                        ,data_in = import_referral_scheduling_events
                                                        ,type = 'event'
                                                        ,id_col = 'id_referral_visit'
                                                        ,value_col1 = 'dt_referral_scheduled')

  message(' . ', appendLF = FALSE)

  referral_event_first_scheduled_visit <- measurement_variable$new(name = 'referral_event_first_scheduled_visit'
                                                                   ,data_in = import_visits_initial_as_scheduled
                                                                   ,type = 'event'
                                                                   ,id_col = 'id_referral_visit'
                                                                   ,value_col1 = 'dt_scheduled_visit_initial')

  message(' done')


  # con <- src_postgres(
  #   dbname = dbname,
  #   host = host,
  #   user = user,
  #   password = password,
  #   port = port
  # )

#
#   message('importing data')
#   op <- pboptions(type="txt")
#
#   ptm_import <- proc.time()
#   system.time(pblapply(X = import_fncs
#          ,FUN = do.call
#          ,list(con = con
#                ,measurement_window = measurement_window
#                ,measurement_window_start = measurement_window_start
#                ,tz = tz
#                )
#
#          )
#   )
#   proc.time() - ptm_import

  # referral_attr_id_organization <- define_var_attribute(data = tbl_referral_organization
  #                                                       ,id = 'id_referral_visit'
  #                                                       ,value = 'id_organization'
  #                                                       ,jitter = FALSE)
  #
  # referral_attr_child_count <- define_var_attribute(tbl_referral_child_record_count
  #                                                   ,id = 'id_referral_visit'
  #                                                   ,value = 'child_count_attr'
  #                                                   ,jitter = jitter)
  #
  # referral_visit_attendance <- define_var_attribute(tbl_visit_reports
  #                                                   ,id = 'id_referral_visit'
  #                                                   ,value = 'visitation_attended'
  #                                                   ,jitter = jitter)
  #
  # ## Define Events
  #
  # referral_event_acceptance <- define_var_event(tbl_referral_acceptance_events
  #                                               ,'id_referral_visit'
  #                                               ,'dt_referral_acceptance')
  #
  # referral_event_scheduling <- define_var_event(tbl_referral_scheduling_events
  #                                               ,'id_referral_visit'
  #                                               ,'dt_referral_scheduled')
  #
  # referral_event_first_scheduled_visit <- define_var_event(tbl_visits_initial_as_sceduled
  #                                                          ,'id_referral_visit'
  #                                                          ,'dt_scheduled_visit_initial')


  ## Define Periods

  ## TODO Need to convert these last four variable definitions to measurement_variable objects

  message('building period variables', appendLF = FALSE)

  ## START HERE -> Need internet to run, but this should replace the define_var_period call below

  referral_period_acceptance_to_schedule <- measurement_variable$new(name = 'acceptance_to_schedule'
                           ,data_in = list(referral_event_acceptance$data_out_identity
                                           ,referral_event_scheduling$data_out_identity)
                           ,type = 'period'
                           ,id_col = 'id_referral_visit'
                           ,value_col1 = 'dt_referral_acceptance'
                           ,value_col2 = 'dt_referral_scheduled'
                           ,target = 3)

  #referral_period_acceptance_to_schedule <- define_var_period(
    #event_start_tibble = referral_event_acceptance
    #,event_stop_tibble = referral_event_scheduling
    #,event_start_var = 'dt_referral_acceptance'
    #,event_stop_var = 'dt_referral_scheduled'
    #,id = 'id_referral_visit'
    #,exclusions = list_holidays_and_weekends()
#    ,period_name = 'acceptance_to_schedule'
#    ,period_target = 3
 #   ,jitter = jitter
  #)

  message(' . ', appendLF = FALSE)



  referral_period_acceptance_to_first_scheduled <- measurement_variable$new(name = 'acceptance_to_first_scheduled'
                           ,data_in = list(referral_event_acceptance$data_out_identity
                                           ,referral_event_first_scheduled_visit$data_out_identity)
                           ,type = 'period'
                           ,id_col = 'id_referral_visit'
                           ,value_col1 = 'dt_referral_acceptance'
                           ,value_col2 = 'dt_scheduled_visit_initial'
                           ,target = 7)

  #
  # referral_period_acceptance_to_first_scheduled <- define_var_period(
  #   event_start_tibble = referral_event_acceptance
  #   ,event_stop_tibble = referral_event_first_scheduled_visit
  #   #,event_start_var = 'dt_referral_acceptance'
  #   #,event_stop_var = 'dt_scheduled_visit_initial'
  #   #,id = 'id_referral_visit'
  #   #,exclusions = list_holidays_and_weekends()
  #   #,period_name = 'acceptance_to_first_scheduled'
  #   #,period_target = 7
  #   #,jitter = jitter
  # )

  # message(' . ', appendLF = FALSE)
  #
  # ## Define *Variable* Attributes
  #
  # referral_period_acceptance_to_schedule_nas <- referral_period_acceptance_to_schedule[[2]] %>%
  #   mutate(valid_data = ifelse(is.na(period_days), FALSE, TRUE)) %>%
  #   select(-period_days)
  #
  # message(' . ', appendLF = FALSE)
  #
  # referral_period_acceptance_to_first_scheduled_nas <- referral_period_acceptance_to_first_scheduled[[2]] %>%
  #   mutate(valid_data = ifelse(is.na(period_days), FALSE, TRUE)) %>%
  #   select(-period_days)

  message(' done')

  #######################################
  #  Varset Definition & Aggregation    #
  #######################################

  ##TODO Need to re-write this section so that I can
  ##take a functional approach to the "summarise" portion
  ##of our workflow

  ##should have a function that works something like

  pcv_performance_monitoring <- measurement_group$new()

  message('building and aggregating varsets', appendLF = FALSE)

  measurement_single_value$new(metric_key = 'period_days'
                               ,group_key = 'id_organization'
                               ,measurement_name = 'Expected Time to Schedule'
                               ,measurement_format = 'days'
                               ,measurement_rounding = 1
                               ,join_variable_1 = referral_period_acceptance_to_schedule
                               ,join_variable_2 = referral_attr_id_organization
                               ,select_var = c('period_days', 'attr_values')
                               ,rename_var = c('period_days', 'id_organization')
                               ,data_out_type = 'identity'
                               ,summary_function = 'mean'
                               ,na_rm = TRUE) %>%
    pcv_performance_monitoring$measurement_add(.)

  message(' . ', appendLF = FALSE)

  # inner_join(referral_period_acceptance_to_schedule[[2]]
  #                                            ,referral_attr_id_organization
  #                                            ,by = 'id_referral_visit') %>%
  #   select(-id_referral_visit) %>%
  #   group_by(attr_values) %>%
  #   summarise_all(c("mean"), na.rm = TRUE) %>%
  #   measurement_single_value$new(.
  #                                   ,metric_key = 'period_days'
  #                                   ,group_key = 'attr_values'
  #                                   ,measurement_name = 'acceptance_to_schedule'
  #                                   ,measurement_format = 'days'
  #                                   ,measurement_rounding = 1
  #                                   ) %>%
  #   pcv_performance_monitoring$measurement_add(.)

  measurement_single_value$new(metric_key = 'met_target'
                               ,group_key = 'id_organization'
                               ,measurement_name = 'Expected Time to Schedule'
                               ,measurement_format = 'percent'
                               ,measurement_rounding = 0
                               ,join_variable_1 = referral_period_acceptance_to_schedule
                               ,join_variable_2 = referral_attr_id_organization
                               ,select_var = c('met_target', 'attr_values')
                               ,rename_var = c('met_target', 'id_organization')
                               ,data_out_type = c('performance', 'identity')
                               ,summary_function = 'mean'
                               ,na_rm = TRUE) %>%
    pcv_performance_monitoring$measurement_add(.)

  message(' . ', appendLF = FALSE)


#
#   inner_join(referral_period_acceptance_to_schedule[[1]]
#                                               ,referral_attr_id_organization
#                                               ,by = 'id_referral_visit') %>%
#     select(-id_referral_visit) %>%
#     group_by(attr_values) %>%
#     summarise_all(c("mean"), na.rm = TRUE) %>%
#     measurement_single_value$new(.
#                                     ,metric_key = 'met_target'
#                                     ,group_key = 'attr_values'
#                                     ,measurement_name = 'acceptance_to_schedule'
#                                     ,measurement_format = 'percent'
#                                     ,measurement_rounding = 0
#                                     ) %>%
#     pcv_performance_monitoring$measurement_add(.)

  measurement_single_value$new(metric_key = 'valid_data'
                               ,group_key = 'id_organization'
                               ,measurement_name = 'Expected Time to Schedule'
                               ,measurement_format = 'percent'
                               ,measurement_rounding = 0
                               ,join_variable_1 = referral_period_acceptance_to_schedule
                               ,join_variable_2 = referral_attr_id_organization
                               ,select_var = c('valid_data', 'attr_values')
                               ,rename_var = c('valid_data', 'id_organization')
                               ,data_out_type = c('quality', 'identity')
                               ,summary_function = 'mean'
                               ,na_rm = TRUE) %>%
    pcv_performance_monitoring$measurement_add(.)

  message(' . ', appendLF = FALSE)

  # inner_join(referral_period_acceptance_to_schedule_nas
  #            ,referral_attr_id_organization
  #            ,by = 'id_referral_visit') %>%
  #   select(-id_referral_visit) %>%
  #   group_by(attr_values) %>%
  #   summarise_all(c("mean")) %>%
  #   measurement_single_value$new(.
  #                                   ,metric_key = 'valid_data'
  #                                   ,group_key = 'attr_values'
  #                                   ,measurement_name = 'acceptance_to_schedule'
  #                                   ,measurement_format = 'percent'
  #                                   ,measurement_rounding = 0
  #   ) %>%
  #   pcv_performance_monitoring$measurement_add(.)


  measurement_single_value$new(metric_key = 'period_days'
                               ,group_key = 'id_organization'
                               ,measurement_name = 'Expected Time to First Planned Visit'
                               ,measurement_format = 'days'
                               ,measurement_rounding = 1
                               ,join_variable_1 = referral_period_acceptance_to_first_scheduled
                               ,join_variable_2 = referral_attr_id_organization
                               ,select_var = c('period_days', 'attr_values')
                               ,rename_var = c('period_days', 'id_organization')
                               ,data_out_type = 'identity'
                               ,summary_function = 'mean'
                               ,na_rm = TRUE) %>%
    pcv_performance_monitoring$measurement_add(.)

  message(' . ', appendLF = FALSE)

  # inner_join(referral_period_acceptance_to_first_scheduled[[2]]
  #                                               ,referral_attr_id_organization
  #                                               ,by = 'id_referral_visit') %>%
  #   select(-id_referral_visit) %>%
  #   group_by(attr_values) %>%
  #   summarise_all(c("mean"), na.rm = TRUE) %>%
  #   measurement_single_value$new(.
  #                                   ,metric_key = 'period_days'
  #                                   ,group_key = 'attr_values'
  #                                   ,measurement_name = 'acceptance_to_first_visit'
  #                                   ,measurement_format = 'days'
  #                                   ,measurement_rounding = 1
  #                                   ) %>%
  #   pcv_performance_monitoring$measurement_add(.)

  measurement_single_value$new(metric_key = 'met_target'
                               ,group_key = 'id_organization'
                               ,measurement_name = 'Expected Time to First Planned Visit'
                               ,measurement_format = 'percent'
                               ,measurement_rounding = 0
                               ,join_variable_1 = referral_period_acceptance_to_first_scheduled
                               ,join_variable_2 = referral_attr_id_organization
                               ,select_var = c('met_target', 'attr_values')
                               ,rename_var = c('met_target', 'id_organization')
                               ,data_out_type = c('performance', 'identity')
                               ,summary_function = 'mean'
                               ,na_rm = TRUE) %>%
    pcv_performance_monitoring$measurement_add(.)

  message(' . ', appendLF = FALSE)

  # inner_join(referral_period_acceptance_to_first_scheduled[[1]]
  #                                                   ,referral_attr_id_organization
  #                                                   ,by = 'id_referral_visit') %>%
  #   select(-id_referral_visit) %>%
  #   group_by(attr_values) %>%
  #   summarise_all(c("mean"), na.rm = TRUE) %>%
  #   measurement_single_value$new(.
  #                                   ,metric_key = 'met_target'
  #                                   ,group_key = 'attr_values'
  #                                   ,measurement_name = 'acceptance_to_first_visit'
  #                                   ,measurement_format = 'percent'
  #                                   ,measurement_rounding = 0
  #                                   ) %>%
  #   pcv_performance_monitoring$measurement_add(.)

  measurement_single_value$new(metric_key = 'valid_data'
                               ,group_key = 'id_organization'
                               ,measurement_name = 'Expected Time to First Planned Visit'
                               ,measurement_format = 'percent'
                               ,measurement_rounding = 0
                               ,join_variable_1 = referral_period_acceptance_to_first_scheduled
                               ,join_variable_2 = referral_attr_id_organization
                               ,select_var = c('valid_data', 'attr_values')
                               ,rename_var = c('valid_data', 'id_organization')
                               ,data_out_type = c('quality', 'identity')
                               ,summary_function = 'mean'
                               ,na_rm = TRUE) %>%
    pcv_performance_monitoring$measurement_add(.)

  message(' . ', appendLF = FALSE)

  #### CURRENTLY THE ONLY METRIC RUNNING ON THE "NEW" METHOD OF AGGREGATION" #####
  measurement_single_value$new(metric_key = 'attr_child_count'
                               ,group_key = 'id_organization'
                               ,measurement_name = 'Children per Referral'
                               ,measurement_format = 'numeric'
                               ,measurement_rounding = 1
                               ,join_variable_1 = referral_attr_child_count
                               ,join_variable_2 = referral_attr_id_organization
                               ,select_var = c('attr_values.x', 'attr_values.y')
                               ,rename_var = c('attr_child_count', 'id_organization')
                               ,data_out_type = 'identity'
                               ,summary_function = 'mean'
                               ,na_rm = TRUE) %>%
    pcv_performance_monitoring$measurement_add(.)

  message(' . ', appendLF = FALSE)

  ################################################################################

  # inner_join(referral_attr_child_count
  #                                 ,referral_attr_id_organization
  #                                 ,by = 'id_referral_visit') %>%
  #   rename(attr_child_count = attr_values.x
  #          ,id_organization = attr_values.y) %>%
  #   select(-id_referral_visit) %>%
  #   group_by(id_organization) %>%
  #   summarise_all(c("mean"), na.rm = TRUE) %>%
  #   measurement_single_value$new(.
  #                                   ,metric_key = 'attr_child_count'
  #                                   ,group_key = 'id_organization'
  #                                   ,measurement_name = 'child_count_value'
  #                                   ,measurement_format = 'numeric'
  #                                   ,measurement_rounding = 1
  #                                   ) %>%
  #   pcv_performance_monitoring$measurement_add(.)

  measurement_single_value$new(metric_key = 'attr_visit_attendance'
                               ,group_key = 'id_organization'
                               ,measurement_name = 'Visit Attendance Rate'
                               ,measurement_format = 'percent'
                               ,measurement_rounding = 0
                               ,join_variable_1 = referral_visit_attendance
                               ,join_variable_2 = referral_attr_id_organization
                               ,select_var = c('attr_values.x', 'attr_values.y')
                               ,rename_var = c('attr_visit_attendance', 'id_organization')
                               ,data_out_type = c('identity')
                               ,summary_function = 'mean'
                               ,na_rm = TRUE) %>%
    pcv_performance_monitoring$measurement_add(.)

  message(' . ', appendLF = FALSE)

  # inner_join(referral_visit_attendance
  #            ,referral_attr_id_organization
  #            ,by = 'id_referral_visit') %>%
  #   rename(attr_visit_attendance = attr_values.x
  #          ,id_organization = attr_values.y) %>%
  #  select(-id_referral_visit) %>%
  #  group_by(id_organization) %>%
  #  summarise_all(c("mean"), na.rm = TRUE) %>%
    # measurement_single_value$new(.
    #                                 ,metric_key = 'attr_visit_attendance'
    #                                 ,group_key = 'id_organization'
    #                                 ,measurement_name = 'attendance_per_scheduled_visit'
    #                                 ,measurement_format = 'percent'
    #                                 ,measurement_rounding = 0
    # ) %>%
    # pcv_performance_monitoring$measurement_add(.)

  message(' done')

  message('saving objects to file. ', appendLF = FALSE)

  file_path <- paste0(system.file('extdata'
                                  ,package = 'oliveR')
                      ,'/'
                      ,lazyeval::expr_text(pcv_performance_monitoring)
  )

  saveRDS(object = pcv_performance_monitoring
          ,file = file_path)

  message(paste0(' '
                 ,ifelse(file.exists(file_path), 'done', 'warning file does not exist'))
  )

}