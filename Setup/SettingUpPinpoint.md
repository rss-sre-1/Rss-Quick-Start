### Summary
Pinpoint is used to see how diffrent services connect to each other and get data on each method a service provides

### Install pinpoint helmchart
Save [values.yaml](https://github.com/rss-sre-1/Rss-Quick-Start/blob/main/Manifests/Pinpoint/values.yaml) file in current directory.
Run these commands to install pinpoint
```
> helm dependency update pinpoint
> helm install pinpoint pinpoint -f values.yml
```

### Create pinpoint Ingress on Kubernetes
Save [pinpoint-ingress.yml](https://github.com/rss-sre-1/Rss-Quick-Start/blob/main/Manifests/Pinpoint/pinpoint-ingress.yml) file in current directory and run command
```
kubectl apply -f pinpoint-ingress.yml
```

### Create dashboards for monitoring
* Access /main endpoint
* use the docker files included in each repo to add each services to pinpoint, note the front end wont show up on pinpoint. 

