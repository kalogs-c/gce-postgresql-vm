output "instance_name" {
  value       = google_compute_instance.postgres-vm.name
  description = "PostgreSQL VM instance name"
}

output "external_ip" {
  value       = google_compute_address.postgres.address
  description = "External IP address of the PostgreSQL VM"
}

output "database_name" {
  value       = var.sql_database
  description = "PostgreSQL database name"
}

output "connection_string" {
  value       = "postgresql://${var.sql_username}:${var.sql_password}@${google_compute_address.postgres.address}:5432/${var.sql_database}"
  description = "PostgreSQL connection URI"
  sensitive   = true
}
