#' Combine data from \code{oliver_replica} into a network metric file
#'
#' Takes tables loaded with \code{\link{load_flat_files}}, aggregates them to provider-level metrics within a given network, and
#' writes the file to the \code{Data} directory of the package.
#' @param time_window_days numeric window of time over which measures are to be averaged.
#' @param network_providers vector of providers to be included in the report. Defaults to current Family Impact Network providers as shown above.
#' @param set_neg_to_zero logical scalar - Should the measurements that are less than 0 be set to 0? Defaults to \code{FALSE}. Experimental.
#' @param set_na_to_avg logical scalar - Should the measurements that are \code{NA} or \code{NaN} be set to the network mean? Defaults to \code{FALSE}. Experimental.
#'
#' @return A single feather file.
#'
#' @author Joe Mienko, \email{mienkoja@uw.edu}
#' @seealso \code{\link{load_flat_files}}
#' @export
#' @examples
#' write_network_metric_file()

write_network_metric_file <- function(
  time_window_days = 30
  ,network_providers =  c('American Indian Community Center'
                         ,'Angela\'s Family Services'
                         ,'Fulcrum Institute, DRC'
                         ,'G&A, LLC'
                         ,'GMC Training Institute'
                         ,'Love My Child Family Services'
                         ,'Martin Luther King Jr. Family Outreach Center'
                         ,'New Beginnings Visitation and Parent Education'
                         ,'Reunified Services'
                         ,'Service Alternatives'
                         ,'The Salvation Army Nurturing Center for Children & Families'
                         ,'Unite Family Services'
                         ,'Family Visitation Volunteers of America')
  ,set_neg_to_zero = FALSE
  ,set_na_to_avg = FALSE
){

  load_flat_files()

  max_date_of_file <- max(report_pcvmetrics_servicereferrals$accepted_date, na.rm = T)

  network_aggr_performance_metrics <- Organizations %>%
    filter(name %in% network_providers) %>%
    select(id
           ,name) %>%
    rename(provider = name) %>%
    inner_join(
      report_pcvmetrics_servicereferrals
    ) %>%
    filter(accepted_date >= max_date_of_file - time_window_days) %>%
    select(id
           ,days_accepteddate_scheduleddate
           ,was_referral_scheduled_3days_after_acceptance
           ,days_accepteddate_firstscheduledvisitdate
           ,was_firstscheduledvisit_7days_after_acceptance
           ,number_of_children_on_sr) %>%
    group_by(id) %>%
    summarise(pcv_pm1_value = mean(days_accepteddate_scheduleddate, na.rm = TRUE)
              ,pcv_pm1_pct_tgt = mean(was_referral_scheduled_3days_after_acceptance, na.rm = TRUE)
              ,count_conforming_pcv_pm1_cnf = sum(ifelse(was_referral_scheduled_3days_after_acceptance == 1
                                                         ,1
                                                         ,NA), na.rm =TRUE)
              ,count_nonconforming_pcv_pm1_cnf = sum(ifelse(was_referral_scheduled_3days_after_acceptance == 0
                                                            ,1
                                                            ,NA), na.rm =TRUE)
              ,pcv_pm2_value = mean(days_accepteddate_firstscheduledvisitdate, na.rm = TRUE)
              ,pcv_pm2_pct_tgt = mean(was_firstscheduledvisit_7days_after_acceptance, na.rm = TRUE)
              ,count_conforming_pcv_pm2_cnf = sum(ifelse(was_referral_scheduled_3days_after_acceptance == 1
                                                     ,1
                                                     ,NA), na.rm =TRUE)
              ,count_nonconforming_pcv_pm2_cnf = sum(ifelse(was_referral_scheduled_3days_after_acceptance == 0
                                                        ,1
                                                        ,NA), na.rm =TRUE)
              ,avg_number_children_per_ref = mean(number_of_children_on_sr, na.rm = TRUE)) %>%
    mutate(network_administrator = 'Family Impact Network (FIN)'
           ,time_window_days = time_window_days
           ,date_of_file_build = now()
           ,set_NaN_to_avg = set_na_to_avg
           ,set_neg_to_zero = set_neg_to_zero)

  pcv_pm1_value_mean <- mean(filter(network_aggr_performance_metrics
                                    ,pcv_pm1_value >= 0)$pcv_pm1_value)

  pcv_pm1_pct_tgt_mean <- mean(filter(network_aggr_performance_metrics
                                      ,pcv_pm1_value >= 0)$pcv_pm1_pct_tgt)

  pcv_pm2_value_mean <- mean(filter(network_aggr_performance_metrics
                                    ,pcv_pm2_value >= 0)$pcv_pm2_value)

  pcv_pm2_pct_tgt_mean <- mean(filter(network_aggr_performance_metrics
                                      ,pcv_pm2_value >= 0)$pcv_pm2_pct_tgt)

  if (set_neg_to_zero == TRUE){
    network_aggr_performance_metrics <- network_aggr_performance_metrics %>%
      mutate(pcv_pm1_pct_tgt = ifelse(pcv_pm1_value < 0
                                      ,pcv_pm1_pct_tgt_mean
                                      ,pcv_pm1_pct_tgt)
             ,pcv_pm1_value = ifelse(pcv_pm1_value < 0
                                     ,0
                                     ,pcv_pm1_value)
             ,pcv_pm2_pct_tgt = ifelse(pcv_pm2_value < 0
                                       ,pcv_pm2_pct_tgt_mean
                                       ,pcv_pm2_pct_tgt)
             ,pcv_pm2_value = ifelse(pcv_pm2_value < 0
                                     ,0
                                     ,pcv_pm2_value)
      )
  }

  if (set_na_to_avg == TRUE){
    network_aggr_performance_metrics <- network_aggr_performance_metrics %>%
      mutate(pcv_pm1_pct_tgt = ifelse(is.nan(pcv_pm1_value) | is.na(pcv_pm1_value)
                                                              ,pcv_pm1_pct_tgt_mean
                                                              ,pcv_pm1_pct_tgt)
             ,pcv_pm1_value = ifelse(is.nan(pcv_pm1_value) | is.na(pcv_pm1_value)
                                          ,pcv_pm1_value_mean
                                          ,pcv_pm1_value)
             ,pcv_pm2_pct_tgt = ifelse(is.nan(pcv_pm2_value) | is.na(pcv_pm2_value)
                                      ,pcv_pm2_pct_tgt_mean
                                      ,pcv_pm2_pct_tgt)
             ,pcv_pm2_value = ifelse(is.nan(pcv_pm2_value) | is.na(pcv_pm2_value)
                                     ,pcv_pm2_value_mean
                                     ,pcv_pm2_value)
            )
  }

  network_aggr_performance_metrics %>%
    mutate(pcv_pm1_value = ifelse(is.nan(pcv_pm1_value) | is.na(pcv_pm1_value) | pcv_pm1_value < 0, NA, pcv_pm1_value)
           ,pcv_pm1_pct_tgt = ifelse(is.nan(pcv_pm1_pct_tgt) | is.na(pcv_pm1_pct_tgt), NA, pcv_pm1_pct_tgt)
           ,pcv_pm2_value = ifelse(is.nan(pcv_pm2_value) | is.na(pcv_pm2_value) | pcv_pm2_value < 0, NA, pcv_pm2_value)
           ,pcv_pm2_pct_tgt = ifelse(is.nan(pcv_pm2_pct_tgt) | is.na(pcv_pm2_pct_tgt), NA, pcv_pm2_pct_tgt)) %>%
    write_feather(path = 'Data//network_aggr_performance_metrics.feather')

}
