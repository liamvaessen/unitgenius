#!/bin/bash
az aks create --resource-group unitgeniusResourceGroupEastUS --name unitgenius --node-count 1 --generate-ssh-keys
az aks get-credentials --resource-group unitgeniusResourceGroupEastUS --name unitgenius