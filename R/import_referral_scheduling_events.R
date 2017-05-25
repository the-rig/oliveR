import_referral_scheduling_events <- function(con
                                              ,output_name = 'tbl_referral_scheduling_events'
                                              ,measurement_window
                                              ,measurement_window_start
                                              ,tz) {

  #dbSendQuery(con$con, build_sql("SET search_path TO ", 'staging'))

  # get the first date that a referral was scheduled
  suppressWarnings(
  tbl_first_referral_scheduling_ver_min <- tbl(con, 'ServiceReferrals') %>%
    select(id
           ,versionId
           ,referralState
           ,requestDateNormalized) %>%
    filter(referralState == 'Scheduled'
           ,!is.na(requestDateNormalized)) %>%
    group_by(id) %>%
    summarise(versionId = min(versionId))
)

  suppressWarnings(
  tbl_referral_scheduling_events <- tbl(con, 'ServiceReferrals') %>%
    inner_join(tbl_first_referral_scheduling_ver_min, by = c("versionId", "id")) %>%
    select(id
           ,referralReason
           ,updatedAt) %>%
    filter(referralReason == 'Initial') %>%
    rename(id_referral_visit = id
           ,dt_referral_scheduled = updatedAt) %>%
    as_data_frame()
)

  #return(tbl_referral_scheduling_events)

  assign(x = output_name
         ,value = tbl_referral_scheduling_events
         ,pos = 1)

}
