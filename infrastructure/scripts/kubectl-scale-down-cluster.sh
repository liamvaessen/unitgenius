#!/bin/bash
for deployment in $(kubectl get deployments -o jsonpath='{.items[*].metadata.name}')
do
  kubectl scale --replicas=0 deployment/$deployment
done