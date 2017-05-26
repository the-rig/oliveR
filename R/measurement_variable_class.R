# library(R6)
#
# # IN DEVELOPMENT
#
# # referral_event_acceptance <- define_var_event(tbl_referral_acceptance_events
# #                                               ,'id_referral_visit'
# #                                               ,'dt_referral_acceptance')
# #
# # referral_event_scheduling <- define_var_event(tbl_referral_scheduling_events
# #                                               ,'id_referral_visit'
# #                                               ,'dt_referral_scheduled')
# #
# # referral_event_first_scheduled_visit <- define_var_event(tbl_visits_initial_as_sceduled
# #                                                          ,'id_referral_visit'
# #                                                          ,'dt_scheduled_visit_initial')
# #
# #
# # import_referral_acceptance_events(output_name = 'tbl_referral_acceptance_events'
# #                                   ,con = con
# #                                   ,measurement_window = measurement_window
# #                                   ,measurement_window_start = measurement_window_start)
#
# measurement_variable <- R6Class("measurement_variable"
#                                 ,portable = FALSE
#                                 ,lock_objects = FALSE
#                   ,public = list(
#                     name = NULL
#                     ,import_fnc = NULL
#                     ,dbname = NA
#                     ,host = NA
#                     ,user = NA
#                     ,password = NA
#                     ,port = NA
#                     ,jitter = NA
#                     ,exclusions = NA
#                     ,measurement_window = NA
#                     ,measurement_window_start = NA
#                     ,tz = NA
#                     ,con = NULL
#                     #import function producing a datafram, or possibly a data frame, or possibly a list of data frames in the case of period variables
#                     ,type = NULL
#                     #one of attr, event, or period
#                     ,id_col = NULL
#                     ,value_col1 = NULL
#                     ,value_col2 = NULL
#                     #logical indicating whether or not we want to jitter the values
#                     ,target = NULL
#                     # a performance target for the variable
#                     ,na_attr = NULL
#                     # a logical indicating whether or not to calculate a logical table for na values. This currently serves as the basis of our data quality metric
#                     ,data_out = NULL
#                     ,initialize = function(name = NA
#                                           ,data_in = NA
#                                           #,data_in_name = 'tbl_referral_acceptance_events'
#                                           ,dbname = Sys.getenv("OLIVER_REPLICA_DBNAME")
#                                           ,host = Sys.getenv("OLIVER_REPLICA_HOST")
#                                           ,user = Sys.getenv("OLIVER_REPLICA_USER")
#                                           ,password = Sys.getenv("OLIVER_REPLICA_PASSWORD")
#                                           ,port = Sys.getenv("OLIVER_REPLICA_PORT")
#                                           ,jitter = Sys.getenv("OLIVER_REPLICA_JITTER")
#                                           ,exclusions = list_holidays_and_weekends()
#                                           ,measurement_window = 180
#                                           ,measurement_window_start = 20170301
#                                           ,tz = 'America/Los_Angeles'
#                                           ,type = NA
#                                           ,id_col = NA
#                                           ,value_col1 = NA
#                                           ,value_col2 = NA
#                                           ,target = NA
#                                           ,na_attr = NA) {
#                       self$name <- name
#                       self$data_in <- data_in
#                       self$type <- type
#                       self$id_col <- id_col
#                       self$value_col1 <- value_col1
#                       self$value_col2 <- value_col2
#                       self$jitter <- jitter
#                       self$exclusions <- exclusions
#                       self$target <- target
#                       self$na_attr <- na_attr
#                       self$con <- src_postgres(
#                         dbname = dbname,
#                         host = host,
#                         user = user,
#                         password = password,
#                         port = port
#                       )
#                       self$measurement_window <- measurement_window
#                       self$measurement_window_start <- measurement_window_start
#                       self$tz <- tz
#                       self$data_in <- do.call(self$data_in
#                               ,args = list(con = self$con
#                                            #,output_name = self$data_in_name
#                                            ,measurement_window = self$measurement_window
#                                            ,measurement_window_start = self$measurement_window_start
#                                            ,tz = self$tz
#                                            ))
#                       # need to map jitter down to this function
#                       if (self$type == 'event'){
#                         self$data_out <- define_var_event(data = self$data_in
#                                                           ,id = self$id_col
#                                                           ,value_date = self$value_col1)
#                       } else if (self$type == 'attr'){
#                         self$data_out <- define_var_attribute(data = self$data_in
#                                                               ,id = self$id_col
#                                                               ,value = self$value_col1
#                                                               ,jitter = self$jitter)
#                       } else if (self$type == 'period'){
#                         self$data_out <- define_var_period(event_start_tibble = self$data_in[[1]]
#                                                            ,event_stop_tibble = self$data_in[[2]]
#                                                            ,event_start_var = self$value_col1
#                                                            ,event_stop_var = self$value_col2
#                                                            ,id = self$id_col
#                                                            ,exclusions = list_holidays_and_weekends()
#                                                            ,period_name = self$name
#                                                            ,period_target = self$target
#                                                            ,jitter = self$jitter
#                         )
#                       }
#                     }
#                   )
# )
#
# referral_event_acceptance <- measurement_variable$new(name = 'referral_event_acceptance'
#                                                       ,data_in = import_referral_acceptance_events
#                                                       ,type = 'event'
#                                                       ,id_col = 'id_referral_visit'
#                                                       ,value_col1 = 'dt_referral_acceptance')
#
# referral_attr_id_organization <- measurement_variable$new(name = 'referral_attr_id_organization'
#                                                           ,data_in = import_referral_organization
#                                                           ,type = 'attr'
#                                                           ,id_col = 'id_referral_visit'
#                                                           ,value_col1 = 'id_organization')
#
#
#
#
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
#
# referral_event_scheduling <- define_var_event(tbl_referral_scheduling_events
#                                               ,'id_referral_visit'
#                                               ,'dt_referral_scheduled')
#
# referral_event_first_scheduled_visit <- define_var_event(tbl_visits_initial_as_sceduled
#                                                          ,'id_referral_visit'
#                                                          ,'dt_scheduled_visit_initial')
#
#
# ## Define Periods
#
# referral_period_acceptance_to_schedule <- define_var_period(
#   event_start_tibble = referral_event_acceptance
#   ,event_stop_tibble = referral_event_scheduling
#   ,event_start_var = 'dt_referral_acceptance'
#   ,event_stop_var = 'dt_referral_scheduled'
#   ,id = 'id_referral_visit'
#   ,exclusions = list_holidays_and_weekends()
#   ,period_name = 'acceptance_to_schedule'
#   ,period_target = 3
#   ,jitter = jitter
# )
#
# referral_period_acceptance_to_first_scheduled <- define_var_period(
#   event_start_tibble = referral_event_acceptance
#   ,event_stop_tibble = referral_event_first_scheduled_visit
#   ,event_start_var = 'dt_referral_acceptance'
#   ,event_stop_var = 'dt_scheduled_visit_initial'
#   ,id = 'id_referral_visit'
#   ,exclusions = list_holidays_and_weekends()
#   ,period_name = 'acceptance_to_first_scheduled'
#   ,period_target = 7
#   ,jitter = jitter
# )
#
# ## Define *Variable* Attributes
#
# referral_period_acceptance_to_schedule_nas <- referral_period_acceptance_to_schedule[[2]] %>%
#   mutate(valid_data = ifelse(is.na(period_days), FALSE, TRUE)) %>%
#   select(-period_days)
#
# referral_period_acceptance_to_first_scheduled_nas <- referral_period_acceptance_to_first_scheduled[[2]] %>%
#   mutate(valid_data = ifelse(is.na(period_days), FALSE, TRUE)) %>%
#   select(-period_days)
#
