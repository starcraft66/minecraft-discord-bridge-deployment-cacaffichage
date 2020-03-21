provider "docker" {
  host = "ssh://root@${var.bridge_droplet_ipv6_addr}:22"
}

resource "docker_image" "bridge-image" {
  name = "starcraft66/minecraft-discord-bridge:snapshot"
}

variable "bridge_droplet_ipv4_addr" {
  type = string
}

variable "bridge_droplet_ipv6_addr" {
  type = string
}

resource "docker_container" "bridge-container" {
  name      = "minecraft-discord-bridge-cacaffichage"
  image     = docker_image.bridge-image.latest
  restart   = "unless-stopped"
  start     = true
  ports {
    internal    = 9822
    external    = 9822
  }
  volumes {
      host_path       = "/mnt/cacaffichage-storage/config.json"
      container_path  = "/app/config.json"
      read_only       = true
  }
  volumes {
      host_path       = "/mnt/cacaffichage-storage/db.sqlite"
      container_path  = "/data/db.sqlite"
  }
  volumes {
      host_path       = "/mnt/cacaffichage-storage/bridge_log.log"
      container_path  = "/app/bridge_log.log"
  }
}