variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "GCP region (use us-central1, us-west1, or us-east1 for free tier)"
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "GCP zone"
  default     = "us-central1-a"
}

variable "sql_username" {
  type        = string
  description = "PostgreSQL username"
}

variable "sql_password" {
  type        = string
  description = "PostgreSQL password"
  sensitive   = true
}

variable "sql_database" {
  type        = string
  description = "PostgreSQL database name"
}

variable "ip_name" {
  type        = string
  description = "Name of the existing VPC external static IP address"
}

variable "vm_name" {
  type        = string
  description = "VM instance name"
}

variable "machine_type" {
  type        = string
  description = "GCE machine type (e2-micro is free tier eligible)"
  default     = "e2-micro"
}

variable "network" {
  type        = string
  description = "VPC network name"
  default     = "default"
}

variable "postgres_version" {
  type        = string
  description = "PostgreSQL major version tag (e.g. 16, 17)"
  default     = "16"

  validation {
    condition     = can(regex("^[0-9]+$", var.postgres_version))
    error_message = "Must be a numeric PostgreSQL version (e.g. 16)."
  }
}

variable "disk_size" {
  type        = number
  description = "Persistent disk size for PostgreSQL data in GB (free tier includes 30 GB total with boot disk)"
  default     = 20

  validation {
    condition     = var.disk_size >= 10 && var.disk_size <= 100
    error_message = "Disk size must be between 10 and 100 GB."
  }
}

variable "allowed_source_ranges" {
  type        = list(string)
  description = "CIDR ranges allowed to connect to PostgreSQL (default: 0.0.0.0/0 = anywhere)"
  default     = ["0.0.0.0/0"]
}

variable "extra_databases" {
  type        = list(string)
  description = "Additional PostgreSQL databases to create besides sql_database"
  default     = []
}
