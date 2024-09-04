
# GKE Terraform Time API Deployment Guide

## Overview

This guide will help you deploy a simple RESTful Time API on Google Kubernetes Engine (GKE). The Time API is built with Golang and returns the current time in JSON format. We'll use Docker for containerization, Terraform for infrastructure management, and GitHub Actions for continuous integration and deployment (CI/CD).

## Prerequisites

Before you start, ensure you have the following installed on your local machine:

1. **Docker**: [Installation Guide](https://docs.docker.com/get-docker/)
2. **Terraform**: [Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
3. **Google Cloud SDK**: [Installation Guide](https://cloud.google.com/sdk/docs/install)
4. **Git**: [Installation Guide](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

## Configuration

### 1. Clone the Repository

Clone the GitHub repository to your local machine:

```bash
git clone https://github.com/Celestina-OG/Terraform-GKE.git
cd Terraform-GKE
```

### 2. Set Up Google Cloud Credentials

1. **Create a Google Cloud Project**: Follow [this guide](https://cloud.google.com/resource-manager/docs/creating-managing-projects) if you haven't already created a project.

2. **Create a Service Account**: This account allows Terraform to interact with Google Cloud.

   - Go to the [Google Cloud Console](https://console.cloud.google.com/).
   - Navigate to **IAM & Admin > Service Accounts**.
   - Create a new service account with appropriate permissions and download the JSON key file.

3. **Configure Credentials**:

   - Export the path to your service account key file:

     ```bash
     export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/service-account-key.json"
     ```

4. - create two bucket on GCS that will be used for the backend

      ```bash
      terraform {
        backend "gcs" {
          bucket  = var.gcs_bucket_name
          prefix  = var.gcs_prefix        
          region  = var.region           
        }
      }
      ```
      
    - Change the name of the bucket, has to be unique
      ```bash
          env:
            GCS_BUCKET_NAME: "k8s-bucket-gke" 
            GCS_PREFIX: "terraform/state" 
      ```
     
### 3. Configure Terraform

1. Go to the `Infra` directory:

   ```bash
   cd Infra
   ```

2. Create a file named `terraform.tfvars` and configure it with your Google Cloud project ID and region:

   ```hcl
   project_id = "your-gcp-project-id"
   region     = "us-east4"  # Or your preferred region
   region="us-east4"
   clusterName="gke-cluster"
   diskSize=50
   minNode=1
   maxNode=2
   machineType="e2-medium"
   env             = "dev"
   company         = "shortlet"
   private_subnet_cidr = "10.0.1.0/24"
   public_subnet_cidr  = "10.0.2.0/24"
   private_name = "private"
   public_name  = "public"
   network_name = ""
   credentials_path = "/tmp/gcp_key.json" # this assumes this /path/to/your/service-account-key
   ```

### 4. Build and Push Docker Image

Build the Docker image for the Time API and push it to Google Container Registry (GCR):

```bash
docker build -t gcr.io/$(gcloud config get-value project)/time-api:latest .
docker push gcr.io/$(gcloud config get-value project)/time-api:latest
```

### 5. Deploy Infrastructure and Application

#### Initialize and Apply Terraform Configuration

1. **Initialize Terraform**: Prepare Terraform to manage your resources.

   ```bash
   terraform init
   ```

2. **Apply Configuration**: Create all the resources defined in your Terraform configuration.

   ```bash
   terraform apply -auto-approve
   ```

## GitHub Actions Workflow

This GitHub Actions will automate the deployment process above. Ensure you have the following secrets set in your GitHub repository:

- **GCP_SA_KEY**: JSON key for your Google Cloud service account.
- **GCP_PROJECT**: Your Google Cloud project ID.
- **KUBECONFIG_DATA**: Base64 encoded kubeconfig file for accessing your GKE cluster. This will be gotten after deploying the gke. 
- [Download konfig](https://github.com/corneliusweig/konfig)
```bash
kubectl konfig export <the name of your cluster> > gke.config
```

### Workflow Files

There are two GitHub Actions workflows defined:

1. **Infrastructure Workflow**: Sets up the GKE cluster and VPC infrastructure.

   ```yaml
   name: infrastructure

   on:
     push:
       branches:
         - infra

   jobs:
     infra:
       runs-on: ubuntu-latest
       steps:
         - name: Checkout code
           uses: actions/checkout@v4

         - name: Authenticate with GCP
           uses: google-github-actions/auth@v2
           with:
             credentials_json: ${{ secrets.GCP_SA_KEY }}

         - name: Set up Google Cloud SDK
           uses: google-github-actions/setup-gcloud@v2
           with:
             version: 'latest'

         - name: Create GCP credentials file
           run: echo '${{ secrets.GCP_SA_KEY }}' > /tmp/gcp_key.json

         - name: Terraform Init
           run: terraform init 
           working-directory: ./Infra/Gke-infra

         - name: Terraform Apply
           working-directory: ./Infra/Gke-infra
           run: terraform apply -auto-approve -var="project_id=${{ secrets.GCP_PROJECT }}" -var="credentials_path=/tmp/gcp_key.json"
   ```


2. **Deployment Workflow**: Automates the Docker build, push, and deployment process.

   ```yaml
   name: deploy to gke

   on:
     push:
       branches:
         - main

   jobs:
     deploy:
       runs-on: ubuntu-latest
       steps:
         - name: Checkout code
           uses: actions/checkout@v4

         - name: Authenticate with GCP
           uses: google-github-actions/auth@v2
           with:
             credentials_json: ${{ secrets.GCP_SA_KEY }}

         - name: Set up Google Cloud SDK
           uses: google-github-actions/setup-gcloud@v2
           with:
             version: 'latest'

         - name: Configure Docker to use gcloud
           run: gcloud auth configure-docker

         - name: Set up Docker Buildx
           uses: docker/setup-buildx-action@v2

         - name: Build Docker image
           run: docker build -t gcr.io/${{ secrets.GCP_PROJECT }}/time-api:latest .

         - name: Push Docker image to GCR
           run: docker push gcr.io/${{ secrets.GCP_PROJECT }}/time-api:latest

         - name: Set up kubectl
           run: |
             gcloud components install gke-gcloud-auth-plugin
             mkdir -p $HOME/.kube/ && touch $HOME/.kube/config
             echo "${{ secrets.KUBECONFIG_DATA }}" | base64 --decode > $HOME/.kube/config
             chmod 600 $HOME/.kube/config

         - name: Terraform Init
           run: terraform init 
           working-directory: ./Infra/kubernetes

         - name: Terraform Apply
           working-directory: ./Infra/kubernetes
           env:
             TF_VAR_project_id: ${{ secrets.GCP_PROJECT }}
           run: terraform apply -auto-approve 
   ```

## Testing the API

Once the deployment is complete, your API will be accessible at the external IP address assigned to the LoadBalancer service. Use the following command to test the API:

```bash
curl http://<your-loadbalancer-ip>/time
```

## Troubleshooting

- **No External IP Address**: Ensure the LoadBalancer service is correctly set up and the Ingress is properly configured.
- **Deployment Errors**: Check the logs for errors in Google Cloud Console or use `kubectl logs` for Kubernetes-specific logs.


## Contact

- **GitHub**: [https://github.com/Celestina-OG](https://github.com/Celestina-OG)
