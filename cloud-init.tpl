#cloud-config

users:
  - name: ${ssh_user}
    groups:
      - sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${ssh_public_key}

package_update: true
package_upgrade: true

packages:
  - ca-certificates
  - curl
  - gnupg
  - apt-transport-https
  - containerd

write_files:

  # Kubernetes version pin
  - path: /etc/kubernetes-version
    permissions: "0644"
    content: |
      ${kubernetes_version}


  # Kubernetes sysctl
  - path: /etc/sysctl.d/99-kubernetes.conf
    permissions: "0644"
    content: |
      net.bridge.bridge-nf-call-iptables = 1
      net.bridge.bridge-nf-call-ip6tables = 1
      net.ipv4.ip_forward = 1


  # containerd config
  - path: /etc/containerd/config.toml
    permissions: "0644"
    content: |
      version = 2

      [plugins."io.containerd.grpc.v1.cri"]
        sandbox_image = "registry.k8s.io/pause:3.10"

        [plugins."io.containerd.grpc.v1.cri".containerd]
          snapshotter = "overlayfs"

        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          runtime_type = "io.containerd.runc.v2"

          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = true


runcmd:

  #################################
  # OS preparation
  #################################

  - swapoff -a
  - sed -i '/ swap / s/^/#/' /etc/fstab

  - modprobe overlay
  - modprobe br_netfilter

  - sysctl --system


  #################################
  # containerd
  #################################

  - systemctl enable containerd
  - systemctl restart containerd


  #################################
  # Kubernetes repository
  #################################

  - mkdir -p /etc/apt/keyrings

  - curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key |
      gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

  - |
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
    https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" \
    > /etc/apt/sources.list.d/kubernetes.list


  - apt-get update


  #################################
  # Kubernetes install
  #################################

  - |
    K8S_VERSION=$(cat /etc/kubernetes-version)

    apt-get install -y \
      kubelet=$${K8S_VERSION#v}-* \
      kubeadm=$${K8S_VERSION#v}-* \
      kubectl=$${K8S_VERSION#v}-*

  - apt-mark hold kubelet kubeadm kubectl


  #################################
  # kubelet preparation
  #################################

  - systemctl enable kubelet
  - systemctl stop kubelet


  #################################
  # VM template cleanup
  #################################

  - apt-get clean

  - truncate -s 0 /etc/machine-id

  - rm -f /etc/ssh/ssh_host_*


final_message: |
  Kubernetes node template ready.
  Installed:
    - containerd
    - kubelet
    - kubeadm
    - kubectl

  Next step:
    control-plane:
      kubeadm init

    worker:
      kubeadm join ...