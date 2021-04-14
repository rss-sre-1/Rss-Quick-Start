# Automated Deployment of the Revature Swag Shop
The Revature Swag Shop(hereafter RSS) is intended for deployment to a Kubernetes cluster. The process of deploying updates/upgrades of each individual microservice via a canary deployment lifecycle has been automated for ease of such proccesses. 

## overview
The automated deployment of RSS canaries employes 2 technoligies used in tandam.  Firstly an number of Github workflows have been implemented which scale the size of pods on the cluster as appropriate for the current step of the deployment proccess.  Secondnly a Jenkens pipeline is used to implement load-testing of a new deployment. 

A number of terms used herein have been defined below as they have particular definitions pertaining to these automation technologies:
* Action--A set of actions taken by Github when a defined trigger condition is met
* Workflow--A text file that defined the actions taken when a corisponding Github Action is triggered
* Pipeline--The set of actions performed by a Jenkins implementation when such is triggered.  Herein it is used as a general term for a Jenkins 'item' though it is in reality a particular catagory thereof

The following can be found in the repository of each microservice:
* 4 Github Actions workflows 
* a Jenkinsfile to configure the use of a Jenkins pipeline
* 9 Github Repository secrets to be used by the aforementioned workflows.

### flow of the automation
* a push is made to the default branch of a Github repo
* workflow 'BUILD' is triggered by push
* Jenkins pipeline is triggered by BUILD
* workflow 'CREATE_CANARY' is triggered by jenkins
* Jenkins waits for user input to either promote or remove the canary
* workflow 'PROMOTE_CANARY' || 'REJECT_CANARY' is triggered by the pipeline

### Configureation
* set up a Jenkins Pipeline
** be sure to either set the Authentication Token to 'load_test' or adjust the  'curl' command within the 'handoff_to_jenkins' job of 'Build.yml' with the appropriate token
* adjust the following Repository Secrets appropriately
** TODO: 
* make sure that the following pods exist on the cluster (their manifests have been applied) before attempting to run a workflow for a given microservice:
** ~-deployment
** ~-load-test-deployment
** ~-canary-deployment
** ~-service
** ~-load-test-service
*** '~' refers to the name of the microservice

## potential pitfalls/further development ideas
* only workflows extant in the default branch of a repository will appear in the 'Aactions' tab of that repository
* each individual 'run' tag within a workflow defined a new instance of a shell to run in.  Actions taken in one do not persist beyond the length of that tun-tag
* commented out lines within the 'run' tag will cause the workflow to fail.
** they system does not properly handle comments as they are read as shell commands and thus the commenting format will be read as improper syntax

## The Github Actions

### Descriptions of Github Actions
Below are listed the tasks performed by each Workflow

#### BUILD
* trigger: a push to the default branch
* sonar_maven_build
** converts the current version of the src code into a Docker Image, then pushes said image to the AWS ECR
*** the current Github Hash is used as the tag for this image
* access_aws_set_loadtest_deployment
** update the image of the lost-test deployment to the newly pushed image
** spin-up the load-test deployment to the same number of replicas that the production should have if the new cannary should end up being deployed.
* handoff_to_jenkins
** trigger the associated Pipeline so that load-testing can be performed

#### CREATE_CANARY
* trigger: an HTTP POST request send by the Jenkins Pipeline
* access_aws:
** spin-down the load-test-deployment to dormancy
** update the canary-deployment to the newly pushed image
** spin-up the canary-deployment to a single replica-set for production testing

#### Promote_Canary
* trigger: an HTTP POST request send by the Jenkins Pipeline
* access_aws:
** update the prucution deployment to the newly pushed image
** spin-down the canary-deployment to dormancy

#### Reject_Cannary
* trigger: an HTTP POST request send by the Jenkins Pipeline
* spin-down the canary-deployment to dormancy

### general notes
Github workflows are YAML files and and have the following general structure
* name tag defines the name that the Action will be displayed under
* env tag contians a list of the variables used by the workflow

## The Jenkins Pipeline
This pipeline is defined by a flat file 'Jenkinsfile' that can be found in the root directory.  The pipeline outline is as described below



## Github Repository Secrets

