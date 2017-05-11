# oliveR

Database access and measurement development for the Oliver SMS. The package is designed to work with the [oliver-opencpu-server-docker](https://github.com/pocdata/oliver-opencpu-server-docker) and the `oliver_replica` psql database. 

## Prerequisites 

1. A public/private key pair with the public key shared to mattbro@uw.edu and residing on the reverse tunnel target.
2. A valid username on the reverse tunnel target. Can be set by contacting mattbro@uw.edu.
3. Authy account information should be forwarded to \email{mattbro@uw.edu} prior to trying to establish a connection to the replica with the command string or access will be denied. Access to `oliver_replica` requires two-factor authentication. Authy (\url{https://www.authy.com/}) is used for this purpose. 
4. A connection to the `oliver_replica` database. This is accomplished with a complex `ssh` statement, a sample of which is as follows: `ssh -i /Users/mienkoja/.ssh/id_rsa -p 5431 -L 10.200.10.1:5432:oliver-replica.criploulbgnu.us-west-2.rds.amazonaws.com:5432 -N mienkoja@52.90.57.218`. This statement can be generated for a specific user from within oliveR using the `create_ssh_command()` function. 
5. A functioning instance of [oliver-opencpu-server-docker](https://github.com/pocdata/oliver-opencpu-server-docker). 
6. Unless you want to specify your credentials manually, the `build_all_metrics()` function is set to pull connection parameters for `oliver_replica` from the environment. These can be set according within your favorite shell environment *or* can be set within R using `Sys.setenv()` as shown below: 

```
Sys.setenv(OLIVER_REPLICA_DBNAME = "oliver_replica"
           ,OLIVER_REPLICA_HOST = "10.200.10.1"
           ,OLIVER_REPLICA_USER = "mienkoja"
           ,OLIVER_REPLICA_PORT = "5432"
           ,OLIVER_REPLICA_PASSWORD = "my_password")
```

## Installation

oliveR can be installed from from github with:

```{r, eval = FALSE}
# install.packages("devtools")
devtools::install_github("hadley/pkgdown")
```

## Usage

The interaction between [oliver-opencpu-server-docker](https://github.com/pocdata/oliver-opencpu-server-docker) and oliveR relies on the present of one or more "metric" objects. On the initial install of oliveR, no metric objects are present as the data contained within may be sensitive. The first time you load oliveR (and each time you want to refresh the metric objects), you should update the metric objects with: 

```{r, eval = FALSE}
oliveR::build_all_metrics()
```

This will drop the objects into an `rds` formatted file in the oliveR directory. The objects are then loaded into the global environment with: 

```{r, eval = FALSE}
oliveR::load_measurement_objects()
```

Metric objects are used within oliveR to create lists of metric information - values and geometry. This is accomplished with running methods from a `metric_group`. A `metric_group` object serves as a container for one or more metric objects. For our purposes we are currently only dealing with `metric_performance_provider` objects, an R6 object which currently contains two methods: 1. `get_value` (a method to produce a single numeric value for a given metric), and 2. `get_donut` (a method to produce svg geometry representing a donut plot. The function, `get_metric_list()`, is used to generate a nested list which contains the returns from the `get_value` and `get_donut` methods on all metric objects within a given metric group by:

```{r, eval = FALSE}
oliveR::get_metric_list(metric_group = my_metric_group, case_id = my_case_id)
```

There are multiple ways that this can be replicated within [oliver-opencpu-server-docker](https://github.com/pocdata/oliver-opencpu-server-docker). The following demonstrates how this can be accomplished to convert the list output of `get_metric_list` to json. 

```
curl http://localhost/ocpu/library/oliveR/R/get_metric_list/json -H "Content-Type: application/json" -d '{"case_id":my_case_id}'
```

