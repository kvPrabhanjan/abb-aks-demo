---

## Architecture Overview

The Terraform scripts provision the following Azure resources:

- **Resource Group**: A logical container to hold all related resources.
- **Azure Kubernetes Service (AKS)**: Manages the Kubernetes cluster for deploying containerized applications.
- **Azure Key Vault**: Securely stores secrets and sensitive configuration data.
- **Azure Monitor (Application Insights)**: Provides monitoring and diagnostics for the applications.
- **Azure Storage Account**: Stores the Terraform state file, enabling collaboration and state management.

---

## Architecture Diagram

Here's a simplified representation of the infrastructure:

```
+-----------------------+
|   Azure Resource Group|
+----------+------------+
           |
           v
+-----------------------+
|        AKS Cluster    |
|  (Azure Kubernetes    |
|      Service)         |
+----------+------------+
           |
           v
+-----------------------+
|   Application Insights|
|   (Monitoring)        |
+-----------------------+

+-----------------------+
|      Key Vault        |
|  (Secrets Management) |
+-----------------------+

+-----------------------+
|   Storage Account     |
| (Terraform State File)|
+-----------------------+
```

---

## Azure Services Utilized

- **Azure Kubernetes Service (AKS)**: Hosts and manages the Kubernetes cluster.
- **Azure Key Vault**: Stores secrets, keys, and certificates securely.
- **Azure Monitor (Application Insights)**: Monitors the performance and health of applications.
- **Azure Storage Account**: Stores the Terraform state file for infrastructure state management.

---

## Deployment Instructions

### Prerequisites

- **Azure CLI**: Installed and authenticated.
- **Terraform**: Installed on your local machine.
- **Azure Subscription**: With necessary permissions to create resources.

### Steps

1. **Clone the Repository**

   ```bash
   git clone https://github.com/kvPrabhanjan/abb-aks-demo.git
   cd abb-aks-demo/infra/terraform
   ```

2. **Initialize Terraform**

   ```bash
   terraform init
   ```

   This command initializes the Terraform working directory and downloads the necessary providers.

3. **Review and Customize Variables**

   Review the `variables.tf` file and create a `terraform.tfvars` file to set your custom values:

   ```hcl
   resource_group_name = "your-resource-group-name"
   location            = "your-azure-region"
   aks_cluster_name    = "your-aks-cluster-name"
   ...
   ```

4. **Plan the Deployment**

   ```bash
   terraform plan
   ```

   This command shows the execution plan and the resources that will be created.

5. **Apply the Configuration**

   ```bash
   terraform apply
   ```

   Confirm the action when prompted. Terraform will provision the resources as defined.

---

## Additional Notes

- **State Management**: The Terraform state file is stored in the specified Azure Storage Account container, enabling collaboration and state locking.
- **Security**: Ensure that sensitive information is stored securely in Azure Key Vault and not hard-coded in the Terraform files.
- **Monitoring**: Application Insights provides telemetry data to monitor the performance and usage of your applications deployed in AKS.

---