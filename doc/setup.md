# CI/CD setup with Google Cloud Run and GitHub Actions

This short guide will help you get set up with GitHub Actions-powered CI/CD pipeline 

## Pre-requisites

* A Google Cloud Platform account, with a project and billing account configured.
* The [Google Cloud Container Registry API enabled](https://cloud.google.com/container-registry/docs/enable-service)
* The Google Cloud IAM Service Account API enabled
* The `gcloud` [installed and updated](https://cloud.google.com/sdk/docs/install)

## How it works

### Service account keys

Service accounts let you assign an identity to an application. This makes it easier to 
set up authentication flows with Google Cloud as well as third-party applications 
without needing to share/depend on user account (i.e. developer-controled accounts). By
segregating accounts this way, it is possible to give an application only the access to
resources that it absolutely needs - and these may be much narrow than developer-
controlled user accounts. This is good security practice.
However, for a fair while, the primary way of authenticating a third party application with your
application was to share _service account keys_ with that application. Sharing keys with
third-party applications can be a security risk. 

For example, if a third-party application was compromised, your service account keys may 
also be compromised: someone may be able to use those keys to access your Google Cloud 
resources. It also makes key governance harder: it is not always easy to track which 
keys are used by which applications, and for which purposes. This adds complexity to 
managing identities. Fortunately, there's another way...

### Workload identity federation

Workload Identity Federation is that method: it utilises 'keyless authentication'. It 
enables applications to replace potentially long-lived keys with short-lived access 
tokens. This method is based on configuring Google's identity management tools to trust
valid tokens from third-party providers. When these providers are configured, tokens
from that provider can be exchanged for a Google Cloud token that can then be used to
'impersonate' an identity held on Google Cloud (e.g. a specific service account).

This approach is beneficial because it reduces the governance challenges associated with
managing keys directly, and it removes the risk of having your keys leaked by a 
third-party application. While you can still use Service Account Keys to authenticate
your applications, it is no longer the recommended approach. The rest of this 

### GitHub Actions

## Generating your Google credentials

### 1 - Create a Service Account

* IAM & Admin
* Service Accounts
* Create Service Account
* IAM Role -> Google Cloud Run Developer, Storage Admin, Cloud Run Service Agent

### 2 - Set required local environment variables

* `REPO_NAME`
* `REPO_OWNER`
* `PROJECT_ID`
* `SERVICE_ACCOUNT`
* `SERVICE_NAME`
* `POOL_NAME` (`github-actions`)

### 3 - Create a new Workload Identity Provider

#### 3.1 Create a new Workload Identity Pool

The first thing you'll need to do is create a new Workload Identity Pool to associate
your Workload Identity Provider with. You only need to create an Identity Pool once so
if you end up configuring multiple GitHub Actions you can skip this step in future.

To generate the pool, simply run:

```bash
gcloud iam workload-identity-pools create ${POOL_NAME} \
  --location=global \
  --project=${PROJECT_ID} \
  --display-name='Github Actions'
```

Now set `WORKLOAD_IDENDITY_POOL_ID` by running:

```bash
export WORKLOAD_IDENTITY_POOL_ID=$(gcloud iam workload-identity-pools describe "github-actions" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --format="value(name)")
```

### 3.2 Create a new Workload Identity Provider

You now need to associate a Workload Identity Provider with your newly created pool
(and the service you're going to deploy). To do this, you can run:

```bash
gcloud iam workload-identity-pools providers create-oidc "${SERVICE_NAME}" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="github-actions" \
  --display-name="GitHub Actions provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.aud=assertion.aud" \
  --issuer-uri="https://token.actions.githubusercontent.com"
```

You can then get access to your newly created Workload Identity Provider's name by
running the following command:

```bash
gcloud iam workload-identity-pools providers describe "${SERVICE_NAME}" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="github-actions" \
  --format="value(name)"
  ```

## 4 - Update IAM Roles

Finally for this section, you'll need to configure your Service Account's IAM Roles to
include the Workload Identity Pool you created earlier. This allows identities in the 
Workload Identity Pool to impersonate your chosen Service Account. You can do this 
simply enough using this command:

```bash
gcloud iam service-accounts add-iam-policy-binding "${SERVICE_ACCOUNT}" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${REPO_ORG}/${REPO_NAME}"
```

# Configure GitHub Action

## 1 - Set GitHub Action Secrets

* `PROJECT_ID`
* `SERVICE_ACCOUNT`
* `WORKLOAD_IDENTITY_PROVIDER`
* `REGION` (optional) - can be set directly in your workflow

Note: if you plan on configuring CI/CD for both development and production environments,
you'll want to make sure you're de-conflicting your secrets. For example, consider using
`DEV_SERVICE_ACCOUNT` and `PROD_SERVICE_ACCOUNT` to explicitly indicate the credentials
to be used in each context. You will need to generate credentials for each environment
you are targeting. Additionally, if you expect to use multiple tools or platforms with
GitHub Actions, it may be worth going further and using `GCP_PROD_SERVICE_ACCOUNT` to
further de-conflict your configuration. For a simple setup as described here, you need
not worry about this, though!

## 2 - Create Workflow

{Provided example}

# Next steps
