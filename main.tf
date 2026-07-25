resource "proxmox_download_file" "this" {
  content_type = "import"
  datastore_id = "local"
  node_name    = local.proxmox_host_1
  url          = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
  overwrite    = false
}

resource "proxmox_virtual_environment_vm" "this" {
  name      = "k8s-node-template_${var.kubernetes_version}_${formatdate("YYYY-MM_DD", timestamp())}.${var.minor}"
  node_name = local.proxmox_host_1
  template = true
  stop_on_destroy = true

  cpu {
    cores = var.cores
  }

  memory {
    dedicated = var.memory
  }

  initialization {
    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
  }

  disk {
    datastore_id = "local-lvm"
    import_from  = proxmox_download_file.this.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.disk_size
  }
}

resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = local.proxmox_host_1

  source_raw {
    data = templatefile("${path.module}/cloud-init.tpl", {
      "ssh_user": var.ssh_user
      "ssh_public_key": var.ssh_public_key
      "kubernetes_version": var.kubernetes_version
    })
    file_name = "k8s-cloud-init_${var.kubernetes_version}.yaml"
  }
}
