import_visits_initial_as_scheduled <- function(con
                                              #,output_name = 'tbl_visits_initial_as_sceduled'
                                              ,measurement_window
                                              ,measurement_window_start
                                              ,tz) {

  dbSendQuery(con$con, build_sql("SET search_path TO ", 'staging'))

  tbl_scheduling_events <- dbGetQuery(con$con
                                      ,'
                                      select
                                      id id_referral_visit
                                      ,(json_array_elements(\"visitSchedule\") ->> \'visitStartDate\'::text)::date visitStartDate
                                      from \"ServiceReferrals\"
                                      where \"isCurrentVersion\" = TRUE
                                      and \"deletedAt\" IS NULL
                                      and \"referralReason\" = \'Initial\'
                                      ')

  tbl_scheduling_events_initial <- tbl_scheduling_events %>%
    group_by(id_referral_visit) %>%
    summarise(dt_scheduled_visit_initial = min(visitstartdate)) %>%
    as_data_frame()

  # we first make a table which containes all of the visitSchedule information (from the ServiceReferrals table)
  # we filter this table to ensure that the referrals is the most current version, has not been deleted, and is
  # an 'Initial' referral

  # we then select the first scheduled visit from across all referral versions.

  return(tbl_scheduling_events_initial)

  # assign(x = output_name
  #        ,value = tbl_scheduling_events_initial
  #        ,pos = 1)

}
