#!/bin/bash
#For this program to run the pipeline, a MiniPipeline.sh file must be present in the same directory as this file.

Interval="59s";

# CHECKING FOR STOP FILE
if [ "$(ls | grep stop 2> /dev/null)" == "stop" ]; then
  read -p "File 'stop' found. Remove and continue? (y/n): ";
  if [ "$REPLY" != "y" ]; then
    exit;
  else
    rm stop &> /dev/null;
  fi
fi
stop=$(cat stop 2> /dev/null);

# The loop does not stop until there is a file named 'stop' with content in it.
while [ "$stop" == "" ]; do
  echo $(date +"%T") - ;

## ADD PIPELINE SCRIPT LOCATIONS HERE | FOLLOWED BY PROJECT DIRECTORY PATH ##
  ./rss-evaluation-service/PipelineScript/Pipeline.sh $PWD/rss-evaluation-service/;
  ./rss-frontend/MiniPipeline.sh $PWD/rss-frontend/;

##############################################################################

  echo " - ";
  sleep $Interval;
  stop=$(cat stop 2> /dev/null);
done

rm $TempFile &> /dev/null;
