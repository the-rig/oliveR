library(R6)

# IN DEVELOPMENT

referral_event_acceptance <- define_var_event(tbl_referral_acceptance_events
                                              ,'id_referral_visit'
                                              ,'dt_referral_acceptance')

referral_event_scheduling <- define_var_event(tbl_referral_scheduling_events
                                              ,'id_referral_visit'
                                              ,'dt_referral_scheduled')

referral_event_first_scheduled_visit <- define_var_event(tbl_visits_initial_as_sceduled
                                                         ,'id_referral_visit'
                                                         ,'dt_scheduled_visit_initial')

referral_event_acceptance <- measurement_variable$new(name = 'referral_event_acceptance'
                                                       ,data_in = import_referral_acceptance_events
                                                       ,type = 'event'
                                                       ,id_col = 'id_referral_visit'
                                                       ,value_col1 = 'dt_referral_acceptance'
                                                       ,value_col2 = NA
                                                       ,jitter = FALSE
                                                       ,target = NA
                                                       ,na_attr = TRUE)

measurement_variable <- R6Class("measurement_variable"
                  ,public = list(
                    name = NULL
                    ,data_in = NULL
                    ,dbname = NA
                    ,host = NA
                    ,user = NA
                    ,password = NA
                    ,port = NA
                    ,jitter = NA
                    ,measurement_window = NA
                    ,measurement_window_start = NA
                    ,tz = NA
                    ,con = NULL
                    #import function producing a datafram, or possibly a data frame, or possibly a list of data frames in the case of period variables
                    ,type = NULL
                    #one of attr, event, or period
                    ,id_col = NULL
                    ,value_col1 = NULL
                    ,value_col2 = NULL
                    #logical indicating whether or not we want to jitter the values
                    ,target = NULL
                    # a performance target for the variable
                    ,na_attr = NULL
                    # a logical indicating whether or not to calculate a logical table for na values. This currently serves as the basis of our data quality metric
                    ,data_out = NULL
                    ,initialize = function(name = NA
                                          ,data_in = NA
                                          ,dbname = Sys.getenv("OLIVER_REPLICA_DBNAME")
                                          ,host = Sys.getenv("OLIVER_REPLICA_HOST")
                                          ,user = Sys.getenv("OLIVER_REPLICA_USER")
                                          ,password = Sys.getenv("OLIVER_REPLICA_PASSWORD")
                                          ,port = Sys.getenv("OLIVER_REPLICA_PORT")
                                          ,jitter = Sys.getenv("OLIVER_REPLICA_JITTER")
                                          ,measurement_window = 180
                                          ,measurement_window_start = 20170301
                                          ,tz = 'America/Los_Angeles'
                                          ,type = NA
                                          ,id_col = NA
                                          ,value_col1 = NA
                                          ,value_col2 = NA
                                          ,target = NA
                                          ,na_attr = NA) {
                      self$name <- name
                      self$type <- type
                      self$id_col <- id_col
                      self$value_col1 <- value_col1
                      self$value_col2 <- value_col2
                      self$jitter <- jitter
                      self$target <- target
                      self$na_attr <- na_attr
                      self$con <- src_postgres(
                        dbname = dbname,
                        host = host,
                        user = user,
                        password = password,
                        port = port
                      )
                    }
                    ,calculate_data_out = function() {
                      # need to map jitter down to this function
                      if (self$type == 'event'){
                        do.call(data, args = list(con = self$con))
                        self$data_out <- nrow(tbl_referral_child_record_count)
                        # self$data_out <- define_var_event(data = do.call(self$data_in
                        #                                                  ,list(con = self$con)
                        #                                                  )
                        #                                   ,id = self$id_col
                        #                                   ,value_date = self$value_col1)
                        self$data_out <- capture.output(self$con)
                      } else if (self$type == 'attr'){
                        # self$data_out <- define_var_attribute(data = self$data_in
                        #                                       ,id = self$id_col
                        #                                       ,value = self$value_col1
                        #                                       ,jitter = self$jitter)
                      } else if (self$type == 'period'){
                        self$data_out <- define_var_period(event_start_tibble = self$data_in[[1]]
                                                           ,event_stop_tibble = self$data_in[[2]]
                                                           ,event_start_var = self$value_col1
                                                           ,event_stop_var = self$value_col2
                                                           ,id = self$id_col
                                                           ,exclusions = list_holidays_and_weekends()
                                                           ,period_name = self$name
                                                           ,period_target = self$target
                                                           ,jitter = self$jitter
                                                           )
                      }
                    }
                  )
)


