terraform {
  backend "gcs" {
    bucket = "statestorebucket"  
    prefix = "terraform/state"
  }
}

provider "google" {
  project = "devops-e2e-workflow"  # Replace with your Google Cloud project ID
  region  = "europe-west1"          # Your preferred region
  zone    = "europe-west1-b"        # Your desired zone
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
  node_count = 2

  node_config {
    service_account = "devops-e2e-workflow@devops-e2e-workflow.iam.gserviceaccount.com"
    machine_type    = "e2-medium"
    disk_size_gb    = 20
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    
    tags = ["gke-cluster"]  # Adding network tags to nodes
  }

  lifecycle {
    prevent_destroy = false
  }
}

# Firewall rule to allow HTTP, HTTPS, and SSH traffic to GKE nodes
resource "google_compute_firewall" "allow_http_https_ssh" {
  name    = "allow-http-https-ssh"
  network = "default"  # Specify the network where the GKE cluster is created (default is "default")
  
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "22"]  # Allow traffic on HTTP (80), HTTPS (443), and SSH (22)
  }
  
  source_ranges = ["0.0.0.0/0"]  # Allow traffic from all sources (any IP)
  direction     = "INGRESS"      # Incoming traffic
  priority      = 1000           # Priority (lower numbers are higher priority)
  
  target_tags = ["gke-cluster"]  # Apply this firewall rule to nodes with the "gke-cluster" tag
}

