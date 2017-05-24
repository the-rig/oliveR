build_all_metrics <- function(
    dbname = Sys.getenv("OLIVER_REPLICA_DBNAME"),
    host = Sys.getenv("OLIVER_REPLICA_HOST"),
    user = Sys.getenv("OLIVER_REPLICA_USER"),
    password = Sys.getenv("OLIVER_REPLICA_PASSWORD"),
    port = Sys.getenv("OLIVER_REPLICA_PORT"),
    jitter = Sys.getenv("OLIVER_REPLICA_JITTER"),
    measurement_window = 180,
    measurement_window_start = 20170301,
    tz = 'America/Los_Angeles',
    import_fncs = list(import_referral_child_record_count
                        ,import_visits_initial_as_sceduled
                        ,import_referral_scheduling_events
                        ,import_referral_organization
                        ,import_visit_reports
                        ,import_referral_acceptance_events
    )
)
{
  con <- src_postgres(
    dbname = dbname,
    host = host,
    user = user,
    password = password,
    port = port
  )

  lapply(X = import_fncs
         ,FUN = do.call
         ,list(con = con
               ,measurement_window = measurement_window
               ,measurement_window_start = measurement_window_start
               ,tz = tz
               )

         )


  # message('importing data', appendLF = FALSE)
  #
  # import_referral_child_record_count(con = con)
  #
  # message(' .', appendLF = FALSE)
  #
  # import_visits_initial_as_sceduled(con = con)
  #
  # message(' .', appendLF = FALSE)
  #
  # import_referral_scheduling_events(con = con)
  #
  # message(' .', appendLF = FALSE)
  #
  # import_referral_organization(con = con)
  #
  # message(' .', appendLF = FALSE)
  #
  # import_visit_reports(con = con
  #                      , measurement_window = measurement_window
  #                      , measurement_window_start = measurement_window_start
  #                      , tz = tz)
  #
  # message(' .', appendLF = FALSE)
  #
  # import_referral_acceptance_events(con = con
  #                                   , measurement_window = measurement_window
  #                                   , measurement_window_start = measurement_window_start
  #                                   , tz = tz)
  #
  # message(' done')

  referral_attr_id_organization <- define_var_attribute(data = tbl_referral_organization
                                                        ,id = 'id_referral_visit'
                                                        ,value = 'id_organization'
                                                        ,jitter = FALSE)

  referral_attr_child_count <- define_var_attribute(tbl_referral_child_record_count
                                                    ,id = 'id_referral_visit'
                                                    ,value = 'child_count_attr'
                                                    ,jitter = jitter)

  referral_visit_attendance <- define_var_attribute(tbl_visit_reports
                                                    ,id = 'id_referral_visit'
                                                    ,value = 'visitation_attended'
                                                    ,jitter = jitter)

  ## Define Events

  referral_event_acceptance <- define_var_event(tbl_referral_acceptance_events
                                                ,'id_referral_visit'
                                                ,'dt_referral_acceptance')


  referral_event_scheduling <- define_var_event(tbl_referral_scheduling_events
                                                ,'id_referral_visit'
                                                ,'dt_referral_scheduled')

  referral_event_first_scheduled_visit <- define_var_event(tbl_visits_initial_as_sceduled
                                                           ,'id_referral_visit'
                                                           ,'dt_scheduled_visit_initial')


  ## Define Periods

  referral_period_acceptance_to_schedule <- define_var_period(
    event_start_tibble = referral_event_acceptance
    ,event_stop_tibble = referral_event_scheduling
    ,event_start_var = 'dt_referral_acceptance'
    ,event_stop_var = 'dt_referral_scheduled'
    ,id = 'id_referral_visit'
    ,exclusions = list_holidays_and_weekends()
    ,period_name = 'acceptance_to_schedule'
    ,period_target = 3
    ,jitter = jitter
  )

  referral_period_acceptance_to_first_scheduled <- define_var_period(
    event_start_tibble = referral_event_acceptance
    ,event_stop_tibble = referral_event_first_scheduled_visit
    ,event_start_var = 'dt_referral_acceptance'
    ,event_stop_var = 'dt_scheduled_visit_initial'
    ,id = 'id_referral_visit'
    ,exclusions = list_holidays_and_weekends()
    ,period_name = 'acceptance_to_first_scheduled'
    ,period_target = 7
    ,jitter = jitter
  )

  ## Define *Variable* Attributes

  referral_period_acceptance_to_schedule_nas <- referral_period_acceptance_to_schedule[[2]] %>%
    mutate(valid_data = ifelse(is.na(period_days), FALSE, TRUE)) %>%
    select(-period_days)

  referral_period_acceptance_to_first_scheduled_nas <- referral_period_acceptance_to_first_scheduled[[2]] %>%
    mutate(valid_data = ifelse(is.na(period_days), FALSE, TRUE)) %>%
    select(-period_days)


  message(' complete')

  #######################################
  #  Varset Definition & Aggregation    #
  #######################################

  pcv_performance_monitoring <- measurement_group$new()

  message('building and aggregating varsets...', appendLF = FALSE)

  inner_join(referral_period_acceptance_to_schedule[[2]]
                                             ,referral_attr_id_organization
                                             ,by = 'id_referral_visit') %>%
    select(-id_referral_visit) %>%
    group_by(attr_values) %>%
    summarise_all(c("mean"), na.rm = TRUE) %>%
    measurement_single_value$new(.
                                    ,metric_key = 'period_days'
                                    ,group_key = 'attr_values'
                                    ,measurement_name = 'acceptance_to_schedule'
                                    ,measurement_format = 'numeric'
                                    ,measurement_rounding = 1
                                    ) %>%
    pcv_performance_monitoring$measurement_add(.)

  inner_join(referral_period_acceptance_to_schedule[[1]]
                                              ,referral_attr_id_organization
                                              ,by = 'id_referral_visit') %>%
    select(-id_referral_visit) %>%
    group_by(attr_values) %>%
    summarise_all(c("mean"), na.rm = TRUE) %>%
    measurement_single_value$new(.
                                    ,metric_key = 'met_target'
                                    ,group_key = 'attr_values'
                                    ,measurement_name = 'acceptance_to_schedule'
                                    ,measurement_format = 'percent'
                                    ,measurement_rounding = 0
                                    ) %>%
    pcv_performance_monitoring$measurement_add(.)

  inner_join(referral_period_acceptance_to_schedule_nas
             ,referral_attr_id_organization
             ,by = 'id_referral_visit') %>%
    select(-id_referral_visit) %>%
    group_by(attr_values) %>%
    summarise_all(c("mean")) %>%
    measurement_single_value$new(.
                                    ,metric_key = 'valid_data'
                                    ,group_key = 'attr_values'
                                    ,measurement_name = 'acceptance_to_schedule'
                                    ,measurement_format = 'percent'
                                    ,measurement_rounding = 0
    ) %>%
    pcv_performance_monitoring$measurement_add(.)

  inner_join(referral_period_acceptance_to_first_scheduled[[2]]
                                                ,referral_attr_id_organization
                                                ,by = 'id_referral_visit') %>%
    select(-id_referral_visit) %>%
    group_by(attr_values) %>%
    summarise_all(c("mean"), na.rm = TRUE) %>%
    measurement_single_value$new(.
                                    ,metric_key = 'period_days'
                                    ,group_key = 'attr_values'
                                    ,measurement_name = 'acceptance_to_first_visit'
                                    ,measurement_format = 'numeric'
                                    ,measurement_rounding = 1
                                    ) %>%
    pcv_performance_monitoring$measurement_add(.)

  inner_join(referral_period_acceptance_to_first_scheduled[[1]]
                                                    ,referral_attr_id_organization
                                                    ,by = 'id_referral_visit') %>%
    select(-id_referral_visit) %>%
    group_by(attr_values) %>%
    summarise_all(c("mean"), na.rm = TRUE) %>%
    measurement_single_value$new(.
                                    ,metric_key = 'met_target'
                                    ,group_key = 'attr_values'
                                    ,measurement_name = 'acceptance_to_first_visit'
                                    ,measurement_format = 'percent'
                                    ,measurement_rounding = 0
                                    ) %>%
    pcv_performance_monitoring$measurement_add(.)

  inner_join(referral_period_acceptance_to_first_scheduled_nas
             ,referral_attr_id_organization
             ,by = 'id_referral_visit') %>%
    select(-id_referral_visit) %>%
    group_by(attr_values) %>%
    summarise_all(c("mean")) %>%
    measurement_single_value$new(.
                                    ,metric_key = 'valid_data'
                                    ,group_key = 'attr_values'
                                    ,measurement_name = 'acceptance_to_first_visit'
                                    ,measurement_format = 'percent'
                                    ,measurement_rounding = 0
    ) %>%
    pcv_performance_monitoring$measurement_add(.)

  inner_join(referral_attr_child_count
                                  ,referral_attr_id_organization
                                  ,by = 'id_referral_visit') %>%
    rename(attr_child_count = attr_values.x
           ,id_organization = attr_values.y) %>%
    select(-id_referral_visit) %>%
    group_by(id_organization) %>%
    summarise_all(c("mean"), na.rm = TRUE) %>%
    measurement_single_value$new(.
                                    ,metric_key = 'attr_child_count'
                                    ,group_key = 'id_organization'
                                    ,measurement_name = 'child_count_value'
                                    ,measurement_format = 'numeric'
                                    ,measurement_rounding = 1
                                    ) %>%
    pcv_performance_monitoring$measurement_add(.)

  inner_join(referral_visit_attendance
             ,referral_attr_id_organization
             ,by = 'id_referral_visit') %>%
    rename(attr_visit_attendance = attr_values.x
           ,id_organization = attr_values.y) %>%
    select(-id_referral_visit) %>%
    group_by(id_organization) %>%
    summarise_all(c("mean"), na.rm = TRUE) %>%
    measurement_single_value$new(.
                                    ,metric_key = 'attr_visit_attendance'
                                    ,group_key = 'id_organization'
                                    ,measurement_name = 'attendance_per_scheduled_visit'
                                    ,measurement_format = 'percent'
                                    ,measurement_rounding = 0
    ) %>%
    pcv_performance_monitoring$measurement_add(.)

  message(' complete')

  message('saving objects to file. file exists?...', appendLF = FALSE)

  file_path <- paste0(system.file('extdata'
                                  ,package = 'oliveR')
                      ,'/'
                      ,lazyeval::expr_text(pcv_performance_monitoring)
  )

  saveRDS(object = pcv_performance_monitoring
          ,file = file_path)

  message(paste0(' '
                 ,file.exists(file_path))
  )

}