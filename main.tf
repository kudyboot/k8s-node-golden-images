# resource "proxmox_download_file" "this" {
#   content_type = "import"
#   datastore_id = "local"
#   node_name    = local.proxmox_host_1
#   url          = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
#   overwrite    = false
# }

data "proxmox_file" "debian_iso" {
  node_name    = local.proxmox_host_1
  datastore_id = "local"
  content_type = "import"
  file_name    = "debian-13-genericcloud-amd64.qcow2"
}

resource "proxmox_virtual_environment_vm" "this" {
  name            = "k8s-tpl-${replace(var.kubernetes_version, ".", "-")}-${formatdate("YYYYMMDD", timestamp())}-r${var.minor}"
  node_name       = local.proxmox_host_1
  stop_on_destroy = true

  cpu {
    cores = var.cores
  }

  memory {
    dedicated = var.memory
  }

  initialization {
    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id

    # ip_config {
    #   ipv4 {
    #     address = "192.168.1.13/24"
    #     gateway = "192.168.1.1"
    #   }
    # }
  }

  disk {
    datastore_id = "local-lvm"
    import_from  = data.proxmox_file.debian_iso.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.disk_size
  }
  # network_device {
  #     bridge = "vmbr0"
  # }
}

resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = local.proxmox_host_1

  source_raw {
    data = templatefile("${path.module}/cloud-init.tpl", {
      "ssh_user" : var.ssh_user
      "ssh_public_key" : var.ssh_public_key
      "kubernetes_version" : var.kubernetes_version
    })
    file_name = "k8s-tpl-${replace(var.kubernetes_version, ".", "-")}-r${var.minor}.yaml"
  }
}
