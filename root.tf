module "infra" {
  source = "./infra"
}

module "bridge" {
  source = "./bridge"
  bridge_droplet_ipv4_addr = "${module.infra.bridge_droplet_ipv4_addr}"
  bridge_droplet_ipv6_addr = "${module.infra.bridge_droplet_ipv6_addr}"
}