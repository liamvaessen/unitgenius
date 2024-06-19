#!/bin/bash
kubectl apply -f ./infrastructure/kubernetes/.
kubectl apply -f ./infrastructure/kubernetes/unitgenius-rabbitmq/.
kubectl apply -f ./infrastructure/kubernetes/enable-database-execution/.
kubectl apply -f ./infrastructure/kubernetes/enable-database-engine/.