# OpenTofu FaaS Lab — Azure Functions

> **Laboratory Work 05** — Integrated Services Networks & Cloud Technologies (VilniusTech)

This lab replaces the Azure portal setup with infrastructure and deployment automation. A Linux Consumption Function App, Storage Account, and Application Insights instance are created with Terraform/OpenTofu, and the Python function code is deployed through the Azure CLI during `apply`.

## What Is Automated

- Resource Group
- Storage Account
- Linux Consumption plan
- Function App on Azure Functions runtime v4
- Application Insights monitoring
- Deployment of an HTTP trigger and a timer trigger from local source code

## Project Structure

```text
Lab5/
├── versions.tf
├── providers.tf
├── variables.tf
├── main.tf
├── outputs.tf
├── function_src/
│   ├── function_app.py
│   ├── host.json
│   └── requirements.txt
├── scripts/
│   ├── build-function-package.sh
│   └── deploy-function-code.sh
├── README.md
└── 05 - lab - functions EN.txt
```

## Quick Start

1. Authenticate with Azure:

```bash
az login
```

2. Deploy everything:

```bash
terraform init
terraform apply
```

During `apply`, Terraform provisions the Azure resources first and then uses the Azure CLI to package and deploy the function code.

## What Gets Deployed

- `GET /api/hello?name=<your name>`
  Returns a JSON message and echoes extra query parameters to help with the lab question about adding attributes.
- A timer-triggered function
  Runs every minute and writes a timestamped log entry to Application Insights.

## Useful Commands

```bash
terraform output http_function_url
terraform output app_insights_name

curl "$(terraform output -raw http_function_url)?name=Mark&course=Cloud"
```

## Cleanup

```bash
terraform destroy
```

## Notes

- The function code is packaged locally with Python dependencies before zip deployment.
- `az login` must be active on the machine that runs Terraform.
- If your subscription blocks a region, change `location` in `variables.tf` or `terraform.tfvars`.
