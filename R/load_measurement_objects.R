load_measurement_objects <- function(){
  
  object_names <- 'pcv_performance_monitoring'

  file_dir <- system.file("extdata", package = "oliveR")

  if(all(dir.exists(file_dir), !is.na(object_names)))
    for(i in object_names){
      filepath <- paste0(file_dir
                         ,'/'
                         ,i)
      if(file.exists(filepath))
        assign(i, readRDS(filepath), envir = .GlobalEnv)
  }
}
