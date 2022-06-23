# #!/bin/bash

touch main.tf
touch variables.tf
mkdir modules
cd modules
mkdir instances
cd instances
touch instances.tf
touch outputs.tf
touch variables.tf
cd ..
mkdir storage
cd storage
touch storage.tf
touch outputs.tf
touch variables.tf
cd

PROJECT_ID=$(gcloud config get-value project)


cat > variables.tf <<EOF
variable "region" {
 default = "us-central1"
}

variable "zone" {
 default = "us-central1-a"
}

variable "project_id" {
 default = "$PROJECT_ID"
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
EOF

# Task - 1 : Import infrastructure
cat > modules/instances/instances.tf <<EOF
resource "google_compute_instance" "tf-instance-1" {
  name         = "tf-instance-1"
  machine_type = "n1-standard-1"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = "default"
  }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}

resource "google_compute_instance" "tf-instance-2" {
  name         = "tf-instance-2"
  machine_type = "n1-standard-1"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = "default"
  }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}
EOF

cp variables.tf modules/instances/variables.tf
cp variables.tf modules/storage/variables.tf

terraform init

terraform import module.instances.google_compute_instance.tf-instance-1 $(gcloud compute instances describe tf-instance-1 --zone us-central1-a --format="value(id)")
terraform import module.instances.google_compute_instance.tf-instance-2 $(gcloud compute instances describe tf-instance-2 --zone us-central1-a --format="value(id)")

terraform plan
terraform apply -auto-approve
