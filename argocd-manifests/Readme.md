# Argo CD - Installation and Configuration

## Step-by-Step Commands

1. **Create `argocd` namespace in Kubernetes**
   ```bash
   kubectl create namespace argocd
   ```

2. **Install Argo CD into the `argocd` namespace**
   ```bash
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

3. **Download and install the Argo CD CLI**
   ```bash
   brew install argocd
   ```

4. **Access the Argo CD API Server (port-forwarding)**
   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```

5. **Login to Argo CD CLI**
   ```bash
   argocd login localhost:8080
   ```

6. **Get initial admin password**
   ```bash
   kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
   ```

7. **Change admin password **
   ```bash
   argocd account update-password
   ```
---

### Appliation.yaml File Explaination

- **`metadata.name`**: Name of the Argo CD Application.
- **`namespace`**: Kubernetes namespace where the app is managed.
- **`repoURL`**: GitHub repo URL containing the app configuration.
- **`targetRevision`**: Branch or tag to track (e.g., `HEAD`).
- **`path`**: Directory in repo containing Kubernetes manifests or Helm chart.
- **`destination.server`**: Cluster to deploy to (in-cluster in this case).
- **`destination.namespace`**: Namespace in which to deploy the app.

To apply this manifest:
```bash
kubectl apply -f argocd-manifests/argocd-app.yaml
```

---

### Output 

```bash
# argocd app get argocd-manifests

Name:               argocd/argocd-manifests
Project:            default
Server:             https://kubernetes.default.svc
Namespace:          aks-store
URL:                https://localhost:8080/applications/argocd-manifests
Source:
- Repo:             https://github.com/kvPrabhanjan/abb-aks-demo.git
  Target:           
  Path:             argocd-manifests
SyncWindow:         Sync Allowed
Sync Policy:        Manual
Sync Status:        Synced to  (5162d16)
Health Status:      Healthy

```

