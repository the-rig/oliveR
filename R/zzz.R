.onLoad <- function(libname, pkgname) {
  object_names = c('child_count_value', 'acceptance_to_schedule_value')
  for(i in object_names){
    filepath <- system.file('Data', paste0(i,'.rds'), package = 'oliveR')
    #filepath <- file.path("Data/",paste0(i,".rds"))
    assign(i, readRDS(filepath), envir = .GlobalEnv)
  }
}

