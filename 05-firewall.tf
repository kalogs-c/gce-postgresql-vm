resource "google_compute_firewall" "http-access" {
  name    = "${var.vm_name}-http"
  project = var.project_id
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["container-vm-postgres"]
}
