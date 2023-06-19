module "gce-container" {
  source  = "terraform-google-modules/container-vm/google"
  version = "~> 2.0"

  container = {
    image = "postgres:latest"
    env = [
      {
        name  = "POSTGRES_USER",
        value = var.sql_username,
      },
      {
        name  = "POSTGRES_PASSWORD",
        value = var.sql_password,
      },
      {
        name  = "POSTGRES_DB",
        value = var.sql_database
      },
    ]
    volumeMounts = [
      {
        mountPath = "/var/lib/postgresql/data"
        name      = "data"
        readOnly  = false
      }
    ]
  }

  volumes = [
    {
      name = "data"
      emptyDir = {
        medium = "Memory"
      }
    }
  ]

  restart_policy = "Always"
}
