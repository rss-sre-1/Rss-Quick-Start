## Evaluation Service

#### Implementing Evaluation Service

* Clone the rss-evaluation-service repository
* Create a namespace called rss-evaluation
  * kubectl create namespace rss-evaluation
* Apply the rss-evaluation manifests (manifests are in a folder called manifests)
  * service, ingress, deployment, loki-external, service-monitor, prometheus-rule, canary, loadtest
* Create secret
  * kubectl create -n rss-evaluation secret generic rss-evaluation-credentials --from-literal=url=**REDACTED** --from-literal=username=**REDACTED** --from-literal=password=**REDACTED**
* Create fluentd configmap
  * kubectl create configmap -n rss-evaluation rss-evaluation-fluent-conf --from-file fluent.conf

#### Implemented Changes
* Converted the H2 database to Postgres
* Added logback and fluentd dependencies to the service
* Created a canary deployment manifest
* Update Dockerfile to integrate Pinpoint APM
* Exported logs to Loki
* Added custom counter metric to service
* Resolved recursive entity construction with Jsonbackreference
