get_sha_info <- function(){
  sha_file <- tryCatch(paste0(readLines("R/install-packages.R"), collapse = "")
                       ,warning=function(w) 1)
  if(sha_file==1) {
    sha_value <- 'SHA information not available'
  } else
    sha_value <- stringr::str_extract(sha_file, stringr::regex('(?<=oliveR@).*(?=\\\\")', multiline = TRUE))
  return(sha_value)
}