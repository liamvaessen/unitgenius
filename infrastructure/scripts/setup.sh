#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

#---------- Login to Azure ---------- 
echo -e "\n\n${PURPLE}[UnitGenius Setup Tool]:${NC} ${YELLOW}Logging in to Azure...${NC}"
login_output=$(az login)
tenantId=$(echo $login_output | jq -r '.[0].tenantId')
echo -e "\n\n${PURPLE}[UnitGenius Setup Tool]:${NC} ${GREEN}Logged in to Azure...${NC}"

echo -e "\n\n${PURPLE}[UnitGenius Setup Tool]:${NC} Your Azure subscriptions: "
az account list --output table

echo -e "\n${PURPLE}[UnitGenius Setup Tool]:${NC} Enter your preferred tenantId: "
read tenantId

echo "tenantId=$tenantId" > preferences.env
echo -e "\n\n${PURPLE}[UnitGenius Setup Tool]:${NC} Stored preference for tenantId: $tenantId"

echo -e "\n${PURPLE}[UnitGenius Setup Tool]:${NC} Enter your preferred subscriptionId: "
read subscriptionId

az account set --subscription $subscriptionId
echo -e "\n\n${PURPLE}[UnitGenius Setup Tool]:${NC} Set subscription to $subscriptionId"

echo "subscriptionId=$subscriptionId" >> preferences.env
echo -e "\n\n${PURPLE}[UnitGenius Setup Tool]:${NC} Stored preference for subscriptionId: $subscriptionId"

# #---------- Create resource group ----------
echo -e "\n\n${PURPLE}[UnitGenius Setup Tool]:${NC} ${YELLOW}Creating resource group...${NC}"
az group create --name unitgeniusResourceGroupEastUS --location eastus
echo -e "\n\n${PURPLE}[UnitGenius Setup Tool]:${NC} ${GREEN}Created resource group unitgeniusResourceGroupEastUS.${NC}"


# #---------- Create RBAC for cluster ----------
echo -e "\n\n${PURPLE}[UnitGenius Setup Tool]:${NC} ${YELLOW}Creating service principal with Contributor role for AKS cluster...${NC}"
sp=$(az ad sp create-for-rbac --name unitgeniusAKSClusterServicePrincipal --query "{appId:appId, password:password}" -o tsv)
read -r appId clientSecret <<< "$sp"
az role assignment create --assignee $appId --role Contributor --scope subscriptions/$subscriptionId/resourceGroups/unitgeniusResourceGroupEastUS
echo -e "\n\n${PURPLE}[UnitGenius Setup Tool]:${NC} ${GREEN}Created service principal with Contributor role for AKS cluster.${NC}"

echo "appId=$appId" >> preferences.env
echo -e "\n\n${PURPLE}[UnitGenius Setup Tool]:${NC} Stored preference for service principal appId: $appId"

#---------- Create Cluster ----------
echo -e "\n\n${PURPLE}[UnitGenius Setup Tool]:${NC} ${YELLOW}Creating AKS cluster...${NC}"
az aks create --resource-group unitgeniusResourceGroupEastUS --name unitgenius --service-principal $appId --client-secret $clientSecret --node-count 2 --generate-ssh-keys
echo -e "\n\n${PURPLE}[UnitGenius Setup Tool]:${NC} ${GREEN}Created AKS cluster unitgenius.${NC}"


#---------- Set kubectl context ----------
az aks get-credentials --resource-group unitgeniusResourceGroupEastUS --name unitgenius
echo -e "\n\n${PURPLE}[UnitGenius Setup Tool]:${NC} Set kubectl context to AKS cluster unitgenius"


#---------- Securely handle preferred secret values ----------
echo -e "\n\n${PURPLE}[UnitGenius Setup Tool]:${NC} Before continuing, enter your (preffered) values for the following secret(s) in the Github repositories of the project:"
echo -e ""
echo -e "${PURPLE}[UnitGenius Setup Tool]:${NC}   - Repository: unitgenius"
echo -e "${PURPLE}[UnitGenius Setup Tool]:${NC}     Secret key: AUTH_DB_CONNECTION_STRING"
echo -e "${PURPLE}[UnitGenius Setup Tool]:${NC}     Secret value: the connection string to database for the auth functionality"
echo -e ""
echo -e "${PURPLE}[UnitGenius Setup Tool]:${NC}   - Repository: unitgenius, unitgenius-generationservice"
echo -e "${PURPLE}[UnitGenius Setup Tool]:${NC}     Secret key: OPENAI_APIKEY"
echo -e "${PURPLE}[UnitGenius Setup Tool]:${NC}     Secret value: your api key for OpenAI."
echo -e ""
echo -e "${PURPLE}[UnitGenius Setup Tool]:${NC}   - Repository: ALL repositories"
echo -e "${PURPLE}[UnitGenius Setup Tool]:${NC}     Secret key: AZURE_CREDENTIALS"
echo -e "${PURPLE}[UnitGenius Setup Tool]:${NC}     Secret value: enter the following object: 
{
  "'clientId'": ""$appId"",
  "'clientSecret'": ""$clientSecret"",
  "'tenantId'": ""$tenantId"",
  "'subscriptionId'": ""$subscriptionId""
}"
echo -e ""
echo -e "${PURPLE}[UnitGenius Setup Tool]:${NC}   - Repository: ALL repositories"
echo -e "${PURPLE}[UnitGenius Setup Tool]:${NC}     Secret key: POSTMAN_APIKEY"
echo -e "${PURPLE}[UnitGenius Setup Tool]:${NC}     Secret value: your api key for Postman. Can be set later but is required for integration tests in pipelines to work."
echo -e ""
echo -e "${PURPLE}[UnitGenius Setup Tool]:${NC} Press enter when completed:"
read -r

#---------- Commit and push change to main branch to deploy ----------
echo -e "\n\n${PURPLE}[UnitGenius Setup Tool]:${NC} ${YELLOW}Trying to commit and push change to main branch to deploy...${NC}"
git add .
git commit -m "Setup AKS cluster"
git push origin main
echo -e "\n\n${PURPLE}[UnitGenius Setup Tool]:${NC} ${GREEN}Done committing and pushing change to main branch to deploy.${NC}"


echo -e "\n\n${PURPLE}[UnitGenius Setup Tool]:${NC} ${GREEN}DONE... Setup of Azure environment completed successfully${NC}"
