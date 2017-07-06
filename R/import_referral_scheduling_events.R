import_referral_scheduling_events <- function(con
                                              #,output_name = 'tbl_referral_scheduling_events'
                                              ,measurement_window
                                              ,measurement_window_start
                                              ,tz) {

  dbSendQuery(con$con, build_sql("SET search_path TO ", 'staging'))


  # using the ServiceReferrals table...
  # we select all referral versions where the referalState was equal to Scheduled, and where the request date is valid
  # we then select the first version of those "Scheduled" referrals.

  suppressWarnings(
  tbl_first_referral_scheduling_ver_min <- tbl(con, 'ServiceReferrals') %>%
    select(id
           ,versionId
           ,referralState
           ,requestDate) %>%
    filter(referralState == 'Scheduled'
           ,!is.na(requestDate)) %>%
    group_by(id) %>%
    summarise(versionId = min(versionId))
)

  # using the ServiceReferrals table...
  # we also select those referrals where the referral reason is 'Initial'
  # finally, we ensure that we only have those initial referrals where
  # we have an associated 'scheduled' referral version as selected above.

  suppressWarnings(
  tbl_referral_scheduling_events_prep <- tbl(con, 'ServiceReferrals') %>%
    inner_join(tbl_first_referral_scheduling_ver_min, by = c("versionId", "id")) %>%
    select(id
           ,referralReason
           ,updatedAt) %>%
    filter(referralReason == 'Initial') %>%
    as_data_frame()
  )

  suppressWarnings(
    tbl_referral_scheduling_events_prep %>%
    rename(id_referral_visit = id
           ,dt_referral_scheduled = updatedAt) -> tbl_referral_scheduling_events
)

  # the resulting table contains the first time a referral was switched to the 'scheduled' state
  # where the referralReason was of type "Initial"

  return(tbl_referral_scheduling_events)

  # assign(x = output_name
  #        ,value = tbl_referral_scheduling_events
  #        ,pos = 1)

}
