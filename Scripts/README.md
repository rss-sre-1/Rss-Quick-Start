## Bash Scripts and any other scripting files used to help setup, manage, and monitor the system.

### Scripts
- [Sebastian.sh](#sebastian)
- [Pipeline.sh](#pipeline)
- [kubectl.sh](#kubectl)
- [superkube.sh](#superkube)


### Sebastian
Sebastian is a light weight script that continuous calls provided pipeline (Pipeline.sh) style scripts.

##### Usage:
###### Startup
Set the location of the pipeline.sh script in the ADD PIPELINE SCRIPT LOCATIONS HERE section. The current Pipeline.sh is set to execute from the local directory. For executing from a parent directory use ../PATH TO FILE/Pipeline.sh, for child directories or sub folders of the current folder use ./PATH TO FILE/Pipeline.sh

Increase or decrease the interval between attempting the pipeline by changing the Interval variable (s second, m minute, h hour).
To stop Sebastian, enter the following command in the same directory in a new terminal, ``echo " " > stop;`` or create a file in the same directory call stop with content in it. Running Sebastian.sh again will give you to option to remove the file in order to continue. Alternatively, when the process is sleeping, not outputing from an active pipeline, you can press \[CRTL\] + C to end the script.

### Pipeline
This script mimics a pipeline, such as in jenkins, currently having stages for image building with Docker and deployment on a kubernetes cluster with kubectl. It will scrape a github repository's commit page comparing a previous logged commit to the one it finds. If it finds a new commit it will run a git pull (this file must be placed in the local repo directory), build & push a new docker image, then reapply the image onto the deployment.

##### Usage:
###### Requirements
- DockerDesktop installed and running.
- Curl installed (check with ``curl --version``).

###### Startup
Modify the variables at the start of the file as needed to your github repository and and docker information. Only change the File names if those are already being used in the directory you are putting Pipeline.sh in.

### kubectl
Simplifies the use of running kubectl command in a namespace you plan to frequently access. This file speeds up the typing process by automatically adding a predefined namespace set inside the kubectl.sh file. For entering commands even faster type ./k or ./ku, given there are no other .sh files in the current directory starting with "k" or "ku", and the terminal will automatically fill in the rest to be ./kubectl.sh. 

##### Usage:
examples:
- ./kubectl.sh get all
- ./kubectl.sh apply -f deployment.yml

### superkube
A DevOps script for performing get commands across the following namespaces: kube-node-lease, kube-public, kube-system, default, docutest, postgress, rss-account, rss-cart, rss-evaluation, rss-frontend, rss-inventory. Attempting `get all` or any other commands will output the response of a regular kubectl command.

##### Usage:
examples:
- ./superkube.sh get pods
- ./superkube.sh get deployments


