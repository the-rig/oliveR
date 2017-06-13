import_referral_acceptance_events <- function(con
                                              #,output_name = 'tbl_referral_acceptance_events'
                                              ,measurement_window
                                              ,measurement_window_start
                                              ,tz) {

  dbSendQuery(con$con, build_sql("SET search_path TO ", 'staging'))

  # using the ServiceReferrals table...
  # 1. select the id, versionId, referralState, and the requestDateNormalized fields.
  # 2. we limit this table to those referrals where the state is "Requested" and where the date field is valid.
  # 3. we then select the latest "version" of this field
  # the result of this query is the most recent request date for a given referral id.

  # BACKGROUND - An accepted date can never be more than 6 months old

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

  # using the ServiceReferrals table...
  # 1. select the id, versionId, referralState, and the requestDateNormalized fields.
  # 2. we limit this table to those referrals where the state is "Accepted" and where the date field is valid.
  # 3. we further limit this table to those referrals which "match" the referrals from the "requested" referral table
  # 4. we further limit the table to those "Accepted" referrals which took place after the "latest" requests.
  # the result of this query is the first acceptance dates following the most recent request dates for a given referral id.

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

  # using the ServiceReferrals table...add the referralReason to our selection of columns.

  suppressWarnings(
    tbl_referral_acceptance_events_prep <- tbl(con, 'ServiceReferrals') %>%
      select(id
             ,referralReason
             ,updatedAt
             ,versionId) %>%
      inner_join(tbl_first_referral_accepted_ver_min, by = c("id", "versionId")) %>%
      as_data_frame()
  )

  # we then select only the referrals with referralReason == 'Initial'
  # we also apply the date restrictions as per agreed bounds (last 180 days and only after March 1)

  tbl_referral_acceptance_events <- tbl_referral_acceptance_events_prep %>%
      filter(updatedAt > (lubridate::now(tzone = tz) - lubridate::days(measurement_window))
              ,updatedAt > lubridate::ymd(measurement_window_start)
              ,referralReason == 'Initial'
      ) %>%
      select(-versionId) %>%
      rename(id_referral_visit = id
             ,dt_referral_acceptance = updatedAt) %>%
      as_data_frame()

  # the resulting table contains the first acceptance dates associated with the latest request date.
  # where the referralReason was of type "Initial"

  return(tbl_referral_acceptance_events)
#
#   assign(x = output_name
#          ,value = tbl_referral_acceptance_events
#          ,pos = 1)

}