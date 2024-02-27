terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox" 
      version = "2.7.4" 
    }
  }
}

provider "proxmox" {
  # url is the hostname (FQDN if you have one) for the proxmox host you'd like to connect to to issue the commands. my proxmox host is 'prox-1u'. Add /api2/json at the end for the API
  pm_api_url = "https://192.168.211.15:8006/api2/json" 
  # api token id is in the form of: <username>@pam!<tokenId>
  pm_api_token_id = "usuario1@pve!terraform-token" 
  # this is the full secret wrapped in quotes. don't worry, I've already deleted this from my proxmox cluster by the time you read this post
  pm_api_token_secret = "57d431a1-bf8d-4569-b5d7-63bd0cf415b0" 
 
  pm_otp = "" 
  pm_tls_insecure = true
}

resource "proxmox_lxc" "basic" {

  target_node  = var.proxmox_host
  hostname     = "TerraHost"
  start        = true
  ostemplate   = var.template_name
  unprivileged = true
  ostype       = "ubuntu"

  ssh_public_keys =  var.ssh_key

  // Terraform will crash without rootfs defined
  rootfs {
    storage = "local-lvm"
    size    = "8G"
  }
  nameserver = "8.8.8.8"
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "192.168.211.132/24" 
    gw     = "192.168.211.1"
   
  }

}
