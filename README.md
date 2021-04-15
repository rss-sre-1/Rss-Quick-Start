# Setup 

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

### Implementing Frontend Service
#### Implementing Frontend Service ####
* Clone the rss-frontend repository
* Create a namespace called rss-frontend
  * kubectl create namespace rss-frontend
* Apply the rss-frontend manifests (manifests are in a folder called rss-frontend-manifests)
  * service, ingress, deployment
  
 ### Implementing Inventory Service

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
  
### Implementing Evaluation Service

* Clone the rss-evaluation-service repository
* Create a namespace called rss-evaluation
  * kubectl create namespace rss-evaluation
* Apply the rss-evaluation manifests (manifests are in a folder called manifests)
  * service, ingress, deployment, loki-external, service-monitor, prometheus-rule, canary, loadtest
* Create secret
  * kubectl create -n rss-evaluation secret generic rss-evaluation-credentials --from-literal=url=**REDACTED** --from-literal=username=**REDACTED** --from-literal=password=**REDACTED**
* Create fluentd configmap
  * kubectl create configmap -n rss-evaluation rss-evaluation-fluent-conf --from-file fluent.conf
 
### Implementing Cart Service

* Clone the [rss-cart-service repository](https://github.com/rss-sre-1/rss-cart-service.git)
* Build image using provided [Dockerfile](https://github.com/rss-sre-1/rss-cart-service/blob/dev/revature-cart-backend/Dockerfile)
  * `docker build -t rss-cart-service .`
  * Push image to Dockerhub or ECR. Image may be retagged at this point.
    * `docker push rss-cart-service:latest` 
  * Change image repository URL in [rss-cart-deployment.yml](https://github.com/rss-sre-1/rss-cart-service/blob/dev/manifests/rss-cart-deployment.yml) on line 38.
  * Change image repository URL in [rss-cart-canary-deployment.yml](https://github.com/rss-sre-1/rss-cart-service/blob/dev/manifests/rss-cart-carany-deployment.yml) and [rss-cart-load-test-deployment](https://github.com/rss-sre-1/rss-cart-service/blob/dev/manifests/rss-cart-load-test-deployment.yml) on line 40.
* Create a namespace called rss-cart
  * `kubectl create namespace rss-cart`
* Create environment variables DB_URL (database url), DB_USERNAME (database username) and DB_PASSWORD (database password)
* Create secret using previously created environment variables
  * `kubectl create -n rss-cart secret generic rss-cart-credentials --from-literal=url=*$DB_URL --from-literal=username=$DB_USERNAME --from- literal=password=$DB_PASSWORD`
* Create fluentd configmap for logging using [fluent.conf](https://github.com/rss-sre-1/rss-cart-service/blob/dev/logging/fluent.conf)
  * `kubectl create configmap -n rss-cart rss-cart-fluent-conf --from-file fluent.conf`
* Apply the [rss-cart manifests](https://github.com/rss-sre-1/rss-cart-service/tree/dev/manifests) to kubernetes
  * service - define how the pods will be accessed
    * `kubectl apply rss-cart-service-service.yml`
  * service-monitor - allow for service discovery in Prometheus for observability and dashboarding
    * `kubectl apply rss-cart-service-monitor.yml` 
  * rules - set up recording and alerting rules for Prometheus 
    * `kubectl apply rss-cart-rules.yml`  
  * role - set user role to find correct service account
    * `kubectl apply rss-cart-role.yml`
  * deployment - production deployment of cart service and fluentd
    * `kubectl apply rss-cart-deployment.yml` 
  * canary-deployment - canary deployment of cart service and fluentd
    * `kubectl apply rss-cart-canary-deployment.yml`
  * load-test-deployment - load test deployment of cart service and fluentd
    * `kubectl apply rss-cart-deployment.yml` 
  * ingress - allows access to service from outside the cluster  
    * `kubectl apply rss-cart-ingress.yml`   
  * loki-external - allows access to loki agent in default namespace from inside rss-cart namespace
    * `kubectl apply loki-external.yml`
* Ensure all pods are running by doing a get all on the rss-cart namespace. There should be 3 deployment pods with 2/2 containers ready.
  * `kubectl -n rss-cart get all`    

## setting up Nginx
The helm chart used for installation was provided by this [repository](https://github.com/kubernetes/ingress-nginx/).

Run these commands to install Nginx-ingress controller onto your cluster
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-ngin
```
## setting up Grafana Loki

### Grafana
Save [values.yaml](https://github.com/rss-sre-1/rss-cart-service/blob/dev/grafana/grafana-values.yaml) file in current directory.
Pay attention to your persistence configuration:
```yaml
persistence:
  type: pvc
  enabled: true
  #storageClassName:
  accessModes:
    - ReadWriteOnce
  size: 20Gi
  # annotations: {}
  finalizers:
    - kubernetes.io/pvc-protection
```
Run these commands to install grafana
```
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install grafana grafana/grafana -f values.yaml
```
 
Save [grafana-ingress.yml](https://github.com/rss-sre-1/rss-cart-service/blob/dev/grafana/grafana-ingress.yml) file in current directory and run command
```
kubectl apply -f grafana-ingress.yml
```

* Access /grafana/ endpoint and login with username: admin and password: password.
* Import dashboard with [JSON model](https://github.com/rss-sre-1/rss-cart-service/blob/dev/grafana/Dashboards/microservice-monitor-dashboard.json). 
* In order for Grafana to display properly, be sure to create a namespace for each microservice and name them `rss-cart`, `rss-inventory`, `rss-account`, `rss-evaluation` accordingly. 


### Loki and FluentD

#### Fluentd
Fluentd was used as a data collector for logs.

Create config map using fluent.conf file in your namespace:
<pre>kubectl create configmap fluent-conf -n {your_namespace} --from-file fluent.conf</pre>


#### Loki
Loki was used for log aggregation.

Install Loki with helm chart
<pre>helm install loki grafana/loki -f loki/values.yaml</pre>

Apply Loki external file in your namespace:
<pre>kubectl apply -f loki-external.yml -n {your_namespace}</pre>

## setting up Pinpoint

Save [values.yaml](https://github.com/rss-sre-1/Rss-Quick-Start/blob/main/Manifests/Pinpoint/values.yaml) file in current directory.
Run these commands to install pinpoint
```
> helm dependency update pinpoint
> helm install pinpoint pinpoint -f values.yml
```

Save [pinpoint-ingress.yml](https://github.com/rss-sre-1/Rss-Quick-Start/blob/main/Manifests/Pinpoint/pinpoint-ingress.yml) file in current directory and run command
```
kubectl apply -f pinpoint-ingress.yml
```

### setting up Prometheus

Here we installed the prometheus helm chart. This creates a prometheus object in the cluster named kube-prometheus-stack. 
This helm chart install these objects: kubernetes/kube-state-metrics, prometheus-community/prometheus-node-exporter, and grafana/grafana. Grafana was disabled on this helm chart so that it could be installed individually by the grafana team. 
This is where we got the helm chart to install prometheus: [here](https://github.com/prometheus-community/helm-charts.git).
This configuration inside the helm chart is where we configured prometheus alertmanager. This was sending alerts to slack. Do not commit this file with your slack webhook url still in here: the webhook will stop working and you will need to get a new one.
```yaml
persistence: #line 650
  type: pvc
  enabled: true
  #storageClassName:
  accessModes:
    - ReadWriteOnce
  size: 20Gi
  # annotations: {}
  finalizers:
    - kubernetes.io/pvc-protection
   
  config: #line 146
    global:
      resolve_timeout: 5m
      slack_api_url: #put your slack channel webhook url here
    route:
      receiver: 'default-receiver'
      group_by:
      - job
      group_wait: 30s
      group_interval: 30s
      repeat_interval: 3h
      routes:
      - receiver: 'rss-inventory'
        group_wait: 10s
        match:
          job: rss-inventory
      - receiver: 'rss-cart'
        group_wait: 10s
        match:
          job: rss-cart
      - receiver: 'rss-account'
        group_wait: 10s
        match:
          job: rss-account
      - receiver: 'rss-evaluation'
        group_wait: 10s
        match:
          job: rss-evaluation
    receivers:
    - name: 'default-receiver'
      slack_configs:
      - channel: '#alerts'
        title: "{{ range .Alerts }}{{ .Annotations.summary }}\n{{ end }}"
        text: "{{ range .Alerts }}{{ .Annotations.description }}\n{{ .Annotations.message }}\n{{ end }}"
        title_link: 'http://ad8d6edfec9aa4a79be8f07ba490356a-1499412652.us-east-1.elb.amazonaws.com/alertmanager/#/alerts'
    - name: 'rss-inventory'
      slack_configs:
      - channel: '#rss-inventory'
        title: "{{ range .Alerts }}{{ .Annotations.summary }}\n{{ end }}"
        text: "{{ range .Alerts }}{{ .Annotations.description }}\n{{ .Annotations.message }}\n{{ end }}"
        title_link: 'http://ad8d6edfec9aa4a79be8f07ba490356a-1499412652.us-east-1.elb.amazonaws.com/alertmanager/#/alerts'
    - name: 'rss-cart'
      slack_configs:
      - channel: '#rss-cart'
        title: "{{ range .Alerts }}{{ .Annotations.summary }}\n{{ end }}"
        text: "{{ range .Alerts }}{{ .Annotations.description }}\n{{ .Annotations.message }}\n{{ end }}"
        title_link: 'http://ad8d6edfec9aa4a79be8f07ba490356a-1499412652.us-east-1.elb.amazonaws.com/alertmanager/#/alerts'
    - name: 'rss-account'
      slack_configs:
      - channel: '#rss-account'
        title: "{{ range .Alerts }}{{ .Annotations.summary }}\n{{ end }}"
        text: "{{ range .Alerts }}{{ .Annotations.description }}\n{{ .Annotations.message }}\n{{ end }}"
        title_link: 'http://ad8d6edfec9aa4a79be8f07ba490356a-1499412652.us-east-1.elb.amazonaws.com/alertmanager/#/alerts'
    - name: 'rss-evaluation'
      slack_configs:
      - channel: '#rss-evaluation'
        title: "{{ range .Alerts }}{{ .Annotations.summary }}\n{{ end }}"
        text: "{{ range .Alerts }}{{ .Annotations.description }}\n{{ .Annotations.message }}\n{{ end }}"
        title_link: 'http://ad8d6edfec9aa4a79be8f07ba490356a-1499412652.us-east-1.elb.amazonaws.com/alertmanager/#/alerts'
    templates:
    - /etc/alertmanager/config/*.tmpl
```
We used different ingresses (one for alertmanager, one for prometheus) instead of the ones provided in the helm chart. These can be found [here](https://github.com/rss-sre-1/Rss-Quick-Start/tree/main/Manifests/Prometheus).
You can apply these ingresses using these commands:
`kubectl apply -f prometheus-alert-ingress.yml`
`kubectl apply -f prometheus-ingress.yml`

Run these commands to install Prometheus
```
helm repo add prometheus https://.github.io/helm-charts
helm repo update
#go to the folder that has values.yaml
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack  -f values.yaml
```
You should only need to install it once. If you need to delete it for any reason you can use this command:
```
helm uninstall kube-prometheus-stack
```
If you make updates to values.yaml, instead of uninstalling and reinstalling the helm chart, enter these commands from the root of the cloned repository:
```
cd scripts
./apply.sh
```

#### Create Prometheus Ingress on Kubernetes
Save [-ingress.yml](https://github.com/rss-sre-1-ingress.yml) file in current directory and run command
```
kubectl apply -f -ingress.yml
```

#### Setting up recording and alerting rules
These dependencies were added to pom.xml in order to implement prometheus:
```xml
        <dependency>
            <groupId>io.micrometer</groupId>
            <artifactId>micrometer-core</artifactId>
        </dependency>
        <dependency>
            <groupId>io.micrometer</groupId>
            <artifactId>micrometer-registry-prometheus</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
```
This was added to application.yaml in order to expose the actuator endpoint:
```yaml
management:
  metrics:
    export:
      prometheus:
        # enabling prometheus format metrics
        enabled: true 
  endpoints:
    web:
      exposure:
        include: "*"
  endpoint:
    health:
      enabled: true
```
We set up service monitors for each microservice in order for prometheus to scrape metrics. Those can be found in each microservice's repository.
Those can be applied with this command:
```
kubectl apply -f [servicemonitor name] -n rss-[servive name]
```
Some microservices may implement the servicemonitor in the setup.yaml file.

#### Alerting Rules
There are rules in each microservice's repository for recording and alerting on high error rates and latencies. These rules are based on a 99.5% service level objective (SLO). To customize rules, [here]( https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/
) is more information.

### setting up postgress databases for loadtesting

use the following commands with the [Values.yml](https://github.com/rss-sre-1/Rss-Quick-Start/blob/main/Manifests/Postgres/values.yaml)

	~helm install account-data -f values.yaml -n loadtesting
	~helm install evaluation-data -f values.yaml -n loadtesting
	~helm install cart-data -f values.yaml -n loadtesting
	~helm install inventory-data -f values.yaml -n loadtesting
	
### setting up Jenkins
The helm chart used for installation was provided by this [repository](https://github.com/jenkinsci/helm-charts).
Save [values.yaml](https://github.com/rss-sre-1/Rss-Quick-Start/blob/main/Manifests/Jenkins/values.yaml) file in current directory.
Changes were made to these properties in the configuration file from the original:
```yaml
adminPassword: "password"
jenkinsUriPrefix: "/jenkins"
ingress:
  enabled: true
  kubernetes.io/ingress.class: nginx
  path: "/jenkins"
```
Run these commands to install Jenkins onto your cluster
```
helm repo add jenkins https://charts.jenkins.io
helm repo update
helm install jenkins jenkins/jenkins -f values.yaml

 


  

