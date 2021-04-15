# PostgreSQL

## Getting Started

### Amazon RDS
The recommended way to set up a PostgreSQL database is to utilize Amazon RDS. Their managed databases are the easiest way to get up and running quickly, and are likely going to be more reliable than installing and congiguring your own. However, due to budget/resource constraints, you may want to install databases on the cluster itself. This is the case with the databases we used for load testing, as they only needed to exist for a short period of time, so it is unneccessary to have them persist outside of the cluster.

### From a Helm Chart
If you would like to install a database on the K8s cluster, the recommeded way to acheive that is via the usage of Helm charts. [This](https://bitnami.com/stack/postgresql/helm) is the chart used in RSS. More information about this chart can be found [here.](https://github.com/bitnami/charts/tree/master/bitnami/postgresql/#installing-the-chart) Install the [values.yaml](https://github.com/bitnami/charts/blob/master/bitnami/postgresql/values.yaml) file on your machine. Edit the file as needed. For the Docutest database, the only changes to make are to specify the admin username and password. This is optional as the chart will automatically generate an admin user and password if not provided. For the databases used in load testing, set the 'enabled' attribute in 'persistence' to false.
Afteword run the commands: 
```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/postgresql -f values.yaml
```
Be sure to follow the directions in the output of the second command to save the password if left to be generated.
