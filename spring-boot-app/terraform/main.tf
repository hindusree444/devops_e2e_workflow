terraform {
  backend "s3" {
    bucket = "statestorebucket"  
    key    = "terraform/state"       
    region = "europe-west1"            
  }
}

{
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
provider "google" {
  project     = "devops-e2e-workflow"  # Replace with your Google Cloud project ID
  region      = "europe-west1"          # Your preferred region
  zone        = "europe-west1-b"       # Your desired zone
}
resource "google_container_cluster" "gke_cluster" {
  name     = "my-gke-cluster1"
  location = "europe-west1"  # Region for the GKE cluster
  
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
