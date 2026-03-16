# Deploy Bicep
az deployment group create --resource-group cloudresume-dev-rg --template-file infra/bicep/main.bicep --parameters infra/bicep/env/dev.bicepparam

# Apply Function App settings
az functionapp config appsettings set --resource-group cloudresume-dev-rg --name cloudresume-dev-func --settings @app/api/env/local.values.dev.json

# Deploy Function App code
zip app/cloudresume-dev-func.zip app/api/host.json app/api/function_app.py app/api/requirements.txt -j
az functionapp deployment source config-zip --resource-group cloudresume-dev-rg --name cloudresume-dev-func --src app/cloudresume-dev-func.zip
