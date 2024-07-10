# Setup Azure Databricks using Terraform

This repository streamlines the process of setting up Azure Databricks on your Azure subscription with the help of Terraform.

### Prerequisites:

##### Azure Account: An active Azure subscription with necessary permissions.
##### Terraform: Terraform installed on your local machine. You can download it from https://www.terraform.io/downloads.html
##### Azure CLI: The Azure CLI installed and authenticated (az login).

### Project Setup:

##### Create a Directory: Make a new directory to hold your Terraform configuration files.
##### Terraform Init: Navigate to the directory in your terminal and run terraform init to initialize the project and download the required providers (Azure and Databricks).

### Configuration Files:

##### Environment Variables with your azure cloud subscription

export ARM_CLIENT_ID="xxxxxxxxxxx"
export ARM_CLIENT_SECRET="xxxxxxxxxxx"
export ARM_SUBSCRIPTION_ID="xxxxxxxxxxx"
export ARM_TENANT_ID="xxxxxxxxxxx"