terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.111"
    }
  }
}

provider "proxmox" {
  endpoint = "https://192.168.1.10:8006"

  username = var.proxmox_user
  password = var.proxmox_password
  # because self-signed TLS certificate is in use
  insecure = true
}