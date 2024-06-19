#!/bin/bash
#---------- Login to Azure ---------- 
# Get tenantId, subscriptionId and appId from preferences.env
source preferences.env
echo -e "\n\n[UnitGenius Setup Tool]: Stored preference for tenantId: $tenantId"
echo -e "\n[UnitGenius Setup Tool]: Stored preference for subscriptionId: $subscriptionId"
echo -e "\n[UnitGenius Setup Tool]: Stored preference for appId: $appId"

echo -e "\n\n[UnitGenius Setup Tool]: Login to Azure"
login_output=$(az login)
tenantId=$(echo $login_output | jq -r '.[0].tenantId')

echo "tenantId=$tenantId" >> preferences.env
echo -e "\n\n[UnitGenius Setup Tool]: Stored preference for tenantId: $tenantId"

echo -e "\n\n[UnitGenius Setup Tool]: Your Azure subscriptions: "
az account list --output table

echo -e "\n[UnitGenius Setup Tool]: Enter your preferred subscriptionId: "
read subscriptionId

az account set --subscription $subscriptionId
echo -e "\n\n[UnitGenius Setup Tool]: Set subscription to $subscriptionId"

echo "subscriptionId=$subscriptionId" >> preferences.env
echo -e "\n\n[UnitGenius Setup Tool]: Stored preference for subscriptionId: $subscriptionId"

az aks get-credentials --resource-group unitgeniusResourceGroupEastUS --name unitgenius
echo -e "\n\n[UnitGenius Setup Tool]: Set kubectl context to AKS cluster unitgenius"

# #---------- Delete Cluster ----------
echo -e "\n\n[UnitGenius Setup Tool]: Deleting AKS cluster"
az aks delete --resource-group unitgeniusResourceGroupEastUS --name unitgenius --yes --no-wait
echo -e "\n\n[UnitGenius Setup Tool]: Deleted AKS cluster unitgenius"

# #---------- Delete RBAC for cluster ----------
echo -e "\n\n[UnitGenius Setup Tool]: Deleting service principal for AKS cluster"
az ad sp delete --id $appId
echo -e "\n\n[UnitGenius Setup Tool]: Deleted service principal for AKS cluster"

# #---------- Delete resource group ----------
echo -e "\n\n[UnitGenius Setup Tool]: Deleting resource group"
az group delete --name unitgeniusResourceGroupEastUS --yes --no-wait
echo -e "\n\n[UnitGenius Setup Tool]: Deleted resource group unitgeniusResourceGroupEastUS"

#---------- Securely handle preferred secret values ----------
# !User-> Before continuing, enter your (preffered) values for the following secret(s) in the Github repositories of the project:
# 	- Repository: unitgenius
# 	  Secret key: AUTH_DB_CONNECTION_STRING
# 	  Secret value: <the connection string to database for the auth functionality>
# 	- Repository: unitgenius, unitgenius-generationservice
# 	  Secret key: OPENAI_APIKEY
# 	  Secret value: <your api key for OpenAI.>
# 	- Repository: ALL repositories
# 	  Secret key: AZURE_CREDENTIALS
# 	  Secret value: <enter the following object:>
# 	- Repository: ALL repositories
# 	  Secret key: POSTMAN_APIKEY
# 	  Secret value: <your api key for Postman. Can be set later but is required for integration tests in pipelines to work.>
# !User-> Press enter when completed.


#---------- Commit and push change to main branch to deploy ----------
