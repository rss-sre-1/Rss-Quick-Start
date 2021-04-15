### Setup 

how to setup the Cluster, Pipeline, and the monitoring for The RSS Micro Service

## EKS Cluster setup

first thing you'll need is the cluster to run it on. refer to the [CapcityPlan.yml](https://github.com/rss-sre-1/Rss-Quick-Start/blob/main/Setup/CapicityPlan.md)

## Creating all the namespaces

run the following commands in the eks cluster

	`kubectl create namespace docutest`
	`kubectl create namespace kube-node-lease`
	`kubectl create namespace kube-public`
	`kubectl create namespace kube-system`
	`kubectl create namespace lens-metrics`
	`kubectl create namespace loadtesting`
	`kubectl create namespace postgres`
	`kubectl create namespace rss-account`
	`kubectl create namespace rss-cart`
	`kubectl create namespace rss-evaluation`
	`kubectl create namespace rss-frontend`
	`kubectl create namespace rss-inventory`

this will create all the namespaces we need for the cluster

## Deploying the services

# Frontend Service
#### Implementing Frontend Service ####
* Clone the rss-frontend repository
* Create a namespace called rss-frontend
  * kubectl create namespace rss-frontend
* Apply the rss-frontend manifests (manifests are in a folder called rss-frontend-manifests)
  * service, ingress, deployment
  
 # Implementing Inventory Service

* Clone the [rss-inventory-service repository](https://github.com/rss-sre-1/rss-inventory-service.git)
* Build image using provided [Dockerfile](https://github.com/rss-sre-1/rss-inventory-service/blob/documentation/Dockerfile)
  * `docker build -t rss-inventory-service .`
  * Push image to Dockerhub or ECR. Image may be retagged at this point.
    * `docker push rss-inventory-service:latest` 
  * Change image repository URL in [rss-inventory-setup.yaml](github.com/rss-sre-1/rss-inventory-service/blob/documentation/rss-inventory-setup.yaml) on line 207 and 282.
* Create a namespace called rss-inventory
  * `kubectl create namespace rss-inventory`
* Create environment variables DB_URL (database url), DB_USERNAME (database username) and DB_PASSWORD (database password)
* Create secret using previously created environment variables
  * `kubectl create -n rss-inventory secret generic rss-inventory-credentials --from-literal=url=$DB_URL --from-literal=username=$DB_USERNAME --from- literal=password=$DB_PASSWORD`
* Create fluentd configmap for logging using [fluent.conf](https://github.com/rss-sre-1/rss-inventory-service/blob/documentation/fluent.conf)
  * `kubectl create configmap -n rss-inventory fluent-conf --from-file fluent.conf`
* Apply the rss-inventory manifests to kubernetes
  * `kubectl apply -f rss-inventory-setup.yaml`
* Apply the following non-controller kubernetes objects (these are not in rss-inventory-setup.yaml)
  * rules - set up recording and alerting rules for Prometheus 
    * `kubectl apply rss-inventory-rules.yml`  
  * loki external- helps export the logs
    * `kubectl apply -f loki-external.yml` 
* Ensure all pods are running by doing a get all on the rss-inventory namespace. There should be 3 deployment pods with 2/2 containers ready.
  * `kubectl -n rss-inventory get all`  

### Implementing Account Service

- Clone the [rss-account-service repository](https://github.com/rss-sre-1/rss-account-service)
- Build and push the image using the provided Dockerfile
	- Build image first
		- From the cloned folder
		- `cd Account-Service`
		- `docker build -t rss-account-service .`
		- OPTIONAL: Tag image
		- `docker tag rss-account-service:{SOURCE TAG} rss-account-service:{TARGET TAG}`
	- Push image to remote repository
	  - `docker push {REPOSITORY NAME}/rss-account-service:{IMAGE TAG}`
	- Change image repository URL in deployment manifests located in manifests folder
		- [rss-account-service-deployment.yml](https://github.com/rss-sre-1/rss-account-service/blob/master/manifests/rss-account-service-deployment.yml) (line 40)
			- `{REPOSITORY NAME}/rss-account-service:{IMAGE TAG}`
		- [rss-account-service-canary-deployment.yml](https://github.com/rss-sre-1/rss-account-service/blob/master/manifests/rss-account-service-canary-deployment.yml) (line 40)
			- `{REPOSITORY NAME}/rss-account-service:{IMAGE TAG}`
		- [rss-account-service-load-test-deployment.yml](https://github.com/rss-sre-1/rss-account-service/blob/master/manifests/rss-account-service-load-test-deployment.yml) (line 41)
			- `{REPOSITORY NAME}/rss-account-service:{IMAGE TAG}`
- Create a namespace on Kubernetes cluster called rss-account
	- `kubectl create namespace rss-account`
- Create environment variables DB_URL (database url), DB_USERNAME (database username) and DB_PASSWORD (database password) on cluster as secrets
	- `kubectl create -n rss-account secret generic rss-account-credentials --from-literal=url={DATABASE URL} --from-literal=username={DATABASE USERNAME} --from-literal=password={DATABASE PASSWORD}`
- Create fluentd configmap for logging using [fluent.conf](https://github.com/rss-sre-1/rss-account-service/blob/master/manifests/fluent.conf)
  - Go back to root folder
  	- `cd ..`
  - Apply fluent.conf file
		- `kubectl create configmap -n rss-account rss-account-fluent-conf --from-file fluent.conf`
- Apply the [rss-account manifests](https://github.com/rss-sre-1/rss-account-service/tree/master/manifests) to Kubernetes cluster
  - service - define how the pods will be accessed
  	- `kubectl apply rss-account-service-service.yml`
  - service-monitor - allow for service discovery in Prometheus for observability and dashboarding
  	- `kubectl apply service-monitor.yml` 
  - rules - set up recording and alerting rules for Prometheus 
  	- `kubectl apply rss-account-rules.yml`  
  - deployment - production deployment of account service and fluentd
  	- `kubectl apply rss-account-service-deployment.yml` 
  - canary-deployment - canary deployment of account service and fluentd
  	- `kubectl apply rss-account-service-canary-deployment.yml`
  - load-test-deployment - load test deployment of account service and fluentd
  	- `kubectl apply rss-account-service-load-test-deployment.yml`
  - load-test-service - makes sure that load test does not go through load balancer
  	- `kubectl apply rss-account-service-load-test-service.yml` 
  - ingress - allows access to service from outside the cluster  
  	- `kubectl apply rss-account-ingress.yml`   
  - loki-external - allows access to loki agent in default namespace from inside rss-account namespace
   	- `kubectl apply loki-external.yml`
- Ensure all pods are running by doing a get all on the rss-account namespace. There should be 3 deployment pods with 2/2 containers ready.
  - `kubectl -n rss-account get all`
  

