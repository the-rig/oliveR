
summarise_vars <- function (join_variable_1
                            ,join_variable_2
                            ,select_var
                            ,rename_var
                            ,group_key = 'id_organization'
                            ,data_out_type = c('identity')
                            ,summary_function = 'mean'
                            ,na_rm = TRUE) {

  dots <- setNames(as.list(select_var)
                   ,rename_var)

  # define the type of data_out we are looking for

  if (length(data_out_type) == 1) {
    data_out_type <- rep(data_out_type, 2)
  }


  if(data_out_type[1] == 'identity'){
    data_out1 <- join_variable_1$data_out_identity
  } else if(data_out_type[1] == 'performance'){
    data_out1 <- join_variable_1$data_out_performance
  } else if(data_out_type[1] == 'quality'){
    data_out1 <- join_variable_1$data_out_quality
  } else {
    stop(paste0("data_out_type[1] of, ", data_out_type[1], " not currently defined"))
  }

  if(data_out_type[2] == 'identity'){
    data_out2 <- join_variable_2$data_out_identity
  } else if(data_out_type[2] == 'performance'){
    data_out2 <- join_variable_2$data_out_performance
  } else if(data_out_type[2] == 'quality'){
    data_out2 <- join_variable_2$data_out_quality
  } else {
    stop(paste0("data_out_type[2] of, ", data_out_type[2], " not currently defined"))
  }



  # if the id_cols of both variables are equal, by_def is set to join_variable_1$id_col
  # if the id_col in join_variable_1 does not exist within the selected data_out,
  # the join will not be possible and the script will fail
  if(join_variable_1$id_col != join_variable_2$id_col) {
    by_def <- join_variable_1$id_col
  } else if (join_variable_1$id_col == join_variable_2$id_col) {
    by_def <- join_variable_2$id_col
    names(by_def) <- join_variable_1$id_col
  }

  # check for presence of rename_var
  if(all(length(rename_var) != 0, length(rename_var) != length(select_var))){
    # if rename_var is provided, but not equal to select_var, then stop eval
    stop("if rename_var specified, it must have an equal number of elements to select_var")
  } else if (all(length(rename_var) != 0, length(rename_var) == length(select_var))) {
    # if rename_var is provided, and equal to select_var, then rename before selection
    inner_join(data_out1
               ,data_out2
               ,by = by_def) %>%
      rename_(.dots = dots) %>%
      select_(lazyeval::interp(~one_of(x), x = rename_var)) -> dat
  } else if (length(rename_var) == 0) {
    # if rename_var is not provided, just make selection
    inner_join(data_out1
               ,data_out2
               ,by = by_def) %>%
      select_(lazyeval::interp(~one_of(x), x = select_var)) -> dat
  }

  dat %>%
    group_by_(.dots = group_key) %>%
    summarise_all(summary_function, na.rm = na_rm) -> dat

  return(dat)

}

