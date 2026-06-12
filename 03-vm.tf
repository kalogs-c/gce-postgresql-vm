data "google_compute_image" "cos" {
  family  = "cos-stable"
  project = "cos-cloud"
}

resource "google_compute_disk" "pg_data" {
  name    = "${var.vm_name}-data"
  project = var.project_id
  type    = "pd-standard"
  zone    = var.zone
  size    = var.disk_size
}

resource "google_compute_instance" "postgres-vm" {
  name                      = var.vm_name
  machine_type              = var.machine_type
  zone                      = var.zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = data.google_compute_image.cos.self_link
      size  = 10
      type  = "pd-standard"
    }
  }

  attached_disk {
    source      = google_compute_disk.pg_data.id
    device_name = "pg-data"
  }

  metadata_startup_script = templatefile("${path.module}/startup.sh.tftpl", {
    sql_username     = var.sql_username
    sql_password     = var.sql_password
    sql_database     = var.sql_database
    postgres_image   = "postgres:${var.postgres_version}"
    extra_databases  = var.extra_databases
  })

  labels = {
    container-vm = "postgres-${var.postgres_version}"
  }

  tags = ["postgres-vm"]

  network_interface {
    network = var.network
    access_config {
      nat_ip = google_compute_address.postgres.address
    }
  }
}
