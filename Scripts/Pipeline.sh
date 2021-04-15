#!/bin/bash
#PIPELINE VARIABLES
Namespace="rss-evaluation"

ImageRegistry="855430746673.dkr.ecr.us-east-1.amazonaws.com";
ImageName="matt-oberlies-sre-p3-rss-evaluation";
ImageTag="latest";
DockerfileLocation="../Evaluation/";

DeploymentName="rss-evaluation-deployment";
########################### THE RELATIVE PATH + MANIFEST FILENAME.
DeploymentManifestLocation="rss-evaluation-manifests/rss-evaluation-deployment.yaml";

#COMMIT PROBE SETTINGS
Org="rss-sre-1";
Repo="rss-evaluation-service";
Branch="dev";


#ONLY CHANGE IF YOU ALREADY HAVE FILES WITH THESE NAMES WITH DATA UNRELATED TO THE PIPELINE
GatherFile="11111111113";
BaseFile="11111111112";
TempFile="11111111111";

#DO NOT CHANGE THESE VARIABLES
URL="https://github.com/$Org/$Repo/commits/$Branch";
GrepURL="https://github.com/$Org/$Repo/commit/";

# CHANGE TO PROJECT ROOT DIRECTORY GIVEN BY SEBASTIAN.SH
if [ "$1" != "" ]; then
  cd $1;
fi
## TODO - add path checking and error msg -



# CHECKING FOR BASE FILE STORING OLD COMMIT
rm $TempFile &> /dev/null;
if [ "$(ls | grep $BaseFile 2> /dev/null)" != "$BaseFile" ]; then
  echo "" > $BaseFile;
  curl $URL -s -o $BaseFile; # 2> /dev/null;
  cat $BaseFile | grep $GrepURL > $GatherFile; # get initial commit
  mv $GatherFile $BaseFile;
#else
#  echo "Previous commit found.";
fi
echo "" > $TempFile;


# GET CURRENT COMMIT
  curl $URL -s -o $TempFile; # 2> /dev/null;
  cat $TempFile | grep $GrepURL > $GatherFile;
  mv $GatherFile $TempFile;

# CHECK IF NEW COMMIT DOES NOT MATCH OLD COMMIT
if [ "$(diff $BaseFile $TempFile)" != "" ]; then
  #read -p "continue?"
  echo "Change found, starting pipeline.";
  #mv $TempFile $BaseFile;


  touch DF;
  err="$(aws ecr get-login-password --profile sre | docker login --username AWS --password-stdin 855430746673.dkr.ecr.us-east-1.amazonaws.com 2>&1)";
  rm DF;
  if [[ "${err:0:5}" == "error" || "${err:0:6}" == "unable" ]]; then
    echo "ERROR: $err";
  else

####### ADD / MODIFY / REMOVE STAGES #######
#STARTING PIPELINE
#  aws ecr get-login-password --profile sre | docker login --username AWS --password-stdin 855430746673.dkr.ecr.us-east-1.amazonaws.com;
  git pull;

#BUILD STAGE
  docker build -t $ImageRegistry/$ImageName:$ImageTag ./$DockerfileLocation;
  docker push $ImageRegistry/$ImageName:$ImageTag;

#DEPLOYMENT STAGE
  kubectl -n $Namespace delete deployment $DeploymentName;
  kubectl -n $Namespace apply -f $DeploymentManifestLocation;


  mv $TempFile $BaseFile;
  fi

fi
