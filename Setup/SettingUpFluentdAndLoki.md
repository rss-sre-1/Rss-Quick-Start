## Fluentd
Fluentd was used as a data collector for logs.

Create config map using fluent.conf file in your namespace:
<pre>kubectl create configmap fluent-conf -n {your_namespace} --from-file fluent.conf</pre>


## Loki
Loki was used for log aggregation.

Install Loki with helm chart
<pre>helm install loki grafana/loki -f loki/values.yaml</pre>

Apply Loki external file in your namespace:
<pre>kubectl apply -f loki-external.yml -n {your_namespace}</pre>
