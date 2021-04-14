#!/bin/bash

if [[ $1 == "get" && $2 != "all" ]]; then
echo "=========Kubernetes========"
kubectl -n kube-node-lease $@
kubectl -n kube-public $@
kubectl -n kube-system $@
echo "==========Default=========="
kubectl -n default $@
echo "=========Docutest=========="
kubectl -n docutest $@
echo "=========Postgres=========="
kubectl -n postgres $@
echo "============RSS============"
kubectl -n rss-account $@
kubectl -n rss-cart $@
kubectl -n rss-evaluation $@
kubectl -n rss-frontend $@
kubectl -n rss-inventory $@
else
kubectl $@
fi

