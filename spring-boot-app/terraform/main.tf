# Compute instance (VM) resource
resource "google_compute_instance" "my_instance" {
  name         = "small-instance"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"

    access_config {
      # Allocate a public IP address
    }
  }
}

output "instance_ip" {
  value = google_compute_instance.my_instance.network_interface[0].access_config[0].nat_ip
}
