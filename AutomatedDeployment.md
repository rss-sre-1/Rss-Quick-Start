# Automated Deployment of the Revature Swag Shop
The Revature Swag Shop(hereafter RSS) is intended for deployment to a Kubernetes cluster. The process of deploying updates/upgrades of each individual microservice via a canary deployment lifecycle has been automated for ease of such proccesses. 

An understanding of the following technologies is assumed of the reader: 
* Docker & DockerHub 
* Amazon Web Services (AWS)
    * Elastic Container Regestry (ECR) 
    * Eleastic Kuberneties Service (EKS) 
    * Simple Storage Service (s3)
* JMeter & Docutest 
* Maven & Spring Framework
* Kubernetes (K8s)
* Git/GitHub/GitBASH
* Sonar cloud

## Overview
The automated deployment of RSS canaries employes 2 technoligies used in tandam.  Firstly an number of Github workflows have been implemented which scale the number of pods on the cluster as appropriate for the current step of the deployment proccess.  Secondnly a Jenkens pipeline is used to implement load-testing of a new Docker image. 

The following terms used herein have been defined below as they have particular definitions pertaining to these automation technologies:
* Action--a subrutine defined an permormed Github when a defined trigger condition is met
* Workflow--A text file that defining the opperations performed when a corisponding Github Action is triggered
* Pipeline--The set of actions performed by a Jenkins implementation when such is triggered.  Herein it is used as a general term for a Jenkins 'item' though it is, in reality, a particular catagory thereof

The following can be found in the repository of each microservice:
* 4 Github Actions workflows 
* a Jenkinsfile to configure the use of a Jenkins pipeline
* 9 Github Repository secrets to be used by the aforementioned workflows.

### Flow of the Automation
* a push is made to the default branch of a Github repo
* workflow 'BUILD' is triggered by push
* Jenkins pipeline is triggered by BUILD
* workflow 'CREATE_CANARY' is triggered by jenkins
* Jenkins waits for user input to either promote or remove the canary
* workflow 'PROMOTE_CANARY' || 'REJECT_CANARY' is triggered by the pipeline

### Configureation
1. set up a Jenkins Pipeline
    * be sure to either set the Authentication Token to 'load_test' or adjust the  'curl' command within the 'handoff_to_jenkins' job of 'Build.yml' with the appropriate token
2. adjust the following Repository Secrets appropriately
    * TODO: 
3. make sure that the following pods exist on the cluster (their manifests have been applied) before attempting to run a workflow for a given microservice:
    * ~-deployment
    * ~-load-test-deployment
    * ~-canary-deployment
    * ~-service
    * ~-load-test-service
        * '~' refers to the name of the microservice

## Potential Pitfalls & Further Development Ideas
* only workflows extant in the default branch of a repository will appear in the 'Aactions' tab of that repository
    * any Workflow actions taken against child branches will not apear until merged into the default branch
* each individual 'run' tag within a workflow defines a new instance of a shell to run in.  Data obtained (such as log-ins to an AWS account) do not persist for subsequent run-tags to use
* they system does not properly handle commented out lines. They are read as shell commands and thus the commenting format will be read as improper syntax

## The Github Actions

### Descriptions of Github Actions
Below are listed the tasks performed by each Workflow

#### BUILD
* triggered by: a push to the default branch
* sonar_maven_build
    * converts the current version of the src code into a Docker Image and pushes said image to the AWS ECR
        * the most recent Github Hash is used as the tag for this image
* access_aws_set_loadtest_deployment
    * update the image of the load-test deployment to the newly pushed image
    * spin-up the load-test deployment to the same number of replicas that the production should have
* handoff_to_jenkins
    * trigger the associated Pipeline so that load-testing can be performed

#### CREATE_CANARY
* triggered by: an HTTP POST request send by the Jenkins Pipeline
* access_aws:
    * spin-down the load-test-deployment to dormancy
    * update the canary-deployment to the newly pushed image
        * this should cause the associated pods to restart with the new image
    * spin-up the canary-deployment to a single replica-set for production testing

#### Promote_Canary
* triggered by: an HTTP POST request send by the Jenkins Pipeline
* access_aws:
    * update the prucution deployment to the newly pushed image
    * spin-down the canary-deployment to dormancy

#### Reject_Cannary
* triggered by: an HTTP POST request send by the Jenkins Pipeline
* spin-down the canary-deployment to dormancy

### general notes
Github workflows are YAML files and and have the following general structure
* name tag that defines the name that the Action will be displayed under
* env tag that contians a list of the variables used by the workflow
    * this is where the Repository Secrets are used
* jobs tag that contins one or more headings
    * each heading defines tasks to be performed by the workflow

## The Jenkins Pipeline
This pipeline is defined by a flat file 'Jenkinsfile' that can be found in the root directory.  

### jenkinsfile outline
* K8s agent
    * defines the pod onwhich the jenkins pipeline runs
* enviroment
    * defines the context inwhich the jenkins pipeline runs
* stages
    * 'Load Test'
        * uses Docutest to permorm many requests against all endpoints of RSS
        * stores the results in an S3 bucket on the cluster
    * 'Create Canary'
        * triggers workflow 'CREATE_CANARY'
    * 'Promote or Reject Canary'
        * waits for user imput 
        * triggers the appropriate workflow based on said input

## Github Repository Secrets
Repository Secret Name|content
----------------------|-------
APP_NAME|'rss-[name of microservise]'
AWS_REGION|the AWS region that hosts the EKS
ECR_REGESTRY|the name of the ECR
ECR_REPOSITORY|the name of the ECR repository
ECR_REPOSITORY_PREFIX|the username of the ECR account
ECR_ACCESS_KEY_ID|generated by AWS
EKS_CLUSTER_NAME|obtained by 'kubectl config get-contexts'
EKS_SECRET_ACCESS_KEY|generated by AWS
JENKINS_TOKEN|generated by Jenkins
SONAR_TOKEN|Generated by SonarCloud

