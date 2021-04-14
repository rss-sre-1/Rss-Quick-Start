### Bash Scripts and any other scripting files used to help setup, manage, and monitor the system.


#### Sebastian
Sebastian is a light weight script that continuous calls provided pipeline (Pipeline.sh) style scripts.

##### Usage:
###### Requirements
- Git Bash or a linux terminal with a bash shell.

###### Startup
Set the location of the pipeline.sh script in the ADD PIPELINE SCRIPT LOCATIONS HERE section. The current Pipeline.sh is set to execute from the local directory. For executing from a parent directory use ../PATH TO FILE/Pipeline.sh, for child directories or sub folders of the current folder use ./PATH TO FILE/Pipeline.sh

Increase or decrease the interval between attempting the pipeline by changing the Interval variable (s second, m minute, h hour).
To stop Sebastian, enter the following command in the same directory, ``echo " " > stop;`` or create a file in the same directory call stop with content in it. Running Sebastian.sh again will give you to option to remove the file in order to continue. Alternatively, when the process is sleeping, not outputing from an active pipeline, you can press \[CRTL\] + C to end the script.

#### Pipeline
This script mimics a pipeline, such as in jenkins, currently having stages for image building with Docker and deployment on a kubernetes cluster with kubectl. It will scrape a github repository's commit page comparing a previous logged commit to the one it finds. If it finds a new commit it will run a git pull (this file must be placed in the local repo directory), build & push a new docker image, then reapply the image onto the deployment.

##### Usage:
###### Requirements
- DockerDesktop installed and running.
- Git Bash or a linux terminal with a bash shell.
- Curl installed (check with ``curl --version``).

###### Startup
Modify the variables at the start of the file as needed to your github repository and and docker information. Only change the File names if those are already being used in the directory you are putting Pipeline.sh in.

