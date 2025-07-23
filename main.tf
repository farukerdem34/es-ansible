terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_network" "private_net" {
  name     = "elastic-network"
  ip_range = "192.168.122.0/24"
}

resource "hcloud_network_subnet" "subnet" {
  network_id   = hcloud_network.private_net.id
  type         = "server"
  network_zone = "eu-central"
  ip_range     = "192.168.122.0/24"
}

locals {
  servers = [
    { name = "es-node-1", ip = "192.168.122.10" },
    { name = "es-node-2", ip = "192.168.122.11" },
    { name = "es-node-3", ip = "192.168.122.12" },
    { name = "kibana", ip = "192.168.122.13" },
  ]
}

resource "hcloud_server" "nodes" {
  for_each = { for s in local.servers : s.name => s }

  name        = each.value.name
  image       = "ubuntu-24.04"
  server_type = "cpx11"
  ssh_keys    = [var.ssh_key]
  public_net {
    ipv6_enabled = false
    ipv4_enabled = true

  }
  network {
    network_id = hcloud_network.private_net.id
    ip         = each.value.ip
  }
}

