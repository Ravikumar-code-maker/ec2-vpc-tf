# main.tf

# -------------------------
# VPC Network
# -------------------------
resource "google_compute_network" "vpc" {
  name                    = "beginner-vpc"
  auto_create_subnetworks = false
}

#Subnet

resource "google_compute_subnetwork" "subnet" {
  name          = "custom-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

# -------------------------
# Firewall Rules
# -------------------------

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports     = ["22"]
 }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-http" {
  name    = "allow-http"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports     = ["80"]
 }
  source_ranges = ["0.0.0.0/0"]
}

# -----------------------
# Static External IP
# -----------------------

resource "google_compute_address" "static_ip" {
  name = "vm-static-ip"
}
# -------------------------
# VM Instance
# -------------------------

resource "google_compute_instance" "vm" {
  name         = "beginner-vm"
  machine_type = var.machine_type
  zone         = var.zone


  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
  }
 }

  network_interface {
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.subnet.name

    access_config { #externalip
      nat_ip = google_compute_address.static_ip.address
  }
 }
  tags = ["http-server", "ssh"]
}

# Enable API Gateway (beta provider required

resource "google_api_gateway_api" "api" {
  provider = google-beta
  api_id   = "example-api"
}

resource "google_api_gateway_api_config" "api_config" {
  provider      = google-beta
  api           = google_api_gateway_api.api.api_id
  api_config_id = "example-config"


  openapi_documents {
    document {
      path     = "openapi.yaml"
      contents = filebase64("${path.module}/openapi.yaml")
  }
 }
}

resource "google_api_gateway_gateway" "gateway" {
  provider   = google-beta
  gateway_id = "example-gateway-id"
  api_config = google_api_gateway_api_config.api_config.id
  region     = var.region
}

