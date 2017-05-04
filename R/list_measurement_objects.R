list_measurement_objects <- function(){
  
  data_directory <- system.file("extdata", package = "oliveR")
  
  if(dir.exists(data_directory)){
    object_names <- read_json(paste0(data_directory
                                     ,'/'
                                     ,list.files(path = data_directory
                                                 ,pattern = '\\.json$')[[1]])
    ) %>% 
      tidyjson::as.tbl_json() %>%
      spread_values(measurement_group = jstring("measurement_group")) %>%
      enter_object("measurements") %>%       
      gather_array() %>%
      spread_values(measurement = jstring("id")) %>%
      .$measurement 
    return(object_names)
  } else {
    return(NA)
  }

}