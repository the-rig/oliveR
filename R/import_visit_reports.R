import_visit_reports <- function(con
                                 #,output_name = 'tbl_visit_reports'
                                 ,measurement_window
                                 ,measurement_window_start
                                 ,tz) {

  dbSendQuery(con$con, build_sql("SET search_path TO ", 'staging'))

  suppressWarnings(
    tbl_service_referrals <- tbl(con, 'ServiceReferrals') %>%
    select(id
           ,organizationId
           ,isCurrentVersion
           ,deletedAt) %>%
    rename(serviceReferralId = id) %>%
    filter(isCurrentVersion
           ,is.na(deletedAt)) %>%
    select(-isCurrentVersion, -deletedAt) %>%
    as_data_frame()
  )

  suppressWarnings(
  tbl_visit_reports_raw_prep <- tbl(con, 'VisitReports') %>%
    select(id
           ,serviceReferralId
           ,cancellationType
           ,isCurrentVersion
           ,deletedAt
           ,approvedAt
           ,dateNormalized) %>%
    as_data_frame()
  )

  suppressWarnings(
    tbl_visit_reports_raw <- tbl_visit_reports_raw_prep %>%
    filter(isCurrentVersion
           # the following two restrictions were in M. Wood's original code. They
           # no longer appear to be needed though.
           #,is.na(deletedAt)
           #,!is.na(approvedAt)
           ,dateNormalized > (lubridate::now(tzone = tz) - lubridate::days(measurement_window))
           ,dateNormalized > lubridate::ymd(measurement_window_start)
   )
  )

  tbl_visit_reports <- inner_join(tbl_service_referrals
                                  ,tbl_visit_reports_raw
                                  ,by = 'serviceReferralId') %>%
    mutate(visitation_attended = ifelse(is.na(cancellationType), TRUE, FALSE)
           ,id_referral_visit = serviceReferralId)

  return(tbl_visit_reports)

  # assign(x = output_name
  #        ,value = tbl_visit_reports
  #        ,pos = 1)

}
