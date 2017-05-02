# .onLoad <- function(libname, pkgname) {
#   object_names = c('pcv_pm1', 'pcv_pm2')
#   for(i in object_names){
#     filepath <- file.path("Data/",paste(i,".rds",sep=""))
#     assign(i, readRDS(filepath), envir = .GlobalEnv)
#   }
# }

