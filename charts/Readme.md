## Architecture Overview (Helm App)

This Helm chart is for deploying a **sample web application** into **Azure Kubernetes Service (AKS)**. It consists of:

### Components Deployed:
- **Deployment** (`deployment.yaml`): Launches app pods using a specified Docker image.
- **Service** (`service.yaml`): Exposes the app within the cluster using a Kubernetes ClusterIP service.
- **Ingress** (`ingress.yaml`): (Optional) Configures HTTP ingress rules to expose the app outside the cluster.
- **ConfigMap** (`configmap.yaml`): Injects non-sensitive configuration settings into the pods.
- **Values File** (`values.yaml`): Contains default values for the chart (image, replica count, ports, etc.).

### Helm Values Control

The `values.yaml` file allows overriding:
- **Image repository and tag**
- **Number of replicas**
- **Container port**
- **Ingress hostname/path**
- **Environment variables** (via `configmap`)

This makes it flexible for different environments (dev, test, prod).

---

### Prerequisites

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm 3](https://helm.sh/docs/intro/install/)
- A running AKS cluster
- The Helm chart (from the GitHub repo)

---

### Step 1: Authenticate with Azure & AKS

```bash
az login
az account set --subscription <your-subscription-id>

# Get AKS credentials
az aks get-credentials --resource-group <your-rg> --name <your-aks-cluster>
```

---

### Step 2: Package or Use the Chart

Clone the repo:
```bash
git clone https://github.com/kvPrabhanjan/abb-aks-demo.git
cd abb-aks-demo/charts/aks-store-demo
```

You can now deploy this chart directly from the local folder, or package it:

```bash
helm package .
```

---

### ⚙️ Step 3: Customize Values (Optional)

Edit `values.yaml` to set:
```yaml
replicaCount: 2

image:
  repository: myacr.azurecr.io/aks-store-demo
  tag: v1
```

---

### Step 4: Deploy with Helm

Install the chart:

```bash
helm install aks-store-demo . --namespace aks-store --create-namespace
```

To upgrade:

```bash
helm upgrade aks-store-demo . --namespace aks-store
```

---

### Step 5: Verify Deployment

```bash
kubectl get pods -n aks-store
kubectl get svc -n aks-store
```

If ingress is enabled:
```bash
kubectl get ingress -n aks-store
```

You can access the app via:
- **Cluster IP** service (internal testing)
- **Ingress controller** (external access)

---

### Step 6: Uninstall

```bash
helm uninstall aks-store-demo --namespace aks-store
```

---