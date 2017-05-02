percent_target_graph = function(id
                                ,measurement_service_val = NA
                                ,measurement_index_val = NA
                                ,conforming_fill_val = NA
                                ,nonconforming_fill_val = NA
                                ){

  measurement_type <- 'cnf'
  conforming_alpha <- 1
  nonconforming_alpha <- .25
  thickness_out <- 4
  thickness_in <- 3

  network_aggr_performance_metrics <- read_feather(path = 'Data//network_aggr_performance_metrics.feather')

  provider_id <- id

  .dots <- list(~provider_id == id)

  total_rows <- network_aggr_performance_metrics %>%
    filter_(.dots = .dots) %>%
    nrow()

  total_observations <- network_aggr_performance_metrics %>%
    filter_(.dots = .dots) %>%
    #filter(id == 3) %>%
    select(ends_with(paste0(measurement_service_val
                            ,'_'
                            ,measurement_index_val
                            ,'_'
                            ,measurement_type))) %>%
    rowSums()

  if (total_rows == 0) {

    return(NA)

  } else if (total_observations == 0) {

    return(NA)

  } else {

    plot <- network_aggr_performance_metrics %>%
      filter_(.dots = .dots) %>%
      #filter(id == 4) %>%
      select(id, ends_with(paste0(measurement_service_val
                                  ,'_'
                                  ,measurement_index_val
                                  ,'_'
                                  ,measurement_type))) %>%
      add_totals_col() %>%
      gather(key, value, -Total) %>%
      filter(key != 'id') %>%
      mutate(fraction = value/Total) %>%
      arrange(key) %>%
      mutate(ymax = cumsum(fraction)
             ,ymin = lag(fraction
                         ,default = 0)) %>%
      ggplot(aes(fill = key
                 ,ymax=ymax
                 ,ymin=ymin
                 ,xmax=thickness_out
                 ,xmin=thickness_in)
      ) +
      geom_rect(alpha = c(conforming_alpha
                          ,nonconforming_alpha)) +
      scale_fill_manual(values = c(conforming_fill_val
                                   ,nonconforming_fill_val)) +
      coord_polar(theta='y') +
      xlim(c(0
             ,thickness_out)) +
      theme_void() +
      guides(fill = 'none')

    return(plot)
  }

}
