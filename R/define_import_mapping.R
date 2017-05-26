define_import_mapping <- function(tribble_out = 'import'){
  import <- tribble(
    ~f, ~params
    ,'import_referral_acceptance_events', list(con = con
                                               ,output_name = 'tbl_referral_acceptance_events'
                                               ,measurement_window = measurement_window
                                               ,measurement_window_start = measurement_window_start
                                               ,tz = tz
    )
    ,'import_referral_child_record_count', list(con = con
                                                ,output_name = 'tbl_referral_child_record_count'
                                                ,measurement_window = measurement_window
                                                ,measurement_window_start = measurement_window_start
                                                ,tz = tz
    )
    ,'import_visits_initial_as_scheduled', list(con = con
                                                ,output_name = 'tbl_visits_initial_as_scheduled'
                                                ,measurement_window = measurement_window
                                                ,measurement_window_start = measurement_window_start
                                                ,tz = tz
    )
    ,'import_referral_organization', list(con = con
                                          ,output_name = 'tbl_referral_organization'
                                          ,measurement_window = measurement_window
                                          ,measurement_window_start = measurement_window_start
                                          ,tz = tz
    )
    ,'import_visit_reports', list(con = con
                                  ,output_name = 'tbl_visit_reports'
                                  ,measurement_window = measurement_window
                                  ,measurement_window_start = measurement_window_start
                                  ,tz = tz
    )
    ,'import_referral_acceptance_events', list(con = con
                                               ,output_name = 'tbl_referral_acceptance_events'
                                               ,measurement_window = measurement_window
                                               ,measurement_window_start = measurement_window_start
                                               ,tz = tz
    )
  )

  assign(x = tribble_out
         ,value = import
         ,pos = 1)

}