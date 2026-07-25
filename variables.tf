variable "proxmox_user" {
  type = string
}

variable "proxmox_password" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "ssh_user" {
  type = string
}

variable "kubernetes_version" {
  type = string
  default = "v1.32.3"
}

variable "minor" {
  type = string
  default = "1"
}

# vm vars

variable "cores" {
  description = "The name of the VM to be created."
  type        = number
  default    = 2
}

variable "memory" {
  description = "The memory allocation for the VM."
  type        = number
  default    = 4096
}

variable "disk_size" {
  description = "The disk size for the VM."
  type        = number
  default    = 20
}
