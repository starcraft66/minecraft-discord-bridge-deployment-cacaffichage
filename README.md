# Minecraft Discord Bridge Deployment "cacaffichage"

This is a `minecraft-discord-bridge` deployment for my private vanilla snapshot minecraft server "cacaffichage".

Everything is deployed using Terraform which configures a digital ocean droplet, cloudflare dns records and a docker container running the bridge on the droplet.

Because the docker engine running on the droplet will only be reachable once the droplet is provisioned, this plan must be applied in two phases. First, the `infra` module must be applied with `terraform apply -target=module.infra`, then the rest can be applied with a simple `terraform apply`.

To use this terraform plan, the `CLOUDFLARE_API_TOKEN` and `DIGITALOCEAN_TOKEN` environment variables must be set accordingly.

The config file and database for the bridge must be manually seeded once.
