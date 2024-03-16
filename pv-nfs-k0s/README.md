
# Volumenes Persistentes NFS en Kubernetes (K0S)

## Creacion de Servidor NFS

En Proxmox vamos a utilizar un contendor lxc de Ubuntu

Editamos el archivo /etc/pve/lxc/135.conf agregando al final

lxc.apparmor.profile: unconfined


Actualizamos los paquetes de Ubuntu

apt update && apt upgrade -y

Instalamos el servicio NFS

apt install nfs-kernel-server -y

Creamos una carpeta 

mkdir /data/nfs

Asignamos permisos a la carpeta

chmod 777 /data/nfs/ -R

Configuramos en /etc/exports

/data/nfs2 192.168.211.0/24(rw,sync,no_subtree_check)
/data/nfs *(rw,sync,no_subtree_check,insecure)

Ejecutamos para renovar lo configurado

exportfs -arv

Reiniciamos Ubuntu

reboot

# Para disponer el volumen en Proxmox podemos acceder desde

Datacenter -> Storage -> Boton (Add) -> NFS

id: NEWNFS
server: 192.168.211.135
Export: /data/nfs
Context: Disk Image

Aceptamos y veremos en Storage disponible nuestro servicio NFS (NEWNFS)

# Comandos de informacion del cluster k0s

<pre>
kubectl cluster-info
</pre>

Kubernetes control plane is running at https://127.0.0.1:44977/11c0715f72822c67e85e404d769444d3
CoreDNS is running at https://127.0.0.1:44977/11c0715f72822c67e85e404d769444d3/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

<pre>
kubectl version --short
</pre>

Flag --short has been deprecated, and will be removed in the future. The --short output will become the default.
Client Version: v1.27.2
Kustomize Version: v5.0.1
Server Version: v1.27.2+k0s

En Nodo worker vamos a verificar acceso al servicio NFS ya instalado

Accedemos via ssh al servidor

ssh root@192.168.211.141

Instalamos el paquete nfs

dnf install nfs-utils

Verificamos el acceso al server NFS (192.168.211.135)

showmount -e 192.168.211.135

Export list for 192.168.211.135:
/data/k0s *
/data/nfs 192.168.211.0/24

Si deseamos probar montar la carpeta /data/k0s

mount -t nfs 192.168.211.135:/data/k0s /mnt

con el comando veremos informacion de carpeta montada de nfs

mount | grep k0s

Para desmontar

umount /mnt

# Configuraciones del PV-NFS

Asignando de forma manual el PV

Creamos un archivo pv-nfs.yml y cambiamos donde dice <nfs server ip> 
<pre>
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-nfs-pv1
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: <nfs server ip>
    path: "/data/k0s"

</pre>

Creamos un archivo pvc-nfs.yml 

<pre>
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-nfs-pv1
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 500Mi
</pre>

Levantamos un Nginx que usa el PVC

<pre>

apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    run: nginx
  name: nginx-deploy
spec:
  replicas: 1
  selector:
    matchLabels:
      run: nginx
  template:
    metadata:
      labels:
        run: nginx
    spec:
      volumes:
      - name: www
        persistentVolumeClaim:
          claimName: pvc-nfs-pv1
      containers:
      - image: nginx
        name: nginx
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
</pre>

Paso final vamos a crear el port-forward para acceder a nginx

<pre>
kubectl expose deploy nginx-deploy --port 80 --type NodePort
</pre>

