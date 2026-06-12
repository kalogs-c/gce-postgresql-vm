resource "google_compute_firewall" "postgres-access" {
  name    = "${var.vm_name}-postgres"
  project = var.project_id
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_ranges = var.allowed_source_ranges
  target_tags   = ["postgres-vm"]
}
