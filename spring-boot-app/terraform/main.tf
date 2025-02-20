provider "google" {
  project     = "devops-e2e-workflow"   # Google Cloud project ID
  region      = "europe-west1"           # Google Cloud region
  zone        = "europe-west1-b"        # Specific zone within the region
  credentials = data.harness_secret.devops_e2e_key.value # Reference secret stored in Harness
}

resource "google_container_cluster" "gke_cluster" {
  name     = "my-gke-cluster1"
  location = "europe-west1" # Specify region for GKE cluster

  remove_default_node_pool = true
  initial_node_count       = 1

  lifecycle {
    prevent_destroy = false
  }
}

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

# Reference the secret in Harness
data "harness_secret" "devops_e2e_key" {
  secret_id = "devops-e2e-key"  # The ID of the secret stored in Harness Secrets Manager
}
