## Cart Service

#### Implementing Cart Service

* Clone the [rss-cart-service repository](https://github.com/rss-sre-1/rss-cart-service.git)
* Create a namespace called rss-cart
  * `kubectl create namespace rss-cart`
* Apply the [rss-cart manifests](https://github.com/rss-sre-1/rss-cart-service/tree/dev/manifests) to kubernetes
  * service - define how the pods will be accessed
    * `kubectl apply rss-cart-service-service.yml`
  * service-monitor - allow for service discovery in Prometheus for observability and dashboarding
    * `kubectl apply rss-cart-service-monitor.yml` 
  * rules - set up recording and alerting rules for Prometheus 
    * `kubectl apply rss-cart-rules.yml`  
  * role - 
    * 
  * load-test-deployment
    *  
  * , load-test-deployment, canary-deployment, deployment, ingress, loki-external
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

#### Features to be Implemented
* Exception Handling
