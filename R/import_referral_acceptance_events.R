import_referral_acceptance_events <- function(con
                                              #,output_name = 'tbl_referral_acceptance_events'
                                              ,measurement_window
                                              ,measurement_window_start
                                              ,tz) {

  dbSendQuery(con$con, build_sql("SET search_path TO ", 'staging'))

  suppressWarnings(
    tbl_first_referral_requested_ver_max <- tbl(con, 'ServiceReferrals') %>%
      select(id
             ,versionId
             ,referralState
             ,requestDateNormalized) %>%
      filter(referralState == 'Requested'
             ,!is.na(requestDateNormalized)) %>%
      group_by(id) %>%
      summarise(versionId = max(versionId))
  )

  suppressWarnings(
    tbl_first_referral_accepted_ver_min <- tbl(con, 'ServiceReferrals') %>%
      select(id
             ,versionId
             ,referralState
             ,requestDateNormalized) %>%
      left_join(tbl_first_referral_requested_ver_max
                ,by = 'id') %>%
      filter(referralState == 'Accepted'
             ,!is.na(requestDateNormalized)
             ,versionId.x > coalesce(versionId.y, 1)) %>%
      group_by(id) %>%
      summarise(versionId = min(versionId.x))
  )

  suppressWarnings(
    tbl_referral_acceptance_events_prep <- tbl(con, 'ServiceReferrals') %>%
      select(id
             ,referralReason
             ,updatedAt
             ,versionId) %>%
      inner_join(tbl_first_referral_accepted_ver_min, by = c("id", "versionId")) %>%
      as_data_frame()
  )

  tbl_referral_acceptance_events <- tbl_referral_acceptance_events_prep %>%
      filter(updatedAt > (lubridate::now(tzone = tz) - lubridate::days(measurement_window))
              ,updatedAt > lubridate::ymd(measurement_window_start)
              ,referralReason == 'Initial'
      ) %>%
      select(-versionId) %>%
      rename(id_referral_visit = id
             ,dt_referral_acceptance = updatedAt) %>%
      as_data_frame()

  return(tbl_referral_acceptance_events)
#
#   assign(x = output_name
#          ,value = tbl_referral_acceptance_events
#          ,pos = 1)

}