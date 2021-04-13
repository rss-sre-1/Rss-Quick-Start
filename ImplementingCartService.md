## Cart Service

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

### Using Cart Service

The cart microservice handles:

- cart creation
- cart updates
- cart retrieval
- cart deletion
- cart item creation
- cart item updates
- cart item retrieval
- cart item deletion

These requests are handled by two controllers: **CartItemController and CartController**

Endpoints and methods are mapped out below.

### CartController

#### Endpoints
VERB | URL | USE
--- | --- | ---
POST | /cart | saves cart to db
GET | /carts/{id} | find carts by user id
GET | /cart/{id} | find cart by id
PUT | /cart | update cart
DELETE | /cart/{id} | delete cart


#### Methods

``` java
public Cart createCart(
      @ApiParam(value = "Cart object", required = true)
      @RequestBody Cart cart)
```

> Saves the Cart object to the database.

``` java
public List<Cart> getCartsByUserId(
    @ApiParam(value = "User ID", required = true)
    @PathVariable("id") int userId)
```

> Retrieves a list of Carts with the matching User ID.

``` java
public Cart getCartById(
    @ApiParam(value = "Cart ID", required = true)
    @PathVariable("id") int id)
```

> Retrieves an individual Cart by Cart ID.

``` java
public Cart updateCart(
    @ApiParam(value = "Cart object", required = true)
    @RequestBody Cart cart)
```

> Updates an already existing Cart based on Cart ID.

``` java
public void deleteCartById(
    @ApiParam(value = "Cart ID", required = true)
    @PathVariable("id") int id)
```

> Deletes a Cart from the database based on Cart ID.

#### Cart Model

```java
private int cartId;
private int userId;
private String name;
private List<CartItem> cartItems;
```

### CartItemController

#### Endpoints

VERB | URL | USE
--- | --- | ---
POST | /cartitem | saves cartItem to db
GET | /cartitem/{id} | finds cartItem by id
GET | /cartitems/{id} | returns all cartItems by cart id
PUT | /cartitem | update cartItem
DELETE | /cartitem/{id} | delete cartItem


#### Methods

``` java
public CartItem createCartItem(@RequestBody CartItem ci)
```

> Saves the CartItem object to the database. If a CartItem with a matching Cart and Product ID already exists in the database the existing CartItem will add the passed CartItem's quantity to its own.

``` java
public CartItem getCartItemById(
    @ApiParam(value = "CartItem ID", required = true)
    @PathVariable("id") int id)
```

> Gets the CartItem object based on the CartItem ID.

``` java
public List<CartItem> getAllCartItems(
    @ApiParam(value = "Cart ID", required = true)
    @PathVariable("id") int cartId)
```

> Returns all CartItems that have the matching Cart by Cart ID

``` java
public CartItem updateCartItem(
    @ApiParam(value = "CartItem", required = true)
    @RequestBody CartItem ci)
```

> Updates the CartItem object in the database.

``` java
public void deleteCartItemById(
    @ApiParam(value = "CartItem ID", required = true)
    @PathVariable("id") int id)
```

> Deletes the CartItem object from the database based on CartItem ID

#### Cart Item Model

```java
private int cartItemId;
private Cart cart;
private int productId;
private int quantity;
```

### Implemented Changes
* Converted the H2 database to PostgreSQL database
* Added logback and fluentd dependencies to the service
* Added logging to all implemented methods
* Created a canary deployment and load test deployment manifest
* Update Dockerfile to integrate Pinpoint APM
* Exported logs to Loki
* Added exception handling for bad requests

