## Cart Service

#### Implementing Cart Service

* Clone the [rss-cart-service repository](https://github.com/rss-sre-1/rss-cart-service.git)
* Create a namespace called rss-cart
  * `kubectl create namespace rss-cart`
* Create environment variables DB_URL (database url), DB_USERNAME (database username) and DB_PASSWORD (database password)
* Create secret using previously created environment variables
  * `kubectl create -n rss-cart secret generic rss-cart-credentials --from-literal=url=*$DB_URL --from-literal=username=$DB_USERNAME --from- literal=password=$DB_PASSWORD`
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
