# AGENTS.md — gce-postgresql-vm

## Build & Lint & Test Commands

This is a Terraform/HCL project. There is no testing framework, no CI/CD, and no linter configuration.

### Terraform commands
```bash
# Initialize providers and modules
terraform init

# Format all .tf files
terraform fmt

# Validate configuration
terraform validate

# Show current state
terraform show

# Plan deployment
terraform plan -out terraform.plan -var-file=terraform.tfvars

# Apply the plan
terraform apply terraform.plan

# Destroy all resources
terraform destroy
```

### Creating a plan with specific variable overrides
```bash
terraform plan -out terraform.plan -var-file=terraform.tfvars -var="project_id=my-project"
```

### Running a single test
There are no tests in this repository. If adding tests, use a standard Terraform testing approach:
- `terraform test` (native, HCL-based tests in `tests/` directory with `.tftest.hcl` files)
- Or [Terratest](https://terratest.gruntwork.io/) (Go-based, in a separate `test/` directory)

### Notes
- Provider `hashicorp/google` pinned to `~> 6.0` via `required_providers` in `01-provider.tf`
- Terraform >= 1.3 required (needed for `validation` blocks in variable declarations)
- `terraform.tfvars` is gitignored — never commit secrets
- Any `.plan` files and `.terraform/` directory are gitignored
- `*.tfstate` and `*.tfstate.*` are gitignored

---

## Code Style Guidelines

### File organization
- Use numbered prefix pattern for `.tf` files: `01-provider.tf`, `02-vpc_ip.tf`, etc.
- Each `.tf` file should be single-purpose, named after the resource/concern it configures
- Keep files small and focused (all current files are 5–55 lines)
- Current file map:
  - `01-provider.tf` — Terraform/provider settings (`required_version`, `required_providers`)
  - `02-vpc_ip.tf` — Static IP address resource
  - `03-vm.tf` — COS image data source, persistent disk resource, VM instance
  - `04-firewall.tf` — Firewall rule for port 5432
  - `05-outputs.tf` — Terraform outputs
  - `variables.tf` — All variable declarations

### Startup script template
- Container deployment uses a `startup.sh.tftpl` file rendered via `templatefile()`
- Template file lives alongside `.tf` files at the project root
- `startup.sh.tftpl` handles: disk formatting/mounting, Docker run with PostgreSQL, extra database creation

### Naming conventions
- **Variables**: `snake_case` (e.g., `project_id`, `sql_username`, `machine_type`, `vm_name`, `allowed_source_ranges`)
- **Resources**: hyphenated name argument (e.g., `"postgres-vm"`, `"postgres-access"`)
- **Data sources**: short descriptive name (e.g., `"cos"`)
- **Files**: hyphenated snake_case (e.g., `02-vpc_ip.tf`, `startup.sh.tftpl`)

### Variable declarations
```hcl
variable "name" {
  type        = string
  description = "Human-readable description"
  default     = "value"  # omit if required
  sensitive   = true     # for secrets like passwords
}
```
- Always include `type` and `description`
- Include `default` only for optional variables with a sensible default
- Mark secrets with `sensitive = true`
- Separate variable blocks with a blank line
- Use `validation` blocks for input constraints (see below)

### Validation blocks
```hcl
variable "postgres_version" {
  type        = string
  description = "PostgreSQL major version tag"
  default     = "16"

  validation {
    condition     = can(regex("^[0-9]+$", var.postgres_version))
    error_message = "Must be a numeric PostgreSQL version (e.g. 16)."
  }
}

variable "disk_size" {
  type        = number
  description = "Disk size in GB"
  default     = 20

  validation {
    condition     = var.disk_size >= 10 && var.disk_size <= 100
    error_message = "Disk size must be between 10 and 100 GB."
  }
}
```

### Resource definitions
```hcl
resource "google_compute_xxx" "resource-name" {
  name         = var.some_name
  project      = var.project_id

  block_name {
    nested_block {
      key = value
    }
  }

  metadata = {
    key = value
  }

  labels = {
    key = value
  }

  tags = ["tag1", "tag2"]
}
```
- Opening brace `{` on the same line as the resource/block header
- Arguments aligned by padding with spaces after `=` where natural
- Nested blocks use `{ }` on new lines
- Array/list args: one element per line

### templatefile usage
```hcl
metadata_startup_script = templatefile("${path.module}/startup.sh.tftpl", {
  template_var  = var.some_var
  another_var   = var.another_var
})
```
- Use `${path.module}` prefix for the template file path
- All template variables passed explicitly in the map argument
- Template escape rules:
  - `${...}` — interpolated by Terraform
  - `$${...}` — literal `${...}` in output (bash variable reference)
  - `%{ for ... }` / `%{ endfor }` — Terraform template directives
  - `~` — whitespace chomping in directives
  - `$(...)` (bash subcommand) — passes through as-is (Terraform only interprets `${}`)

### Data sources
```hcl
data "google_compute_image" "cos" {
  family  = "cos-stable"
  project = "cos-cloud"
}
```
- Reference via `data.TYPE.NAME.ATTRIBUTE` (e.g., `data.google_compute_image.cos.self_link`)

### Comments
- Use `#` for single-line comments
- Use comments sparingly — prefer self-documenting code
- No block comments (`/* */`)

### Terraform formatting
- Run `terraform fmt` before committing
- Indent with 2 spaces (Terraform default)

### Secrets & credentials
- Never commit `service_account.json`, `terraform.tfvars`, or any `.json` key files
- Pass sensitive values via `terraform.tfvars` (gitignored) or `-var` flags
- Use `sensitive = true` on variables that hold secrets
- Never hardcode project IDs or passwords in `.tf` files

### Error handling
- Use `validation` block in variable declarations for input constraints (Terraform 1.2+)
- Use `lifecycle { precondition { ... } }` for cross-variable validation
- For resources: `allow_stopping_for_update = true` to avoid destroy/recreate cycles
- Startups scripts use `set -e -x` for fail-fast and debug logging
- Docker cleanup uses `|| true` to ignore errors when container doesn't exist yet

### Conventions to maintain
- Each `.tf` file: small, focused, numbered `XX-short-name.tf`
- `variables.tf` collects all variable declarations
- Resources reference variables via `var.xxx`, resources via `RESOURCE_TYPE.NAME.ATTRIBUTE`, data sources via `data.TYPE.NAME.ATTRIBUTE`
- No module usage (the old `container-vm` module was removed — containers are deployed via startup script)

### Git workflow
- `.gitignore` covers: `.terraform/`, `*.tfstate*`, `*.tfvars`, `*.log`, `*.plan`
- Do not commit `terraform.tfvars`, `.terraform/`, or `.plan` files
