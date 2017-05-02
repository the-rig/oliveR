update_all_data <- function(my_user_name, my_password){
  con <- dplyr::src_postgres(
    dbname = 'oliver_replica',
    host = '127.0.0.1',
    user = my_user_name,
    password = my_password
  )

  create_flat_files(con = con)
  load_flat_files()
  write_network_metric_file()

  pcv_pm1 <- performance_metric_provider$new(measurement_name = 'Days Until Scheduled'
                                             ,measurement_index = 'pm1'
                                             ,measurement_service = 'pcv'
                                             ,graph_conforming_fill = '#4ABDAC'
                                             ,graph_nonconforming_fill = '#DFDCE3')

  pcv_pm2 <- performance_metric_provider$new(measurement_name = 'Days Until First Visit'
                                             ,measurement_index = 'pm2'
                                             ,measurement_service = 'pcv'
                                             ,graph_conforming_fill = '#FC4A1A'
                                             ,graph_nonconforming_fill = '#DFDCE3')

  saveRDS(pcv_pm1, 'Data//pcv_pm1.rds')
  saveRDS(pcv_pm2, 'Data//pcv_pm2.rds')
}

# .onLoad <- function(libname, pkgname) {
#   data("model1", "mydata", package=pkgname, envir=parent.env(environment()))
# }
