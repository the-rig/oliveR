#' A function to build an ssh command
#'
#' Create an ssh command string to access the oliver replica database on AWS via reverse tunnel to a linux box administered by POC. 
#' This command string can then be interactively pasted into a terminal to set a connection to the oliver replica on your localhost. 
#' 
#' The following dependencies are required in order to create a valid string:
#' 
#' \itemize{
#'   \item A public/private key pair with the public key shared to \email{mattbro@uw.edu} and residing on the reverse tunnel target.
#'   \item A valid username on the reverse tunnel target. Can be set by contacting \email{mattbro@uw.edu}.
#' }
#' 
#' Access to the oliver replica requires two-factor authentication. Authy (\url{https://www.authy.com/}) is used for this purpose. 
#' Authy account information should be forwarded to \email{mattbro@uw.edu} prior to trying to establish a connection to the replica with the command string or access will be denied. 
#' 
#' @param private_key_path A locally accesible path to your previously registered private key. 
#' @param target_port The target port number. Defaults to 5431. 
#' @param local_port_for_forward The local port to be forwarded. Defaults to 5432.
#' @param forward_target_host The actual location of the oliver replica. Defaults to \code{oliver-replica.criploulbgnu.us-west-2.rds.amazonaws.com}.
#' @param forward_target_port The targeted port on the target host. Defaults to 5432.
#' @param reverse_tunnel_target_user A valid username on the reverse tunnel target. 
#' @param reverse_tunnel_target The name of the reverse tunnel target. Defaults to \code{52.90.57.218}.
#' 
#' @return None (invisible NULL).
#'
#' @author Joe Mienko, \email{mienkoja@uw.edu}
#' @seealso \code{\link{create_flat_files}}
#' @export
#' @examples
#' create_ssh_command(private_key_path = '/Users/mienkoja/.ssh/id_rsa'
#'                    ,reverse_tunnel_target_user = 'mienkoja')
#'                    

create_ssh_command <- function(private_key_path = NA
                               ,target_port = 5431
                               ,local_port_for_forward = '10.200.10.1:5432'
                               ,forward_target_host = 'oliver-replica.criploulbgnu.us-west-2.rds.amazonaws.com'
                               ,forward_target_port = 5432
                               ,reverse_tunnel_target_user = NA
                               ,reverse_tunnel_target = '52.90.57.218') {
  
  stopifnot(!is.na(private_key_path), !is.na(reverse_tunnel_target_user))
  
  cmd_txt <- paste0(
    'ssh -i '
    ,private_key_path
    ,' -p '
    ,target_port
    ,' -L '
    ,local_port_for_forward
    ,':'
    ,forward_target_host
    ,':'
    ,forward_target_port
    ,' -N '
    ,reverse_tunnel_target_user
    ,'@'
    ,reverse_tunnel_target
  )
  
  return(cat(cmd_txt))
}

