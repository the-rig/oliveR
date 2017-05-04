load_measurement_objects <- function(){
  object_names <- list_measurement_objects()
  for(i in object_names){
    filepath <- paste0(system.file('Data', package = 'oliveR')
                       ,'/'
                       ,i)
    if(file.exists(filepath))
      assign(i, readRDS(filepath), envir = .GlobalEnv)
  }  
}
