#!/bin/bash

cd ../helm-chart-copy # from rss-inventory repository
touch tempLogs.txt 
helm upgrade kube-prometheus-stack prometheus-community/kube-prometheus-stack -f values.yaml >> tempLogs.txt
cat tempLogs.txt
rm tempLogs.txt

# This script allows you to update the helm chart if you make any changes to the values.yaml
