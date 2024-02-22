
########## INSTALACION Y CONFIGURACION DE DOCKER EN LXC - Proxmox ##########

<pre>
Para Instalar Docker en Ubuntu 22.04

https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-22-04
</pre>

Consideraciones:

Características y Configuraciones del contenedor LXC

Plantilla utilizada: Ubuntu 22.04 

Agregar en el equipo instalado un usuario adicional para acceso futuro dado que al configurar el contenedor para uso con docker no permitira acceder nuevamente como root.

Configuarar en /etc/sudoers el usuario creado para que tenga permiso de sudo

Configuracion para uso de docker:

Editar archivo: /etc/pve/lxc/<NRO_CONTENEDOR>.conf

Agregar al final

<pre>
.....
lxc.apparmor.profile: unconfined
lxc.cgroup.devices.allow: a
lxc.cap.drop: 
lxc.mount.auto: "proc:rw sys:rw"
lxc.hook.mount: 
lxc.hook.post-stop: 
</pre>

En caso de que exista la linea "protection: 0" se debe eliminar

luego de editado esto se deba reiniciar el contenedor