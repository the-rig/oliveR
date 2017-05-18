
# function for future testing use.
# designed to render text-based svg as a plot

read_raw_svg_and_plot <- function(raw_svg){
  # set a system-independent tempdir
  temp_dir <- tempdir()
  # use the temp_dir to create full paths
  temp_svg <- paste0(temp_dir, 'temp_svg.svg')
  temp_pic <- paste0(temp_dir, 'temp_pic.svg')
  # write svg to directory
  write(raw_svg, file = temp_svg)
  # convert svg to picture object
  grConvert::convertPicture(temp_svg, temp_pic)
  # plot picture object
  grImport2::grid.picture(grImport2::readPicture(temp_pic))
}

#
# h <- curl::new_handle()
# curl::handle_setopt(h, copypostfields = "moo=moomooo");
#
#
# h <- basicTextGatherer()
# h$reset()
# url <- "http://localhost/ocpu/library/oliveR/R/get_metric_list/json"
# post_return <- httr::POST(url, body = list("group_id" = "3"))
# post_content <- httr::content(post_return)
#
# post_content_svg <- list()
#
# for (i in 2:(length(post_content[[1]])-1)){
#   post_content_svg[[i]] <- post_content[[1]][[i]]$characteristic_percent_conforming_graph
# }
# post_content_svg <- unlist(post_content_svg)





