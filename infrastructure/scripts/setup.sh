#!/bin/bash
#---------- Login to Azure ---------- 
source preferences.env
echo -e "\n\n[UnitGenius Setup Tool]: Stored preference for tenantId: $tenantId"
echo -e "\n[UnitGenius Setup Tool]: Stored preference for subscriptionId: $subscriptionId"
echo -e "\n[UnitGenius Setup Tool]: Stored preference for appId: $appId"

# echo -e "\n\n[UnitGenius Setup Tool]: Login to Azure"
# login_output=$(az login)
# tenantId=$(echo $login_output | jq -r '.[0].tenantId')

# # echo "tenantId=$tenantId" >> preferences.env
# echo -e "\n\n[UnitGenius Setup Tool]: Stored preference for tenantId: $tenantId"

# echo -e "\n\n[UnitGenius Setup Tool]: Your Azure subscriptions: "
# az account list --output table

# echo -e "\n[UnitGenius Setup Tool]: Enter your preferred subscriptionId: "
# read subscriptionId

# az account set --subscription $subscriptionId
# echo -e "\n\n[UnitGenius Setup Tool]: Set subscription to $subscriptionId"

# # echo "subscriptionId=$subscriptionId" >> preferences.env
# echo -e "\n\n[UnitGenius Setup Tool]: Stored preference for subscriptionId: $subscriptionId"


# # #---------- Create resource group ----------
# echo -e "\n\n[UnitGenius Setup Tool]: Creating resource group"
# az group create --name unitgeniusResourceGroupEastUS --location eastus
# echo -e "\n\n[UnitGenius Setup Tool]: Created resource group unitgeniusResourceGroupEastUS"


# # #---------- Create RBAC for cluster ----------
# echo -e "\n\n[UnitGenius Setup Tool]: Creating service principal for AKS cluster"
# sp=$(az ad sp create-for-rbac --name unitgeniusAKSClusterServicePrincipal --query "{appId:appId, password:password}" -o tsv)
# read -r appId clientSecret <<< "$sp"
# echo -e "\n\n[UnitGenius Setup Tool]: Created service principal for AKS cluster"

# # echo "appId=$appId" >> preferences.env
# echo -e "\n\n[UnitGenius Setup Tool]: Stored preference for service principal appId: $appId"


# #---------- Create Cluster ----------
# echo -e "\n\n[UnitGenius Setup Tool]: Creating AKS cluster"
# az aks create --resource-group unitgeniusResourceGroupEastUS --name unitgenius --service-principal $appId --client-secret $clientSecret --node-count 1 --generate-ssh-keys
# echo -e "\n\n[UnitGenius Setup Tool]: Created AKS cluster unitgenius"


# #---------- Set kubectl context ----------
# az aks get-credentials --resource-group unitgeniusResourceGroupEastUS --name unitgenius
# echo -e "\n\n[UnitGenius Setup Tool]: Set kubectl context to AKS cluster unitgenius"


#---------- Securely handle preferred secret values ----------
# !User-> Before continuing, enter your (preffered) values for the following secret(s) in the Github repositories of the project:
echo -e "\n\n[UnitGenius Setup Tool]: Before continuing, enter your (preffered) values for the following secret(s) in the Github repositories of the project:"
echo -e ""
echo -e "[UnitGenius Setup Tool]:   - Repository: unitgenius"
echo -e "[UnitGenius Setup Tool]:     Secret key: AUTH_DB_CONNECTION_STRING"
echo -e "[UnitGenius Setup Tool]:     Secret value: the connection string to database for the auth functionality"
echo -e ""
echo -e "[UnitGenius Setup Tool]:   - Repository: unitgenius, unitgenius-generationservice"
echo -e "[UnitGenius Setup Tool]:     Secret key: OPENAI_APIKEY"
echo -e "[UnitGenius Setup Tool]:     Secret value: your api key for OpenAI."
echo -e ""
echo -e "[UnitGenius Setup Tool]:   - Repository: ALL repositories"
echo -e "[UnitGenius Setup Tool]:     Secret key: AZURE_CREDENTIALS"
echo -e "[UnitGenius Setup Tool]:     Secret value: enter the following object: 
{
  '"clientId"': '"$appId"',
  '"clientSecret"': '"$password"',
  '"tenantId"': '"$tenantId"',
  '"subscriptionId"': '"$subscriptionId"'
}"
echo -e ""
echo -e "[UnitGenius Setup Tool]:   - Repository: ALL repositories"
echo -e "[UnitGenius Setup Tool]:     Secret key: POSTMAN_APIKEY"
echo -e "[UnitGenius Setup Tool]:     Secret value: your api key for Postman. Can be set later but is required for integration tests in pipelines to work."
echo -e ""
echo -e "[UnitGenius Setup Tool]: Press enter when completed:"

#---------- Commit and push change to main branch to deploy ----------
echo -e "\n\n[UnitGenius Setup Tool]: Commit and push change to main branch to deploy"
git add .
git commit -m "Setup AKS cluster"
git push origin main
echo -e "\n\n[UnitGenius Setup Tool]: Committed and pushed change to main branch to deploy"