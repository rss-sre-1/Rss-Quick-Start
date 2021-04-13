### Summary
Grafana can be used as a platform for monitoring and observability. It allows you to query, visualize, alert on and understand your metrics.

### Install Grafana helmchart
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

### Create Grafana Ingress on Kubernetes
Save [grafana-ingress.yml](https://github.com/rss-sre-1/rss-cart-service/blob/dev/grafana/grafana-ingress.yml) file in current directory and run command
```
kubectl apply -f grafana-ingress.yml
```

### Set up Prometheus and Loki datasources
* Prometheus
* Loki & FluentD

### Create dashboards for monitoring
* Access /grafana/ endpoint and login with username: admin and password: password.
* Import dashboard with [JSON model](https://github.com/rss-sre-1/rss-cart-service/blob/dev/grafana/Dashboards/microservice-monitor-dashboard.json). 
* In order for Grafana to display properly, be sure to create a namespace for each microservice and name them `rss-cart`, `rss-inventory`, `rss-account`, `rss-evaluation` accordingly. 
