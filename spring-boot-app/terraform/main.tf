# Reference the secret stored in Harness Secrets Manager
data "harness_secret" "google_credentials" {
  secret_id = "hindusree454"  # The secret ID where your Google Cloud service account key is stored in Harness
}

# Google Cloud provider configuration using credentials stored in Harness
provider "google" {
  project     = "devops-e2e-workflow"  # Replace with your Google Cloud project ID
  region      = "europe-west1"          # Replace with your preferred region
  zone        = "europe-west1-b"       # Replace with your desired zone
  credentials = data.harness_secret.google_credentials.value  # Using secret value from Harness
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
