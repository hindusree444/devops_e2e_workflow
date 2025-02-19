provider "google" {
  project = "devops-e2e-workflow"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}

resource "google_compute_instance" "vm_instance" {
  name         = "my_instance"
  machine_type = "e2-medium"
  zone         = "europe-west1-b"

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {} # Assigns an external IP
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt update && sudo apt upgrade -y
  EOT
}

# Output the external IP of the created instance
output "instance_ip" {
  value       = google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip
  description = "Public IP of the VM"
}
