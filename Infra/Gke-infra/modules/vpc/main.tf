resource "google_compute_network" "vpc" {
  name          =  "${format("%s","${var.company}-${var.env}-vpc")}"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
}
resource "google_compute_firewall" "allow-internal" {
  name    = "${var.company}-fw-allow-internal"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  source_ranges = [
    "${var.private_subnet_cidr}",
    "${var.public_subnet_cidr}"
  ]
}

resource "google_compute_firewall" "allow-http" {
  name    = "${var.company}-fw-allow-http"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags = ["http"] 

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-k8s-api" {
  name    = "${var.company}-fw-allow-k8s-api"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  target_tags = ["k8s-api"]

  source_ranges = ["0.0.0.0/0"]  # Adjust this if you want to restrict access to specific IP ranges
}

resource "google_compute_subnetwork" "public_subnet" {
  name          =  "${var.public_name}"
  ip_cidr_range = "${var.public_subnet_cidr}"
  network       = "${google_compute_network.vpc.name}"
  region        = "${var.region}"
}
resource "google_compute_subnetwork" "private_subnet" {
  name          =  "${var.private_name}"
  ip_cidr_range = "${var.private_subnet_cidr}"
  network      = "${google_compute_network.vpc.name}"
  region        = "${var.region}"
  purpose       = "PRIVATE"
}

resource "google_compute_router" "nat_router" {
  name    = "${var.company}-${var.env}-router"
  network = google_compute_network.vpc.name
  region  = var.region
}

resource "google_compute_router_nat" "nat_gateway" {
  name   = "${var.company}-${var.env}-nat"
  router = google_compute_router.nat_router.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat  = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  min_ports_per_vm = 64
}

resource "google_compute_address" "nat_ip" {
  name   = "${var.company}-${var.env}-nat-ip"
  region = var.region
}