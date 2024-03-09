terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.7.4"
    }   
    
  }
}



# Lee el archivo JSON
locals {
  config = jsondecode(file("./secret.json"))
}


provider "proxmox" {
  # url is the hostname (FQDN if you have one) for the proxmox host you'd like to connect to to issue the commands. my proxmox host is 'prox-1u'. Add /api2/json at the end for the API
  pm_api_url = "https://192.168.211.15:8006/api2/json" 
  # api token id is in the form of: <username>@pam!<tokenId>
  pm_api_token_id = local.config.proxmox.pm_api_token_id
  # this is the full secret wrapped in quotes. don't worry, I've already deleted this from my proxmox cluster by the time you read this post
  pm_api_token_secret = local.config.proxmox.pm_api_token_secret
 
  pm_otp = "" 
  pm_tls_insecure = true
}

# DESPLIEGUE DEL MASTER

resource "proxmox_lxc" "master" {

  target_node  = local.config.proxmox.host
  vmid         = "140"
  hostname     = "master1"
  start        = true
  ostemplate   = local.config.proxmox.template_rocky
  unprivileged = true
  ostype       = "centos"

  ssh_public_keys =  local.config.ssh.public_key
  
  // Terraform will crash without rootfs defined
  rootfs {
    storage = "local-lvm"
    size    = "8G"
  }

  nameserver = "8.8.8.8"
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "192.168.211.140/24" 
    gw     = "192.168.211.1"
  }

  connection {
      type        = "ssh"
      user        = "root"
      host        = "192.168.211.140"
  }

}

# DESPLIEGUE DEL WORKER

resource "proxmox_lxc" "worker" {

  target_node  = local.config.proxmox.host
  vmid         = "141"
  hostname     = "worker1"
  start        = true
  ostemplate   = local.config.proxmox.template_rocky
  unprivileged = true
  ostype       = "centos"

  ssh_public_keys =  local.config.ssh.public_key
  
  // Terraform will crash without rootfs defined
  rootfs {
    storage = "local-lvm"
    size    = "8G"
  }

  nameserver = "8.8.8.8"
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "192.168.211.141/24" 
    gw     = "192.168.211.1"
  }

  connection {
      type        = "ssh"
      user        = "root"
      host        = "192.168.211.141"
  }

}