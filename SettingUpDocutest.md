# Docutest

## Overview

Docutest is an application used by RSS to load test service build prior to deployment. An instance of the application exist on the K8 cluster, as well as PostgreSQL database used to store test summaries. Individual data (ie. results of a number of threads sending requests to a given endpoint) is stored within an Amazon S3 external to the cluster. Our version of Docutest was forked from a previous version with a few minor changes. The source code as well as some documentation are available here: https://github.com/rss-sre-1/Docutest.

## Getting Started

All files used for setup are available within the Docutest repository. 

### From Your Own Build
If you would like to modify the Docutest source code, fork the repository and create your own. After any changes you make, build the application and push it to a docker repository, then begin the From an Image section.

### Creating An Image
To create an Image of Docutest, Docker will need to be installed. First the source code will need to be packaged into a jar file. If Maven is insalled then simply do the following in the root folder:
```
mvn clean package
```
Otherwise use the inbedden mvnw:
```
./mvnw clean package
```
Once the souce code has been packaged the image can be built with the following command:
```
docker build -t username/repository .
```
The image will then be in your local repository and will need to be pushed to either a public or private repository so that the deployment manifest call pull that image. For example if useing DockerHub the username will be your Dockerhub's username and repository will be the name of a repository on DockerHub. Before pushing the image, make sure you are logged into the service. This can vary depending on the service the image is going to be uploaded to.
```
docker login --username=yourhubusername --email=youremail@company.com
```
You can then push the image onto that repository. 
```
docker push username/repository
```

### From An Image
This is likely going to be the easiest way to set up the Docutest. Download the contents of [the manifests folder.](https://github.com/rss-sre-1/Docutest/tree/master/manifests)

If you have you own Docutest image you would like to use, change the docutest-deployment.yml to use that, rather than "eilonwy/docutest:latest." Additionally, Docutest will need access to a PostgrSQL database. If you need help creating a database, refer to [this link.](https://github.com/rss-sre-1/Rss-Quick-Start/blob/main/SettingUpPostgreSQL) The credentials and url to the database are set in a Kubernetes secret named "docutest-database." The secret can be create with this form:
```
kubectl create secret generic docutest-database --from-literal='url=yourURL' --from-literal='username=yourUsr' --from-literal='password=yourPW'
```
The application will also need access to an S3 bucket, which will be used to store data about individual endpoints as csv files. This can be created with AWS. The credentials for this bucket are stored in a secret named "docutest-s3." This secret can be created by running a command with the following form:
```
kubectl create secret generic docutest-s3 --from-literal='AWS_ACCESS_KEY_ID=yourKeyID' --from-literal='AWS_SECRET_KEY=yourKey'
```
Finally, run these commands: 
```
kubectl apply -f docutest-deployment.yml
kubectl apply -f docutest-service.yml
kubectl apply -f docutest-ingress.yml
```
