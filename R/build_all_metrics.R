build_all_metrics <- function(
    dbname = Sys.getenv("OLIVER_REPLICA_DBNAME"),
    host = Sys.getenv("OLIVER_REPLICA_HOST"),    
    user = Sys.getenv("OLIVER_REPLICA_USER"),
    password = Sys.getenv("OLIVER_REPLICA_PASSWORD"),
    port = Sys.getenv("OLIVER_REPLICA_PORT"),    
    measurement_window = 180,
    measurement_window_start = 20170301,
    na.rm = TRUE
)
{
  con <- src_postgres(
    dbname = dbname,
    host = host,
    user = user,
    password = password,
    port = port
  )

  dbSendQuery(con$con, build_sql("SET search_path TO ", 'staging'))
  
  # for future use 
  #con <- oliver_replica_connect()
  
  ###########################################
  #ReferralAcceptedDate CTE is equivilant to#
  ###########################################
  
  # get the last date that a referral was requested
  message('tbl_first_referral_requested_ver_max...', appendLF = FALSE)
  
  tbl_first_referral_requested_ver_max <- tbl(con, 'ServiceReferrals') %>%
    select(id
           ,versionId
           ,referralState
           ,requestDateNormalized) %>%
    filter(referralState == 'Requested'
           ,!is.na(requestDateNormalized)) %>%
    group_by(id) %>%
    summarise(versionId = max(versionId))

  message(' complete')
  
  
  # get the first date that a referral was requested, among max request dates
  message('tbl_first_referral_accepted_ver_min...', appendLF = FALSE)
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
  message(' complete')
  
  message('tbl_referral_acceptance_events...', appendLF = FALSE)
  
  tbl_referral_acceptance_events <- tbl(con, 'ServiceReferrals') %>%
    select(id
           ,referralReason
           ,updatedAt
           ,versionId) %>%
    inner_join(tbl_first_referral_accepted_ver_min, by = c("id", "versionId")) %>%
    as_data_frame() %>%
    filter(updatedAt > (updatedAt - lubridate::days(measurement_window))
           ,updatedAt > lubridate::ymd(measurement_window_start)
           ,referralReason == 'Initial') %>%
    select(-versionId) %>%
    rename(id_referral_visit = id
           ,dt_referral_acceptance = updatedAt)

  message(' complete')
  
  ############################################
  #ReferralScheduledDate CTE is equivilant to#
  ############################################
  
  # get the first date that a referral was scheduled
  message('tbl_first_referral_scheduling_ver_min...', appendLF = FALSE)
  tbl_first_referral_scheduling_ver_min <- tbl(con, 'ServiceReferrals') %>%
    select(id
           ,versionId
           ,referralState
           ,requestDateNormalized) %>%
    filter(referralState == 'Scheduled'
           ,!is.na(requestDateNormalized)) %>%
    group_by(id) %>%
    summarise(versionId = min(versionId))

  message(' complete')
  
  
  message('tbl_referral_scheduling_events...', appendLF = FALSE)
  tbl_referral_scheduling_events <- tbl(con, 'ServiceReferrals') %>%
    inner_join(tbl_first_referral_scheduling_ver_min, by = c("versionId", "id")) %>%
    select(id
           ,referralReason
           ,updatedAt) %>%
    filter(referralReason == 'Initial') %>%
    rename(id_referral_visit = id
           ,dt_referral_scheduled = updatedAt)
  
  message(' complete')
  
  
  ##############################################
  #FirstScheduledVisitDate CTE is equivilant to#
  ##############################################
  
  # until dplyr gets better at parsing json fields
  # any measure elements which are dependent on json fields
  # will utilize raw SQL
  
  message('tbl_scheduling_events_initial...', appendLF = FALSE)
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
    summarise(dt_scheduled_visit_initial = min(visitstartdatenormalized))
  
  message(' complete')
  
  
  ###########################################
  #NumberOfChildrenOnSR CTE is equivilant to#
  ###########################################
  
  message('tbl_person_child_record_count...', appendLF = FALSE)
  
  tbl_person_child_record_count <- dbGetQuery(con$con
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
    summarise(child_count_attr = max(child_record))
  
  message(' complete')
  
  ################
  #Organizations #
  ################
  
  message('tbl_referral_organization...', appendLF = FALSE)
  
  tbl_referral_organization <- tbl(con, 'ServiceReferrals') %>%
    select(id
           ,organizationId
           ,isCurrentVersion
           ,deletedAt) %>%
    filter(isCurrentVersion == TRUE
           ,is.na(deletedAt)) %>%
    inner_join(tbl(con, 'Organizations'), by = c('organizationId' = 'id')) %>%
    rename(id_referral_visit = id.x
           ,id_organization = organizationId) %>%
    select(id_referral_visit
           ,id_organization
           ,name) %>%
    filter(name != 'Partners for Our Children')
  
  message(' complete')
  
  ##########################
  #  Variable Definitions  #
  ##########################
  
  message('building variable definitions...', appendLF = FALSE)
  
  ## Define Attributes
  
  referral_attr_id_organization <- define_var_attribute(data = tbl_referral_organization
                                                        ,population_member_id = 'id_referral_visit'
                                                        ,value = 'id_organization')
  
  
  referral_attr_child_count <- define_var_attribute(tbl_person_child_record_count
                                                    ,'id_referral_visit'
                                                    ,'child_count_attr')
  
  ## Define Events
  
  referral_event_acceptance <- define_var_event(tbl_referral_acceptance_events
                                                ,'id_referral_visit'
                                                ,'dt_referral_acceptance')
  
  
  referral_event_scheduling <- define_var_event(tbl_referral_scheduling_events
                                                ,'id_referral_visit'
                                                ,'dt_referral_scheduled')
  
  referral_event_first_scheduled_visit <- define_var_event(tbl_scheduling_events_initial
                                                           ,'id_referral_visit'
                                                           ,'dt_scheduled_visit_initial')
  
  
  ## Define Periods
  
  referral_period_acceptance_to_schedule <- define_var_period(
    event_start_tibble = referral_event_acceptance
    ,event_stop_tibble = referral_event_scheduling
    ,event_start_var = 'dt_referral_acceptance'
    ,event_stop_var = 'dt_referral_scheduled'
    ,population_member_id = 'id_referral_visit'
    ,exclusions = list_holidays_and_weekends()
    ,period_name = 'acceptance_to_schedule'
    ,period_target = 3
  )
  
  referral_period_acceptance_to_first_scheduled <- define_var_period(
    event_start_tibble = referral_event_acceptance
    ,event_stop_tibble = referral_event_first_scheduled_visit
    ,event_start_var = 'dt_referral_acceptance'
    ,event_stop_var = 'dt_scheduled_visit_initial'
    ,population_member_id = 'id_referral_visit'
    ,exclusions = list_holidays_and_weekends()
    ,period_name = 'acceptance_to_first_scheduled'
    ,period_target = 7
  )
  
  message(' complete')
  
  #######################################
  #  Varset Definition & Aggregation    #
  #######################################
  
  pcv_performance_monitoring <- metric_group$new()
  
  message('building and aggregating varsets...', appendLF = FALSE)
  
  inner_join(referral_period_acceptance_to_schedule[[2]]
                                             ,referral_attr_id_organization
                                             ,by = 'id_referral_visit') %>%
    select(-id_referral_visit) %>%
    group_by(attr_values) %>%
    summarise_each(c("mean"), na.rm = na.rm) %>%
    metric_performance_provider$new(., 'period_days', 'attr_values', 'acceptance_to_schedule_value') %>%
    pcv_performance_monitoring$metric_add(.)
  
  inner_join(referral_period_acceptance_to_schedule[[1]]
                                              ,referral_attr_id_organization
                                              ,by = 'id_referral_visit') %>%
    group_by(attr_values) %>%
    summarise_each(c("mean"), na.rm = na.rm) %>%
    metric_performance_provider$new(., 'met_target', 'attr_values', 'acceptance_to_schedule_target') %>%
    pcv_performance_monitoring$metric_add(.)
  
  inner_join(referral_period_acceptance_to_first_scheduled[[2]]
                                                ,referral_attr_id_organization
                                                ,by = 'id_referral_visit') %>%
    group_by(attr_values) %>%
    summarise_each(c("mean"), na.rm = na.rm) %>%
    metric_performance_provider$new(., 'period_days', 'attr_values', 'acceptance_to_first_visit_value') %>%
    pcv_performance_monitoring$metric_add(.)
  
  inner_join(referral_period_acceptance_to_first_scheduled[[1]]
                                                    ,referral_attr_id_organization
                                                    ,by = 'id_referral_visit') %>%
    group_by(attr_values) %>%
    summarise_each(c("mean"), na.rm = na.rm) %>%
    metric_performance_provider$new(., 'met_target', 'attr_values', 'acceptance_to_first_visit_target') %>%
    pcv_performance_monitoring$metric_add(.)
  
  inner_join(referral_attr_child_count
                                  ,referral_attr_id_organization
                                  ,by = 'id_referral_visit') %>%
    rename(attr_child_count = attr_values.x
           ,id_organization = attr_values.y) %>%
    select(-id_referral_visit) %>%
    group_by(id_organization) %>%
    summarise_each(c("mean"), na.rm = na.rm) %>%
    metric_performance_provider$new(., 'attr_child_count', 'id_organization', 'child_count_value') %>%
    pcv_performance_monitoring$metric_add(.)
  
  message(' complete')
  
  message('saving objects to file. file exists?...', appendLF = FALSE)
  
  file_path <- paste0(system.file('extdata'
                                  ,package = 'oliveR')
                      ,'/'
                      ,lazyeval::expr_text(pcv_performance_monitoring)
  )
  
  saveRDS(object = pcv_performance_monitoring
          ,file = file_path)
  
  message(paste0(' '
                 ,file.exists(file_path))
  )
  
  
  # message('saving measurement objects to files...', appendLF = FALSE)
  # 
  # object_names <- list_measurement_objects()
  # 
  # for(i in object_names){
  #   filepath <- paste0(system.file('extdata', package = 'oliveR')
  #                      ,'/'
  #                      ,i)
  #   saveRDS(object = as_name(i), filepath)
  # }
  # 
  # message(' complete')

}
  
  
  













  
