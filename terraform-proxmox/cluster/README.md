# Esta documentacion muestra como se crea una plantilla de proxmox destinada a usar con k0s
# y como desplegar el cluster. Las carpetas siguientes contienen:

1 - carpeta master: contiene lo necesario para desplegar con terraform en proxmox el nodo master

2 - carpeta worker: contiene lo necesario para desplegar con terraform en proxmox el nodo worker

3 - carpeta k0s: contiene lo necesario para desplegar el cluester k0s en los nodos creados

NOTA: adicionalmente se incorpora ayuda de como armar un template en proxmox para poder usarlo en terraform con proxmox.

INDICACIONES: Crear un contenedor LXC basados en el video: https://www.youtube.com/watch?v=D5NChlEW8v8 teniendo en cuenta lo agregado abajo que esa indicado como consideraciones adicionales.

Creado el contenedor lxc con rocky-linux-8 como plantilla procedemos a seguir los pasos

ingresando a terminal de Proxmox editamos configuracion de contenedor antes de iniciarlo

mcedit /etc/pve/lxc/132.conf

<pre>

arch: amd64
cores: 1
hostname: plantilla-k0s
memory: 1024
net0: name=eth0,bridge=vmbr0,firewall=1,gw=192.168.211.1,hwaddr=9A:22:92:49:8A:FA,ip=192.168.211.132/24,type=veth
ostype: centos
rootfs: local-lvm:vm-132-disk-0,size=20G
searchdomain: 8.8.8.8
swap: 0
lxc.apparmor.profile: unconfined
lxc.cgroup.devices.allow: a
lxc.cap.drop:
lxc.mount.auto: "proc:rw sys:rw"

</pre>
----------------------------------
Ingresamos al contenedor desde proxmox dado que rocky linux no tiene ssh

pct enter 132 

Instalamos ssh server

dnf install openssh-server

Iniciamos el servicio

systemctl start sshd

# consideramos que nuestro contenedor es el 132

pct start 132 

pct push 132 /boot/config-$(uname -r) /boot/config-$(uname -r)

pct enter 132

# creamos la carpeta

mkdir /dev/kmsg

# creamos el archivo

vi /usr/local/bin/conf-kmsg.sh

<pre>

#!/bin/sh -e
if [ ! -e /dev/kmsg ]; then
	ln -s /dev/console /dev/kmsg
fi
mount --make-rshared /

</pre>

# tambien este otro

vi /etc/systemd/system/conf-kmsg.service

<pre>

Description=Make sure /dev/kmsg exists
[Service]
Type=simple
RemainAfterExit=yes
ExecStart=/usr/local/bin/conf-kmsg.sh
TimeoutStartSec=0
[Install]
WantedBy=default.target


</pre>

# ejecutamos los comandos

<pre>

chmod +x /usr/local/bin/conf-kmsg.sh
systemctl daemon-reload 
systemctl enable --now conf-kmsg

</pre>

# Antes de convertirlo a template vamos a eliminar configuraciones de ssh y nombre de equipo

rm /etc/ssh/ssh_host_*

# Elimino machine-id para que al usar el template cambie el nombre del contenedor

truncate -s 0 /etc/machine-id

# apagar el contenedor

poweroff


# -----------------desde proxmox------------------

vzdump 132 --mode stop --compress gzip --dumpdir /var/lib/vz/template/cache/

# entre otros datos veremos la devolucion

# INFO: creating vzdump archive '/var/lib/vz/template/cache/vzdump-lxc-132-2024_03_09-11_02_54.tar.gz'

# en mi caso tengo las plantillas que se suelen bajar en proxmox en /var/lib/vz/template/cache , usar la ruta donde se encuentran 

# renombramos la plantilla para que nos sea mas facil buscarla

mv vzdump-lxc-132-2024_03_09-11_02_54.tar.gz template_k0s.tar.gz

# -----------Despliegue de k0s---------------------

# Nos aseguramos que tenemos acceso ssh con root a los nodos

ssh root@192.168.211.140
ssh root@192.168.211.141

# debe ingresar sin contraseñas como tampoco solicitar autorizacion

# En la carpeta k0s 

# Si no tengo el archivo k0sctl.yaml lo creo con la configuracion

<pre>

apiVersion: k0sctl.k0sproject.io/v1beta1
kind: Cluster
metadata:
  name: k0s-cluster
spec:
  hosts:
  - ssh:
      address: 192.168.211.140
      user: root
      port: 22
      keyPath: ~/.ssh/id_rsa
    role: controller
  - ssh:
      address: 192.168.211.141
      user: root
      port: 22
      keyPath: ~/.ssh/id_rsa
    role: worker
  k0s:
    version: 1.27.2+k0s.0
    dynamicConfig: false
    config:
      apiVersion: k0s.k0sproject.io/v1beta1
      kind: Cluster
      metadata:
        name: k0s
      spec:
        images:
          calico:
            cni:
              image: calico/cni
              version: v3.18.1
        api:
          k0sApiPort: 9443
          port: 6443
        installConfig:
          users:
            etcdUser: etcd
            kineUser: kube-apiserver
            konnectivityUser: konnectivity-server
            kubeAPIserverUser: kube-apiserver
            kubeSchedulerUser: kube-scheduler
        konnectivity:
          adminPort: 8133
          agentPort: 8132
        network:
          kubeProxy:
            disabled: false
            mode: iptables
          kuberouter:
            autoMTU: true
            mtu: 0
            peerRouterASNs: ""
            peerRouterIPs: ""
          podCIDR: 10.244.0.0/16
          provider: kuberouter
          serviceCIDR: 10.96.0.0/12
        podSecurityPolicy:
          defaultPolicy: 00-k0s-privileged
        storage:
          type: etcd
        telemetry:
          enabled: true

</pre>

# borramos credenciales locales por si ya hemos tenido un acceso con la misma ip en otro server

ssh-keygen -f "/home/guillez/.ssh/known_hosts" -R "192.168.211.140"
ssh-keygen -f "/home/guillez/.ssh/known_hosts" -R "192.168.211.141"

# Nota: la ruta de /home/guillez es personal segun el usuario que esta ejecutando el comando

# Desplegar el cluster

k0sctl apply --config k0sctl.yaml

# Luego de unos minutos obtenemos los datos de acceso

k0sctl kubeconfig > kubeconfig

# con los datos otenidos en el archivo kubeconfig podremos ingresar al cluster

