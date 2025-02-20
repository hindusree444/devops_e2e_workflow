terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.21.0"
    }
    harness = {
      source = "harness/harness"
    }
  }
}

# Declare the GOOGLE_CREDENTIALS_JSON variable
variable "GOOGLE_CREDENTIALS_JSON" {
  description = "Google Cloud JSON credentials file content as a string"
  type        = string
  sensitive   = true
}

# Google Cloud provider configuration using environment variable for credentials
provider "google" {
  project     = "devops-e2e-workflow"  # Replace with your Google Cloud project ID
  region      = "europe-west1"          # Your preferred region
  zone        = "europe-west1-b"       # Your desired zone
  credentials = jsondecode(var.GOOGLE_CREDENTIALS_JSON)  # Use the environment variable for credentials
}

# GKE Cluster resource configuration
resource "google_container_cluster" "gke_cluster" {
  name     = "my-gke-cluster1"
  location = "europe-west1"  # Region for the GKE cluster
  
  remove_default_node_pool = true
  initial_node_count       = 1

  lifecycle {
    prevent_destroy = false
  }
}

# Node pool resource configuration for GKE
resource "google_container_node_pool" "primary_nodes" {
  name       = "node-pool"
  cluster    = google_container_cluster.gke_cluster.name
  node_count = 1

  node_config {
    service_account = "devops-e2e-sa@devops-e2e-workflow.iam.gserviceaccount.com"
    machine_type    = "e2-medium"
    disk_size_gb    = 10
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  lifecycle {
    prevent_destroy = false
  }
}

# Output the Cluster Name
output "gke_cluster_name" {
  value = google_container_cluster.gke_cluster.name
}
