# AKS Demo App for ABB interview

This repository demonstrates a complete end-to-end AI application deployment on **Azure Kubernetes Service (AKS)** using **Terraform**, **Helm**, and **GitHub Actions**.

It includes:

- A sample AI app located in `src/`
- Infrastructure as Code (IaC) using Terraform in `infra/terraform/`
- Helm chart for Kubernetes packaging in `charts/aks-store-demo/`
- GitHub Actions workflows for CI/CD in `.github/workflows/`
- Argo CD configuration and Manifest Files in `argocd-manifests/`
```
---

```

## Project Structure


abb-aks-demo/
│
├── charts/
│   └── aks-store-demo/      # Helm chart for deploying app on AKS
│
├── infra/
│   └── terraform/           # Terraform scripts for provisioning Azure resources
│
├── src/
│   ├── virtual-worker/      # Sample AI application logic and Dockerfile
│   └── ...                  # Other application components
│
└── .github/
    └── workflows/           # CI/CD pipelines for Docker, Helm deployment, and Infra provisioning
```

---

## Workflow Summary

### 1. **Terraform Infrastructure**
- Located in `infra/terraform/`
- Provisions:
  - Resource Group
  - Azure Kubernetes Service (AKS) Cluster
  - Azure Container Registry (ACR)
  - Log Analytics / Monitoring
- Uses remote state via Azure Blob storage

To deploy infrastructure:
```bash
cd infra/terraform
terraform init
terraform plan
terraform apply
```

> Use `terraform import` if resources already exist.

---

### 2. **GitHub Actions CI/CD**

#### a. Docker Image Build & Push
- Triggered on code changes in `src/virtual-worker/`
- Defined in `.github/workflows/package-virtual-worker.yaml`
- Builds Docker image and pushes to GitHub Container Registry (GHCR)

#### b. Helm Deployment to AKS
- Helm chart: `charts/aks-store-demo/`
- A separate workflow handles Helm deployment after image build.
- Connects to AKS using Azure Service Principal with appropriate role assignments.

---

### 3. **Helm Chart**
- Parameterized and reusable chart for deploying the application.
- Located at `charts/aks-store-demo/`
- Includes Kubernetes `Deployment`, `Service`, and `Ingress` definitions.

To install manually:
```bash
helm install aks-store-demo ./charts/aks-store-demo --set image.repository=<repo> --set image.tag=<tag>
```

---
### 4. **Argo CD Configs**
- All in one App deployment configuration file
- Argo CD Configurations file