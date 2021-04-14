### Summary
Nginx ingress controller is a traffic management solution for applications in kubernetes and containerized environments. Depending on where it gets installed, either a hardware or software load balancer will be provisioned.

### Install Nginx-ingress helm chart
The helm chart used for installation was provided by this [repository](https://github.com/kubernetes/ingress-nginx/).

Run these commands to install Nginx-ingress controller onto your cluster
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx
```
