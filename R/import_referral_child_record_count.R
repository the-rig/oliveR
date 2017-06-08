import_referral_child_record_count <- function(con
                                              #,output_name = 'tbl_referral_child_record_count'
                                              ,measurement_window
                                              ,measurement_window_start
                                              ,tz) {

  dbSendQuery(con$con, build_sql("SET search_path TO ", 'staging'))

  tbl_referral_child_record_count <- dbGetQuery(con$con
                                      ,'
                                      select
                                      id id_referral_visit
                                      ,row_number () over (
                                      partition by id
                                      order by
                                      json_array_elements(\"childDetails\") ->> \'childAge\'::text
                                      ,json_array_elements(\"childDetails\") ->> \'childDob\'::text
                                      ,json_array_elements(\"childDetails\") ->> \'childLastName\'::text
                                      ,json_array_elements("childDetails") ->> \'childFirstName\'::text
                                      ) as child_record
                                      from \"ServiceReferrals\" s
                                      where \"isCurrentVersion\" = TRUE
                                      and \"deletedAt\" IS NULL
                                      and \"referralReason\" = \'Initial\'
                                      ') %>%
    group_by(id_referral_visit) %>%
    summarise(child_count_attr = max(child_record)) %>%
    as_data_frame()

  return(tbl_referral_child_record_count)

  # assign(x = output_name
  #        ,value = tbl_referral_child_record_count
  #        ,pos = 1)

}
