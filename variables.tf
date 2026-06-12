variable "project_id" {
  type        = string
  description = "Project ID"
}

variable "region" {
  type        = string
  description = "Region"
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "Zone"
  default     = "us-central1-a"
}

variable "sql_username" {
  type        = string
  description = "Postgres Username"
}
variable "sql_password" {
  type        = string
  description = "Postgres Password"
}
variable "sql_database" {
  type        = string
  description = "Postgres Database Name"
}

variable "ip_name" {
  type        = string
  description = "VPC External IP Name"
}

variable "vm_name" {
  type        = string
  description = "VM Name"
}
variable "machine_type" {
  type        = string
  description = "VM Name"
  default     = "e2-micro"
}

variable "network" {
  type        = string
  description = "Network"
  default     = "default"
}
