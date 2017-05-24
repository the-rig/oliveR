import_visits_initial_as_sceduled <- function(con
                                              ,output_name = 'tbl_visits_initial_as_sceduled'
                                              ,measurement_window
                                              ,measurement_window_start
                                              ,tz) {

  #dbSendQuery(con$con, build_sql("SET search_path TO ", 'staging'))

  tbl_scheduling_events <- dbGetQuery(con$con
                                      ,'
                                      select
                                      id id_referral_visit
                                      ,(json_array_elements(\"visitSchedule\") ->> \'visitStartDateNormalized\'::text)::date visitStartDateNormalized
                                      from \"ServiceReferrals\"
                                      where \"isCurrentVersion\" = TRUE
                                      and \"deletedAt\" IS NULL
                                      and \"referralReason\" = \'Initial\'
                                      ')

  tbl_scheduling_events_initial <- tbl_scheduling_events %>%
    group_by(id_referral_visit) %>%
    summarise(dt_scheduled_visit_initial = min(visitstartdatenormalized)) %>%
    as_data_frame()

  assign(x = output_name
         ,value = tbl_scheduling_events_initial
         ,pos = 1)

}
