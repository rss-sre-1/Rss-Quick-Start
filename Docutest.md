# Docutest

## Overview

Docutest is an application used by RSS to load test service build prior to deployment. An instance of the application exist on the K8 cluster, as well as PostgreSQL database used to store test summaries. Individual data (ie. results of a number of threads sending requests to a given endpoint) is stored within an Amazon S3 external to the cluster. Our version of Docutest was forked from a previous version with a few minor changes. The source code as well as some documentation are available here: https://github.com/rss-sre-1/Docutest.
