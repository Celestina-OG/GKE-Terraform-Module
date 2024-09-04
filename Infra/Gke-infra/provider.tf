provider "google" {
  credentials = file(var.credentials_path)
  project     = var.project_id
  region      = var.region
}
