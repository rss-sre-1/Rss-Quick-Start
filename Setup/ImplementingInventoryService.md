## Inventory Service

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

### Using Inventory Service

This repository holds the inventory microservice which handles:

- product creation*
- product retrieval
- product updates
- product deletion

*creates test products as well as adds new products

These requests are handled by a single **ProductController.**

Endpoints and methods are mapped out below.

### InventoryController

#### Endpoints
VERB | URL | USE
--- | --- | ---
GET | /inventory/main | creates test products
GET | /inventory/product/{id} | gets product by id
GET | /inventory/product | gets a list of all the products
POST | /inventory/product | creates a new product
PUT | /inventory/product | updates a product
DELETE | /inventory/product/{id} | deletes a product by their id

Methods available for import with this Postman [file.](RSS-Inventory-Service.postman_collection.json) 

#### Methods

``` java
public void getProductById()
```

> Creates test products.

``` java
public Product getProductById(@PathVariable Long id)
```

> Will return the product based on the given ID.

``` java
public List<Product> getAllProduct()
```

> Will return a list of all products.

``` java
public Product createProductById(@RequestBody Product product)
```

> Will create a new product.

``` java
public Product updateProduct(@RequestBody Product product)
```

> Will update a product.

``` java
public void deleteProductById(@PathVariable Long id)
```

> Will delete a product.

#### Product (model)

``` java
    private Long id;
    private String category;
    private String brand;
    private String name;
    private String description;
    private String model;
    private String image;
    private Integer quantity;
    private Integer unitPrice;
    private String color;

```

### Implemented Changes
* Converted the H2 database to PostgreSQL database
* Added logback and fluentd dependencies to the service
* Added logging to all implemented methods
* Created a canary deployment and load test deployment manifest
* Update Dockerfile to integrate Pinpoint APM
* Exported logs to Loki
* Added exception handling for bad requests
