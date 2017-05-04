load_measurement_objects <- function(){
  
  object_names <- list_measurement_objects()
  
  file_dir <- system.file("Data", package = "oliveR")
  
  if(dir.exists(file_dir))
    for(i in object_names){
      filepath <- paste0(file_dir
                         ,'/'
                         ,i)
      if(file.exists(filepath))
        assign(i, readRDS(filepath), envir = .GlobalEnv)
  }  
}
