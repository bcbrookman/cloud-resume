# Deploy Bicep
az deployment group create --resource-group cloudresume-prd-rg --template-file infra/bicep/main.bicep --parameters infra/bicep/env/prd.bicepparam

# Apply Function App settings
az functionapp config appsettings set --resource-group cloudresume-prd-rg --name cloudresume-prd-func --settings @app/api/env/local.values.prd.json

# Deploy Function App code
zip app/cloudresume-prd-func.zip app/api/host.json app/api/function_app.py app/api/requirements.txt -j
az functionapp deployment source config-zip --resource-group cloudresume-prd-rg --name cloudresume-prd-func --src app/cloudresume-prd-func.zip
