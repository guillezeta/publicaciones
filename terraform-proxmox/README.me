TERRAFORM CON PROXMOX

CONFIGURACION DE SERVIDOR PROXMOX CON TERRAFORM

En terminal de Proxmox se puede crear los permisos requeridos para terraform

<pre>
pveum role add terraform-role -privs "VM.Allocate VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Monitor VM.Audit VM.PowerMgmt Datastore.AllocateSpace Datastore.Audit"

pveum user add terraform3@pve

pveum aclmod / -user terraform3@pve -role terraform-role

pveum user token add terraform3@pve terraform-token --privsep=0

┌──────────────┬──────────────────────────────────────┐
│ key          │ value                                │
╞══════════════╪══════════════════════════════════════╡
│ full-tokenid │ terraform@pve!terraform-token        │
├──────────────┼──────────────────────────────────────┤
│ info         │ {"privsep":"0"}                      │
├──────────────┼──────────────────────────────────────┤
│ value        │ 480bf00a-67e3-4285-b07e-56bf0696c91f │
└──────────────┴──────────────────────────────────────┘
</pre>

Tener en cuenta de asignar permisos a los discos en proxmox 


INSTALACION DE CLIENTE TERRAFORM

Generar una SSH key 

la ssh_kye se saca de la pce local generando un ssh-keygen y lugo se puede hacer un ssh-copy-id

ssh-keygen

CREACION DEL PROYECTO

Creamos los archivos 

vars.tf 

<pre>
variable "ssh_key" {
  default = "ssh-rsa .................." 
}
variable "proxmox_host" {
    default = "proxmox" 
}
variable "template_name" {
    default = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst" 
}
</pre>

y main.tf

<pre>
terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox" 
      version = "2.7.4" 
    }
  }
}

provider "proxmox" {
  # URL o ip del servidor proxmox. En mi caso es 'https://192.168.211.15:8006'. Agregando /api2/json al final
  pm_api_url = "https://192.168.211.15:8006/api2/json" 
  # api token creado en proxmox: <username>@pam!<tokenId>
  pm_api_token_id = "usuario1@pve!terraform-token" 
  # secret facilitado en el proceso de creacion del token
  pm_api_token_secret = "XXXXXXXX-XXXXXXXX-XXXXXXXX-XXXX" 
 
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

</pre>

Tener en cuenta que en Proxmox debemos tener bajado el template_name

TERRAFORM

Instalado Terraform , estando en la carpeta dondes estan los dos archivos creados (vars.tf y main.tf)

Para inicializar

<pre>
terraform init
</pre>

Para verificar los cambios que va a realizar terraform

<pre>
terraform plan 
</pre>

Para aplicar los cambios

<pre>
terraform apply
</pre>

Para destruir 

<pre>
terraform destroy
</pre>

Se podra oservar que se crean varios archivos que permitiran tener control sobre los cambios.

