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

### Makefile targets
```bash
make plan    # terraform plan -out terraform.plan -var-file=terraform.tfvars
make apply   # terraform apply terraform.plan
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
- `.terraform.lock.hcl` pins `hashicorp/google` to `4.69.1`
- `terraform.tfvars` is gitignored — never commit secrets
- Any `.plan` files and `.terraform/` directory are gitignored

---

## Code Style Guidelines

### File organization
- Use numbered prefix pattern for `.tf` files: `01-provider.tf`, `02-container.tf`, etc.
- Each `.tf` file should be single-purpose, named after the resource/concern it configures
- Keep files small and focused (all current files are 5–50 lines)

### Naming conventions
- **Variables**: `snake_case` (e.g., `project_id`, `sql_username`, `machine_type`, `vm_name`)
- **Resources**: hyphenated name argument (e.g., `"postgres-vm"`, `"http-access"`)
- **Data sources**: short descriptive name (e.g., `"postgres"`, `"existing-ip"`)
- **Modules**: hyphenated (e.g., `"gce-container"`)

### Variable declarations
```hcl
variable "name" {
  type        = string
  description = "Human-readable description"
  default     = "value"  # omit if required
}
```
- Always include `type` and `description`
- Include `default` only for optional variables with a sensible default
- Separate variable blocks with a blank line

### Resource definitions
```hcl
resource "google_compute_xxx" "resource-name" {
  name         = var.some_name
  project      = var.project_id
  # ...

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

### Module usage
```hcl
module "module-name" {
  source  = "terraform-google-modules/container-vm/google"
  version = "~> 2.0"

  arg_name = value
}
```
- Always pin `source` and `version`
- Module arguments grouped logically

### Comments
- Use `#` for single-line comments
- Use comments sparingly — prefer self-documenting code

### Terraform formatting
- Run `terraform fmt` before committing
- Indent with 2 spaces (Terraform default)

### Secrets & credentials
- Never commit `service_account.json`, `terraform.tfvars`, or any `.json` key files
- Pass sensitive values via `terraform.tfvars` (gitignored) or `-var` flags
- Variables for secrets: `sensitive = true` is preferred

### Error handling (Terraform patterns)
- Use `precondition` / `postcondition` blocks for input validation (Terraform 1.2+)
- Use `lifecycle { precondition { ... } }` for custom validation
- Use `validation` block in variable declarations for input constraints:
```hcl
variable "machine_type" {
  type        = string
  description = "GCE machine type"
  default     = "e2-micro"

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+-[0-9]+$", var.machine_type))
    error_message = "Must be a valid GCE machine type."
  }
}
```
- Never hardcode secrets or project IDs

### Conventions to maintain
- Each `.tf` file: small, focused, numbered `XX-short-name.tf`
- `variables.tf` collects all variable declarations
- Resources reference variables via `var.xxx` and data sources via `data.xxx.name.attribute`
- Modules reference outputs via `module.name.output_name`

### Git workflow
- Single `init` commit on `main`
- `.gitignore` covers: `.terraform/`, `*.tfstate*`, `*.tfvars`, `*.log`, `*.plan`
