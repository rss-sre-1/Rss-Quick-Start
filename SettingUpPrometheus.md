### Summary
Prometheus is a monitoring and alerting toolkit. It has a multi-dimensional data model with time series data distinguished by a metric name and key-value pair. It allows for highly customizable data collection and provides observability over your system.


### Install Prometheus helm chart
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

### Create Prometheus Ingress on Kubernetes
Save [-ingress.yml](https://github.com/rss-sre-1-ingress.yml) file in current directory and run command
```
kubectl apply -f -ingress.yml
```

### Setting up recording and alerting rules
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

### Alerting Rules
There are rules in each microservice's repository for recording and alerting on high error rates and latencies. These rules are based on a 99.5% service level objective (SLO). To customize rules, [here]( https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/
) is more information.

