#' Open a connection to the \code{oliver_replica} database. 
#'
#' This function is used to open a connection to the \code{oliver_replica} database and set the database search path to \code{staging} as suggested here \link{https://github.com/tidyverse/dplyr/issues/244}. This function has only been tested on macOS. It is probably pretty fragile. 
#'
#' #' The following dependencies are required in order to create a valid connection:
#'
#' #' \itemize{
#'   \item The presence of the \code{oliver_replica} database on \code{localhost}, possibly via SSH as partially decribed in the \code{\link{create_ssh_command}} documentation.
#'   \item A valid username and password on the \code{oliver_replica} database. Can be set by contacting \email{mattbro@uw.edu}.
#'   \item A password stored on your Windows, Linux, or mac box for use in the \pkg{keyringr} package. Parameters set on your local machine should follow the format \code{oliver_replica_myuser} where \code{myuser} is replaced with the userid. 
#' }
#'
#' @param database_name A character string specifying the name of the database. Defaults to \code{oliver_replica}.
#' @param database_host A character string specifying the name of the database host. Defaults to \code{localhost}.
#' @param database_user A character string specifying the name of the user. Defaults to \code{mienkoja}.
#'
#' @return A list of class \code{PostgreSQLConnection}.
#'
#' @author Joe Mienko, \email{mienkoja@uw.edu}
#' @seealso \code{\link{create_ssh_command}}
#' @export
#' @examples
#' 
#' db_connect()


oliver_replica_connect <- function(
  database_name = 'oliver_replica'
  ,database_host = '127.0.0.1'
  ,database_user = 'mienkoja'
){
  
  # get credentials for windows
  if(get_os() == 'windows'){
    credential_label <- paste0(toupper(database_name)
                               ,'_'
                               ,toupper(database_user))
    credential_path <- paste(Sys.getenv('USERPROFILE')
                             ,'\\DPAPI\\passwords\\'
                             ,Sys.info()["nodename"]
                             ,'\\'
                             ,credential_label
                             ,'.txt'
                             ,sep="")
    con <- src_postgres(
      dbname = database_name
      ,host = database_host
      ,user = database_user
      ,password = decrypt_dpapi_pw(credential_path)
    )
  # get credentials for macOS  
  } else if(get_os() == 'osx'){
    con <- src_postgres(
      dbname = database_name
      ,host = database_host
      ,user = database_user
      ,password = decrypt_kc_pw(paste0(database_name
                                       ,'_'
                                       ,database_user))
    )
  # get credentials for unix/linux
  } else {
    con <- src_postgres(
      dbname = database_name
      ,host = database_host
      ,user = database_user
      ,password = decrypt_gk_pw(paste0('db '
                                       ,database_name
                                       ,' user '
                                       ,database_user))
      ,password = decrypt_kc_pw('oliver_replica_mienkoja')
    )
  }
  
  dbSendQuery(con$con, build_sql("SET search_path TO ", 'staging'))
  
  return(con)
}


