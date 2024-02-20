
En un equpo con docker instalado crear el archivo con el contenido (digamos docker.sh)

docker network create registry

docker run -d -p 5000:5000 \
              --restart=always \
              --name registry_private \
              -v $(pwd)/docker-registry:/var/lib/registry \
              --network registry \
              registry:latestroot@registry:/data/docker-sin-auth# 

Luego ejecutar en consola dandole permisos de ejecucion

chmod 777 docker.sh

./docker.sh

Con esto ya qaueda funcional

IMPORTANTE!! la configuracion siguiente debe aplicarse en cada equipo que deseamos use el repositorio
------------------------------------------------------------------------------------------------------
En cada cliente se debe editar el archivo

Crear el archivo /etc/docker/daemon.json
<pre>
{
  "insecure-registries":["192.168.211.130:5000"]
}
</pre>

Luego reiniciar el servicio docker

systemctl stop docker

systemctl start docker

Verifico que este funcionando

systemctl status docker

------------------------------------------------------------------------------------------------------
Para probar el funcionamiento

Para probar podemos bajar una imagen de docker hub 

docker pull nginx:latest

si mi servidor tiene la ip 192.168.211.130 

docker tag nginx 192.168.211.130:5000/nginx

Subo la imagen

docker push 192.168.211.130:5000/nginx

Verifico la existencia

curl -X GET http://192.168.211.130:5000/v2/_catalog
{"repositories":["nginx"]}

en cualquier equipo que deseo bajar la imagen, dentro de la misma red

docker pull http://192.168.211.130:5000/nginx:latest








