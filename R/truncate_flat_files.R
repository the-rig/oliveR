truncate_flat_files <- function(tables = c('report_businessmetrics_memberbreakdown'
                                       ,'report_businessmetrics_provideractivity'
                                       ,'report_businessmetrics_rollup'
                                       ,'report_pcvmetrics_servicereferrals'
                                       ,'report_pcvmetrics_visitreports'
                                       ,'Organizations')
                            ){

  # get table names (based on file names) from the data directory
  tables <- sub(pattern = '.feather'
                ,replacement = ''
                ,x = sub('Data//', '', Sys.glob("Data//*.feather"))
  )

  # load the tables using the load_flat_files function
  load_flat_files(tables)

  # truncate all of the tables and write them back to the data directory
  for (i in tables) {

    assign(i
           ,lazy_eval(interp(~top_n(table_name, 0), table_name = as.name(i)))
           ,envir=.GlobalEnv)

    path <- paste0('Data//', i, '.feather')

    lazy_eval(interp(~write_feather(table_name, path), table_name = as.name(i)))

  }
}
