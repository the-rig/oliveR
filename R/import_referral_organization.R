import_referral_organization <- function(con
                                              #,output_name = 'tbl_referral_organization'
                                         ,measurement_window
                                         ,measurement_window_start
                                         ,tz) {

  dbSendQuery(con$con, build_sql("SET search_path TO ", 'staging'))

  suppressWarnings(tbl_service_referrals <- tbl(con, 'ServiceReferrals') %>%
                     select(id
                            ,organizationId
                            ,isCurrentVersion
                            ,deletedAt) %>%
                     filter(isCurrentVersion == TRUE
                            ,is.na(deletedAt)) %>%
                     as_data_frame())

  suppressWarnings(tbl_organizations <- tbl(con, 'Organizations') %>% as_data_frame())

  suppressWarnings(
  tbl_referral_organization <- inner_join(tbl_service_referrals
               ,tbl_organizations
               ,by = c('organizationId' = 'id')) %>%
    rename(id_referral_visit = id
           ,id_organization = organizationId) %>%
    select(id_referral_visit
           ,id_organization
           ,name) %>%
    filter(name != 'Partners for Our Children'
           ,name != 'Family Impact Network') %>%
    as_data_frame()
  )

  return(tbl_referral_organization)

  # assign(x = output_name
  #        ,value = tbl_referral_organization
  #        ,pos = 1)

}
