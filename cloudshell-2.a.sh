# #!/bin/bash

# Task - 2 : Configure a remote backend 

cat > modules/storage/storage.tf <<EOF
resource "google_storage_bucket" "storage-bucket" {
  name          = "tf-bucket-709415"
  location      = "US"
  force_destroy = true
  uniform_bucket_level_access = true
}
EOF

cat > main.tf <<EOF
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.55.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region = var.region

  zone = var.zone
}

module "instances" {

  source = "./modules/instances"

}
module "storage" {
  source = "./modules/storage"
}
EOF

terraform init
terraform apply -auto-approve




