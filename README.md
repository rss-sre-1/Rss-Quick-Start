### Setup 

how to setup the Cluster, Pipeline, and the monitoring for The RSS Micro Service

## EKS Cluster setup

first thing you'll need is the cluster to run it on. refer to the [CapcityPlan.yml](https://github.com/rss-sre-1/Rss-Quick-Start/blob/main/Setup/CapicityPlan.md)

## Creating all the namespaces

run the following commands in the eks cluster

`kubectl create namespace docutest`
`kubectl create namespace kube-node-lease`
`kubectl create namespace kube-public`
`kubectl create namespace kube-system`
`kubectl create namespace lens-metrics`
`kubectl create namespace loadtesting`
`kubectl create namespace postgres`
`kubectl create namespace rss-account`
`kubectl create namespace rss-cart`
`kubectl create namespace rss-evaluation`
`kubectl create namespace rss-frontend`
`kubectl create namespace rss-inventory`

this will create all the namespaces we need for the cluster