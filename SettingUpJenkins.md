### Summary
Jenkins is an open source automation server that supports the development of applications through the use of a DevOps pipeline. 
It can be configured to automate the cycle of deploying an application from scratch. 
It can be configured to do this through pipeline scripts in a Jenkinsfile.

### Install Jenkins helmchart
The helm chart used for installation was provided by this [repository](https://github.com/jenkinsci/helm-charts).
Save [values.yaml](https://github.com/rss-sre-1/Rss-Quick-Start/blob/main/Manifests/Jenkins/values.yaml) file in current directory.
Changes were made to these properties in the configuration file from the original:
```yaml
adminPassword: "password"
jenkinsUriPrefix: "/jenkins"
ingress:
  enabled: true
  kubernetes.io/ingress.class: nginx
  path: "/jenkins"
```
Run these commands to install Jenkins onto your cluster
```
helm repo add jenkins https://charts.jenkins.io
helm repo update
helm install jenkins jenkins/jenkins -f values.yaml
```
