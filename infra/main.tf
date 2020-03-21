provider "cloudflare" {

}

provider "digitalocean" {
    
}

resource "digitalocean_project" "production" {
  name        = "Cacaffichage minecraft-discord-bridge"
  description = "A minecraft-discord-bridge deployment for the cacaffichage minecraft server"
  purpose     = "Service or API"
  environment = "Production"
  resources   = [
    digitalocean_droplet.bridge-droplet.urn,
    digitalocean_volume.bridge-storage.urn,
  ]
}

data "digitalocean_ssh_key" "yubikey1" {
  name = "cardno:000606923500"
}

data "digitalocean_ssh_key" "yubikey2" {
  name = "cardno:000609029473"
}

data "digitalocean_ssh_key" "yubikey3" {
  name = "cardno:000609769932"
}

data "digitalocean_ssh_key" "file" {
  name = "rsa-key-20140401"
}

resource "digitalocean_volume" "bridge-storage" {
  region                  = digitalocean_droplet.bridge-droplet.region
  name                    = "cacaffichage-storage"
  size                    = 5
  initial_filesystem_type = "ext4"
  description             = "Storage for bridge files (database, config, logs)"
}

resource "digitalocean_droplet" "bridge-droplet" {
  image     = "ubuntu-19-10-x64"
  name      = "cacaffichage-bridge"
  region    = "tor1"
  size      = "s-1vcpu-1gb"
  ipv6      = true
  user_data = file("./infra/cloud-init-discord-bridge.yml")
  ssh_keys  = [
    data.digitalocean_ssh_key.yubikey1.id,
    data.digitalocean_ssh_key.yubikey2.id,
    data.digitalocean_ssh_key.yubikey3.id,
    data.digitalocean_ssh_key.file.id,
  ]
}

resource "digitalocean_volume_attachment" "bridge-storage-attachment" {
  droplet_id = digitalocean_droplet.bridge-droplet.id
  volume_id  = digitalocean_volume.bridge-storage.id
}

resource "digitalocean_firewall" "bridge-firewall" {
  name = "ssh-and-auth-inbound"

  droplet_ids = [digitalocean_droplet.bridge-droplet.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "9822"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

data "cloudflare_zones" "tdude_co" {
  filter {
    name   = "tdude.co"
    status = "active"
    paused = false
  }
  # id = "c802e5f57a27af705373d5d3570649f0"
}

resource "cloudflare_record" "cacaffichage-bridge_tdude_co_A" {
  zone_id = data.cloudflare_zones.tdude_co.zones[0].id
  name    = "cacaffichage-bridge"
  value   = digitalocean_droplet.bridge-droplet.ipv4_address
  type    = "A"
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "cacaffichage-bridge_tdude_co_AAAA" {
  zone_id = data.cloudflare_zones.tdude_co.zones[0].id
  name    = "cacaffichage-bridge"
  value   = digitalocean_droplet.bridge-droplet.ipv6_address
  type    = "AAAA"
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "STAR_verify_cacaffichage-bridge_tdude_co_CNAME" {
  zone_id = data.cloudflare_zones.tdude_co.zones[0].id
  name    = "*.cacaffichage-bridge"
  value   = cloudflare_record.cacaffichage-bridge_tdude_co_A.hostname
  type    = "CNAME"
  ttl     = 1
  proxied = false
}
