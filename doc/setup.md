# Setup guide

## Template structure

Prefer having one entrypoint `main.py`, with tests alongside source code in applications.

## Getting started

### Setting up Google Cloud access for GitHub Actions

#### Creating a service account

#### Authenticating with Workload Identify Federation

REPO
PROJECT_ID
SERVICE_ACCOUNT
SERVICE_NAME
WORKLOAD_ENTITY_PROVIDER

## Setup pool

```bash
gcloud iam workload-identity-pools describe "github-actions" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --format="value(name)"
```

```bash
export WORKLOAD_IDENTITY_POOL_ID=...
```

## Create provider

```bash
gcloud iam workload-identity-pools providers create-oidc "${SERVICE_NAME}" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="github-actions" \
  --display-name="GitHub Actions provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.aud=assertion.aud" \
  --issuer-uri="https://token.actions.githubusercontent.com"
```

```bash
gcloud iam workload-identity-pools providers describe "${SERVICE_NAME}" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="github-actions" \
  --format="value(name)"
```
