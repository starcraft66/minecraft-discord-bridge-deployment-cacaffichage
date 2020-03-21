output "bridge_droplet_ipv4_addr" {
  value = digitalocean_droplet.bridge-droplet.ipv4_address
}

output "bridge_droplet_ipv6_addr" {
  value = digitalocean_droplet.bridge-droplet.ipv6_address
}
