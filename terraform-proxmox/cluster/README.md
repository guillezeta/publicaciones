# Esta documentacion muestra como se crea una plantilla de proxmox destinada a usar con k0s
# y como desplegar el cluster. Las carpetas siguientes contienen:

1 - carpeta master: contiene lo necesario para desplegar con terraform en proxmox el nodo master

2 - carpeta worker: contiene lo necesario para desplegar con terraform en proxmox el nodo worker

3 - carpeta k0s: contiene lo necesario para desplegar el cluester k0s en los nodos creados

4 - carpeta ansible: contiene configuraciones ejecutadas en el server de proxmox mediante ansible

NOTA: adicionalmente se incorpora ayuda de como armar un template en proxmox para poder usarlo en terraform con proxmox.

INDICACIONES: Crear un contenedor LXC basados en el video: https://www.youtube.com/watch?v=D5NChlEW8v8 teniendo en cuenta lo agregado abajo que esa indicado como consideraciones adicionales.


# ejecutamos primer archivo bash

<pre>
./iniciar.sh

</pre>

# Luego de que el cluster queda con el mensaje esperando el nodo , en otra consola ejecutamos

<pre>
./servicios_k0s.sh
</pre>
