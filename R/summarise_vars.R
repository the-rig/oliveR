
summarise_vars <- function (join_variable_1 = referral_attr_child_count
                            ,join_variable_2 = referral_attr_id_organization
                            ,select_var = c('attr_values.x', 'attr_values.y')
                            ,rename_var = c('attr_child_count', 'id_organization')
                            ,group = 'id_organization'
                            ,summary_function) {

  dots <- setNames(as.list(select_var)
                   ,rename_var)

  # if the id_cols of both variables are equal, by_def is set to join_variable_1$id_col
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
    inner_join(join_variable_1$data_out
               ,join_variable_2$data_out
               ,by = by_def) %>%
      rename_(.dots = dots) %>%
      select_(lazyeval::interp(~one_of(x), x = rename_var)) -> dat
  } else if (length(rename_var) == 0) {
    # if rename_var is not provided, just make selection
    inner_join(join_variable_1$data_out
               ,join_variable_2$data_out
               ,by = by_def) %>%
      select_(lazyeval::interp(~one_of(x), x = select_var)) -> dat
  }

  dat %>%
    group_by_(.dots = group) %>%
    summarise_all(c("mean"), na.rm = TRUE) -> dat

  return(dat)

}
