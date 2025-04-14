# GitHub Actions Workflow: 

## CodeQL Workflow

This GitHub Actions workflow is a **CodeQL analysis workflow** used for **code scanning** to detect security vulnerabilities, bugs, and quality issues in your repository’s source code.

---

### **Trigger Conditions**  
This workflow runs in three scenarios:

1. **Push to `main` branch**  
2. **Pull request to `main` branch**  
3. **Every Tuesday at 17:17 UTC (via cron schedule)**

```yaml
on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]
  schedule:
    - cron: '17 17 * * 2' # Every Tuesday at 17:17
```

---

### **What It Does**

#### 1. **Matrix-based CodeQL Analysis**
The job `analyze` runs for each specified language in a matrix:
```yaml
matrix:
  include:
  - language: actions
  - language: go
  - language: javascript-typescript
  - language: python
```

Each language is analyzed independently using CodeQL with corresponding `build-mode`.

---

#### 2. **Main Steps of the Workflow**

| Step | Description |
|------|-------------|
| **Checkout repository** | Pulls down the source code. |
| **Initialize CodeQL** | Sets up CodeQL analysis for the specific language and build mode. |
| **Manual build placeholder** | Shown if you opt for a manual build mode (not needed for Go, JS, Python, etc.). |
| **Run analysis** | Performs CodeQL static analysis to find vulnerabilities or code issues. |

---

## What Happens If Vulnerabilities Are Found?

- **Findings will appear in the GitHub Security tab** of your repository.
- Each PR or commit can show annotations if it introduces new issues.
- Alerts may be displayed with severity levels (low, medium, high).
- We can configure policies to **block pull requests** with critical findings.

---

---

## Micro-Service Workflow 
Thse workflow is designed to automatically **build and publish a Docker image** for all the microservices (**ai-service,makeline-service,order-service,product-service,store-admin,store-front,virtual-customer and virtual-worker**)  to the **GitHub Container Registry (GHCR)** when:

- Code is pushed to the `main` branch under `src/virtual-worker/`
- Or the workflow is manually triggered via the GitHub UI

---

### Trigger Conditions

```yaml
on:
  push:
    branches:
      - 'main'
    paths:
      - 'src/virtual-worker/**'
  workflow_dispatch:
```

- **Push trigger**: The workflow runs automatically when files under `src/virtual-worker/` are updated on the `main` branch.
- **Manual trigger**: You can also trigger it manually using the "Run workflow" button in the GitHub Actions UI.

---

### Permissions

```yaml
permissions:
  contents: read
  packages: write
```

- Grants the workflow permission to **read repository content** and **write to GitHub Packages (GHCR)**.

---

### Job: `publish-container-image`

This job runs on `ubuntu-latest` and handles the full lifecycle of Docker image building and publishing.

#### 🔹 1. Set Environment Variables

```yaml
- name: Set environment variables
  id: set-variables
```

This step dynamically sets and outputs the following environment variables:

| Variable | Description |
|----------|-------------|
| `REPOSITORY` | The GitHub Container Registry path for the image (e.g., `ghcr.io/owner/repo`) |
| `IMAGE` | The image name  |
| `VERSION` | The shortened Git commit SHA (first 7 characters) |
| `CREATED` | The UTC timestamp when the image was built |

---

#### 🔹 2. Log Variable Outputs (Optional Debug)

```yaml
- name: Env variable output
  id: test-variables
```

This step simply echoes the variables to the logs for verification during the run.

---

#### 🔹 3. Checkout Code

```yaml
- name: Checkout code
  uses: actions/checkout@v2
```

Pulls the repository code so Docker can build from the local `src/virtual-worker` directory.

---

#### 🔹 4. Set Up Docker Buildx

```yaml
- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@v2
```

Enables **multi-platform image building** (`amd64` and `arm64`) using Docker Buildx.

---

#### 🔹 5. Login to GitHub Container Registry

```yaml
- name: Login to GitHub Container Registry
  uses: docker/login-action@v1
```

Authenticates Docker to **GHCR** using GitHub Actions’ built-in `github.actor` and `github.token`.

---

### 🔹6. Set up Python

```yaml
- name: Set up Python
  uses: actions/setup-python@v4
  with:
    python-version: '3.11'
```
---

### 🔹7. Install Linting Dependencies

```yaml
- name: Install Linting Dependencies
  run: |
    python -m pip install --upgrade pip
    pip install flake8
```
---

### 🔹8. Run Flake8 Linter

```yaml
- name: Run Flake8 Linter
  run: flake8 src/ai-service --count --select=E9,F63,F7,F82 --show-source --statistics
```

**What it does:**
- Runs `flake8` to lint the code in `src/ai-service`.
- It **only checks for major errors** (`E9`, `F63`, `F7`, `F82`).
- Outputs:
  - Count of errors
  - The actual line of code where errors occur
  - A summary with statistics

---

#### 🔹 9. Build & Push Docker Image

```yaml
- name: Build and push
  uses: docker/build-push-action@v2
```

Builds the Docker image from `src/virtual-worker/Dockerfile` and **pushes it to GHCR** under two tags:
- `latest`
- The Git commit SHA (shortened)

It also attaches metadata labels for traceability.

---

### Example Image Tag Generated

```
ghcr.io/owner-name/repo-name/virtual-worker:latest
ghcr.io/owner-name/repo-name/virtual-worker:abc1234
```

---
---

## Deploy to AKS Workflow

This GitHub Actions **workflow** is named **"Deploy to AKS"**, and it's designed to **manually trigger a deployment** of aks-store application to an **Azure Kubernetes Service (AKS)** cluster using **Helm**.


## Step-by-Step Breakdown

| Step | Purpose |
|------|---------|
| **Set service variables** | Prepares repo info and timestamps for use later. |
| **Checkout code** | Clones the repository to the runner. |
| **Login to Azure** | Authenticates to Azure using credentials in `AZURE_CREDENTIALS` secret. |
| **Login to GitHub Container Registry** | Authenticates Docker to pull images from GHCR. |
| **Get AKS credentials** | Runs `az aks get-credentials` to connect to the cluster. |
| **Setup kubectl** | Installs `kubectl` for interacting with the AKS cluster. |
| **Setup kubelogin** | Enables Azure AD-based login to Kubernetes with `kubelogin`. |
| **Set AKS context** | Applies Kubernetes context using Azure CLI and Azure AD. |
| **Run kubectl** | Validates connection by listing pods. |
| **Deploy using Helm** | Installs/updates the Helm release from the chart in `charts/aks-store-demo`. |

```bash
helm upgrade --install aks-store-demo ./charts/aks-store-demo \
  --namespace aks-store \
  --create-namespace
```

---

## What Happens After Running?

1. Connects to the AKS cluster (`aks-aksstore` in resource group `rg-aks-store`).
2. Pulls the app image (tagged with commit SHA) from GHCR.
3. Uses the Helm chart in `charts/aks-store-demo` to **install or upgrade** the application in namespace `aks-store`.

---
