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
The automated deployment pipeline of RSS employs 2 technologies used in tandem.  First, a number of Github workflows have been implemented which scale the number of pods on the cluster appropriately as well as set the newly built image in place for each step of the deployment proccess.  Second, a Jenkens pipeline is used to implement the load-testing stage of the new image as well as provide the administrator a choice to promote or reject the canary deployment. 

The following terms used herein have been defined below as they have particular definitions pertaining to these automation technologies:
* Action--a subroutine defined and performed on Github when a defined trigger condition is met
* Workflow--A text file that defines the operations performed when a corresponding Github Action is triggered
* Pipeline--The set of actions performed by a Jenkins job when it is triggered.  Herein it is used as a general term for a Jenkins 'item' though it is, in reality, a particular catagory thereof

The following can be found in the repository of each microservice:
* 4 Github Actions workflows 
* A Jenkinsfile to configure the use of a Jenkins pipeline
* 9 Github Repository secrets to be used by the aforementioned workflows.

### Flow of the Automation
* A push is made to the default branch of a Github repository
* Workflow 'BUILD' is triggered by push
* Jenkins pipeline is triggered by BUILD
* Workflow 'CREATE_CANARY' is triggered by jenkins
* Jenkins waits for user input to either promote or remove the canary
* Workflow 'PROMOTE_CANARY' || 'REJECT_CANARY' is triggered by the pipeline

### Configuration
1. Set up a Jenkins Pipeline
    * Be sure to either set the Authentication Token to 'load_test' or adjust the  'curl' command within the 'handoff_to_jenkins' job of 'Build.yml' with the appropriate token
2. Adjust the following Repository Secrets appropriately
    * APP_NAME
    * AWS_REGION
    * ECR_REGISTRY
    * ECR_REPOSITORY
    * ECR_REPOSITORY_PREFIX
    * EKS_ACCESS_KEY_ID
    * EKS_SECRET_ACCESS_KEY
    * EKS_CLUSTER_NAME
    * JENKINS_TOKEN
    * SONAR_TOKEN
3. Make sure that the following pods exist on the cluster (their manifests have been applied) before attempting to run a workflow for a given microservice:
    * ~-deployment
    * ~-load-test-deployment
    * ~-canary-deployment
    * ~-service
    * ~-load-test-service
        * '~' refers to the name of the microservice

## Potential Pitfalls & Further Development Ideas
* Only workflows extant in the default branch of a repository will appear in the 'Actions' tab of that repository
    * Any Workflow actions taken against child branches will not apear until merged into the default branch
* Each individual 'run' tag within a workflow defines a new instance of a shell to run in. Data obtained (such as log-ins to an AWS account) do not persist for subsequent run-tags to use
* The system does not properly handle commented out lines. They are read as shell commands and thus the commenting format will be read as improper syntax

## The Github Actions

### Descriptions of Github Actions
Below are listed the tasks performed by each Workflow

#### BUILD
* Triggered by: a push to the default branch
* sonar_maven_build (stage):
    * Converts the current version of the src code into a Docker Image and pushes said image to the AWS ECR
        * The most recent Github Hash is used as the tag for this image
* access_aws_set_loadtest_deployment (stage):
    * Update the image of the load-test deployment to the newly pushed image
    * Spin-up the load-test deployment to the same number of replicas that the production should have
* handoff_to_jenkins (stage):
    * Triggers the associated pipeline on Jenkins so that load-testing can be performed

#### CREATE_CANARY
* Triggered by: an HTTP POST request send by the Jenkins Pipeline
* access_aws (stage):
    * Spin-down the load-test-deployment to dormancy
    * Update the canary-deployment to the newly pushed image
        * This should cause the associated pods to restart with the new image
    * Spin-up the canary-deployment to a single replica-set for production testing

#### PROMOTE_CANARY
* Triggered by: an HTTP POST request send by the Jenkins Pipeline
* access_aws (stage):
    * Update the prucution deployment to the newly pushed image
    * Spin-down the canary-deployment to dormancy

#### REJECT_CANARY
* Triggered by: an HTTP POST request send by the Jenkins Pipeline
* Spin-down the canary-deployment to dormancy

### General Notes
Github workflows are YAML files and and have the following general structure
* name tag that defines the name that the Action will be displayed under
* env tag that contains a list of the variables used by the workflow
    * This is where the Repository Secrets are used
* jobs tag that contins one or more headings
    * Each heading defines tasks to be performed by the workflow

## The Jenkins Pipeline
This pipeline is defined by a flat file called a 'Jenkinsfile' that can be found in the root directory.  

### Jenkinsfile outline
* K8s agent
    * Defines the pod onwhich the jenkins pipeline runs
* enviroment
    * Defines the context inwhich the jenkins pipeline runs
* stages
    * 'Load Test'
        * Uses Docutest to perform many requests against all endpoints of RSS
        * Stores the results in an S3 bucket on the cluster
    * 'Create Canary'
        * Triggers workflow 'CREATE_CANARY'
    * 'Promote or Reject Canary'
        * Waits for user imput 
        * Triggers the appropriate workflow based on said input

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
SONAR_TOKEN|generated by SonarCloud
