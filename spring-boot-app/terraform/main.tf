provider "google" {
  project = "devops-e2e-workflow"
  zone    = "europe-west1-b"
}

resource "google_compute_instance" "vm_instance" {
  name         = "sonarqube-vm"
  machine_type = "e2-medium"
  zone         = "europe-west1-b"

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt update && sudo apt upgrade -y
    sudo apt install docker.io -y
    sudo systemctl start docker
    sudo systemctl enable docker
    echo "vm.max_map_count=524288" >> /etc/sysctl.conf
    echo "fs.file-max=131072" >> /etc/sysctl.conf
    sysctl -p
    echo "sonarqube - nofile 131072" >> /etc/security/limits.conf
    echo "sonarqube - nproc 8192" >> /etc/security/limits.conf
    sudo docker run -d --name sonarqube -p 0.0.0.0:9000:9000 sonarqube:lts
  EOT
}

resource "google_compute_firewall" "allow_sonarqube" {
  name    = "allow-sonarqube-9000"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9000"]
  }

  source_ranges = ["0.0.0.0/0"]
}

output "sonarqube_url" {
  value       = "http://${google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip}:9000"
  description = "URL to access SonarQube after deployment"
}
