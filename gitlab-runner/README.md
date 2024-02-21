Instalación de Gitlab CI/CD

Este documento contiene los pasos para instalar Contenedor Docker con Gitlab y Runner para uso de Pipelines

Requerimientos:

- Equipos con Servicio Docker

Consideraciones:

Se procedera a instalar 2 contenedores docker dentro de Proxmox con LXC.

Características y Configuraciones del contenedor LXC

Plantilla utilizada: Ubuntu 22.04 

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





