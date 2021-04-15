## Account Service

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

### Using Account Service

The microservice for Account Service allows for:

- user creation
- user information updates
- user authentication
- retrieving user information
- user account creation
- user account updates
- user account retrieval
- account type creation
- account type updates
- account type retrieval

These requests are handled by three controllers: **UserController, AccountController, and AccountTypeController** 

### UserController

#### Endpoints
VERB | URL | USE
--- | --- | ---
GET | /user/all | get all registered users
POST | /user/new | add new user
POST | /user/login | authentication service
POST | /user/user | find user by id
PUT | /user/info | update user information
PUT | /user/cred | update user password only
PUT | /user/pic | update a user's profile picture
PUT | /user/master | update user to admin

#### Methods

```java
public List<Users> getAllUsers()
```

> Retrieves all users in the database.

```java
public User addNewUser(@RequestBody User user)
```

> Adds a new user to the database upon registration

```java
public User loginUser(@RequestBody User user)
```

> Compares login credentials with what is in the database, will return null is invalid.

```java
public User findUserById(@RequestBody User user)
```

> Will pull a user from database by their ID or email.

``` java
public void updateInformation(@RequestBody User user)
public void updatePassword(@RequestBody User user)
public void updateProfilePic(@RequestBody User user)
public void updateIsAdmin(@RequestBody User user)
```

> Will take in new user info and update the user in the database

### AccountController

#### Endpoints
VERB | URL | USE
--- | --- | ---
PUT | /account/points | save new point total to db
PUT | /account/points/a | add to account's points
POST | /account/new | saves the new account
POST | /account/account | find account by id
POST | /account/accounts | find accounts by user id

#### Methods

```java
public void updatePoints(@RequestBody Account acc)
```

> Takes in the new account point total and saves it to database

``` java
public void addPoints(@RequestBody Account acc)
```

> Will take the new points and add them to the account point total

``` java
public Account addAccount(@RequestBody Account acc)
```

> Takes in the new account and adds it to the database

``` java
public Account getAccountById(@RequestBody Account acc)
```

> Will return the account, from the database, by the id

``` java
public List<Account> findAccountByUserId(@RequestBody User acc)
```

> Will return accounts related to the user id and return a list

### AccountTypeController

#### Endpoints

VERB | URL | USE
--- | --- | ---
POST | /acctype/type | admins can add account types to the database
GET | /acctype/all | returns all account types
PUT | /acctype/type/u | updates a current account type


#### Methods

``` java
public AccountType addAccountType(@RequestBody AccountType accType)
```

> As an admin can add account types to the database

``` java
public List<AccountType> getAllAccountType()
```

> Will pull all of the account types and return a list

``` java
public void updateAccountType(@RequestBody AccountType accType)
```

> Will update a current account type(for spelling errors, ect)

## Implemented Changes from previous batch

- Added custom exception handling
- Configured source code to handle interaction with a PostgreSQL database
	- Source code was implemented to interact with an Oracle SQL database
- Adjusted table relationships to interact with a PostgreSQL database
