## GitHub Actions Workflow: 

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

#### 🔹 6. Build & Push Docker Image

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
