variable "ssh_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDN/L/Cc5nSaZPmQv78EGXnHese0jHr35ac2wH7iyKtEOvLPytCT/q+QhklK5G0ftr6tbQi1VfDZgCuXyThW+e+n1WJTPfr5bkN5fLcRtV24/seTFiWScz9oBRMR5OMDZ/j3zGO0vU1vHJlf5XeKE4UJs9Ho7ZZXwYTa+QXrLGh3Wj7ldNSxVVC5e7AlG+E/Vz4+8cAFExDSIP19c8ZZonSDFdLEC2Zqbh8r9jJg3qYWbkBakZt6qQ9Ej3g1dwLhmRNWqt12u1sl1//t0Ba9ATfbBZGv1r56Ml7tw61+pdwKrl+GWy27ptQ4DXzQ8t7sVMkGzpM7yaHUCqhvdkFChf6eB/orP/BTxXiInJeTA6VcCNqUcPLM/7Ow69UcVhDAc3oo7/4KadIb4wzaIBWdaE9Ok0dxGpmgtcw67SPC/tGljtx3zrxpmA9zPATHuXPpx0SNTaONTBxBYW03uZjpxtbhRkbWPJFXRW72o26H7HE8B8R8UGqCL6EbzR7YveUO00= guillez@guilleznt" 
}
variable "proxmox_host" {
    default = "proxmox" 
}
variable "template_name" {
    default = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst" 
}

