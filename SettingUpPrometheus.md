### Summary
Prometheus is a monitoring and alerting toolkit. It has a multi-dimensional data model with time series data distinguished by a metric name and key-value pair. It allows for highly customizable data collection and provides observability over your system.


### Install Prometheus helmchart
Save [values.yaml](https://github.com/rss--values.yaml) file in current directory.
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
Run these commands to install Prometheus
```
helm repo add prometheus https://.github.io/helm-charts
helm repo update
helm install prometheus  -f values.yaml
```

### Create Prometheus Ingress on Kubernetes
Save [-ingress.yml](https://github.com/rss-sre-1-ingress.yml) file in current directory and run command
```
kubectl apply -f -ingress.yml
```

### Set up Grafana and Loki datasources
* Grafana
* Loki & FluentD

### Create dashboards for monitoring
* Access /grafana/ endpoint and login with username: admin and password: password.
* Import dashboard with [JSON model](https). 
* In order for Grafana to display properly, be sure to create a namespace for each microservice and name them `rss-cart`, `rss-inventory`, `rss-account`, `rss-evaluation` accordingly. 
