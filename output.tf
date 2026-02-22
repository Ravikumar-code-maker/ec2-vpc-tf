output "vm_external_ip" {
  value = google_compute_address.static_ip.address
}

output "vpc_name" {
  value = google_compute_network.vpc.name
}

output "subnet_name" {
  value = google_compute_subnetwork.subnet.name
}

output "api_gateway_url" {
  value = google_api_gateway_gateway.gateway.default_hostname
}
