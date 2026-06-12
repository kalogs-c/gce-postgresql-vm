# PostgreSQL VM on Google Compute Engine

Creates an `e2-micro` VM on GCP running PostgreSQL 16 in Docker on Container-Optimized OS, with a persistent disk for data. Fits within the [GCP free tier](https://cloud.google.com/free/docs/free-cloud-features#compute) (1 VM, 30 GB total persistent disk).

## Prerequisites

- [Terraform](https://www.terraform.io/) >= 1.3
- A GCP project with billing enabled
- Authentication via `gcloud auth application-default login` or a service account JSON key

## Getting Started

```bash
# 1. Authenticate with GCP
gcloud auth application-default login

# 2. Copy and edit variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your project_id, sql_password, etc.

# 3. Initialize (downloads provider and modules)
terraform init

# 4. Preview and apply
terraform plan -out terraform.plan -var-file=terraform.tfvars
terraform apply terraform.plan

# 5. Get connection details
terraform output connection_string

# 6. Destroy when done
terraform destroy
```

## Variables

| Variable | Default | Description |
|---|---|---|
| `project_id` | — | GCP project ID |
| `region` | `us-central1` | Region (use `us-central1`, `us-west1`, or `us-east1` for free tier) |
| `zone` | `us-central1-a` | Zone |
| `sql_username` | — | PostgreSQL username |
| `sql_password` | — | PostgreSQL password (sensitive) |
| `sql_database` | — | Primary PostgreSQL database |
| `extra_databases` | `[]` | Additional databases to create (e.g. `["analytics", "logs"]`) |
| `ip_name` | — | Name for the static external IP address (created automatically) |
| `vm_name` | — | VM instance name |
| `machine_type` | `e2-micro` | GCE machine type (free tier eligible) |
| `network` | `default` | VPC network name |
| `postgres_version` | `16` | PostgreSQL major version tag |
| `disk_size` | `20` | Persistent disk size for PostgreSQL data in GB (boot is 10 GB, total 30 GB within free tier) |
| `allowed_source_ranges` | `["0.0.0.0/0"]` | CIDR ranges allowed to connect (restrict to your IP for security) |

## Outputs

| Output | Description |
|---|---|
| `instance_name` | VM instance name |
| `external_ip` | External IP address |
| `database_name` | Primary database name |
| `connection_string` | PostgreSQL connection URI (sensitive) |

## Architecture

- **VM**: `e2-micro` on Container-Optimized OS (COS)
- **Container**: PostgreSQL runs via Docker, started by a startup script
- **Disk**: 10 GB boot (pd-standard) + variable data disk (pd-standard) = up to 30 GB free tier
- **Networking**: Static external IP created by Terraform, firewall on port 5432
- **Extra databases**: Created automatically via `docker exec` after PostgreSQL is ready

## Troubleshooting

Check the startup script logs on the VM:

```bash
gcloud compute ssh <vm_name> --zone <zone> -- \
  "sudo journalctl -u google-startup-scripts.service --no-pager"
```
