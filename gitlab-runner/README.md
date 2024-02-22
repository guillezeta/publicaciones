######## INSTALACION DE GITLAB CI/CD ########

Este documento contiene los pasos para instalar Contenedor Docker con Gitlab y Runner para uso de Pipelines

Requerimientos:

- Equipos con Servicio Docker

DESPLIEGUE DE GITLAB

<env>
docker network create gitlab

docker run --detach \
  --hostname 127.0.0.1 \
  --publish 443:443 --publish 80:80 --publish 2222:22 \
  --name gitlab-cicd \
  --restart always \
  --volume ./config:/etc/gitlab \
  --volume ./logs:/var/log/gitlab \
  --volume ./data:/var/opt/gitlab \
  --network gitlab \
  gitlab/gitlab-ce:16.7.5-ce.0
</env>

Luego de que me de el login en el navegador, para obtener la password del usuario root

Para obtener la password

<pre>
sudo docker exec -it gitlab-cicd grep 'Password:' /etc/gitlab/initial_root_password
</pre>

GITLAB RUNNER

<pre>
docker run -d --name gitlab-runner --restart always \
    -v /srv/gitlab-runner/config:/etc/gitlab-runner \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --network gitlab \
    gitlab/gitlab-runner:v16.3.0
</pre>

INGRESAR A GITLAB Y REALIZAR LOS PASOS

1 - Crear un Grupo

2 - Crear un proyecto en el Grupo

3 - Acceder en las opciones de administracion de Gitlab "Setings"

  - En Setings --> General
    - Desplegar area "Visibility and access controls"
        - Asignar ip o dominio de Gitlab en "Custom Git clone URL for HTTP(S)"
            Ej: http://192.168.211.131


4 - Volver a pantalla principal de Gitlab y buscar el proyecto e ingresar

Acceder en la opcion "Setings" --> CI/CD

- Desplegar el item Runners

- Desactivar opcion "Enable shared runners for this project"

- Crear un nuevo Runner en boton "New proyect runner"

    - Si tenemos linux dejamos como esta la seleccion de Sistema Operativo
    - En Tags ingresamos "dind" y tildamos opcion "Run untagged jobs"
    - Presionamos en boton Create Runner

    * En el proceso nos mostrara que debemos ejecutar dentro del contenedor Runner algo como:

NOTA: En mi caso muestra un error debido a mal interpretacion del dominio, esto lo salvamos 
     reemplazando en la url mostrada como ejemplo

     http://127.0.0.1/devops/test/-/runners/10/register?platform=linux

     por

     http://192.168.211.131/devops/test/-/runners/10/register?platform=linux

     la ip: 192.168.211.131 es en mi caso donde tengo instalado gitlab, en caso de tener dominio colocar su dominio o de lo contrario la ip donde esta instalado gitlab.

Ejemplo:
<pre>
gitlab-runner register  --url http://127.0.0.1  --token glrt-S2rFgqGuKy-qUy85qsKG
</pre>
Notar que tambien aca debemos cambiar la ip
<pre>
gitlab-runner register  --url http://192.168.211.131  --token glrt-S2rFgqGuKy-qUy85qsKG
</pre>

Tomar esto y ejecutar en el Contenedor Runner, para ello en consola, donde tenemos levantado el runner ejecutar

docker exec -ti gitlab-runner bash

- Ejecutamos lo que nos mostro al crear el runner y veremos entre otras opciones las siguientes

  * en la ejecucion nos va a pedir confirmar la ip del servidor gitlab, dejamos como esta
  * Nos va a solicitar Ingresar el fin del runner: Docker
  * La imagen a usar para ejecucion por el runner "docker:dind"

Una vez terminada la ejecucion , dentro del contenedor, vamos a instalar un editor para poder modificar las configuraciones del runner

<pre>
apt update

apt install mc

mcedit /etc/gitlab-runner/config.toml

</pre>

El archivo entre otras cosas va a tener

<pre>
concurrent = 1
check_interval = 0
shutdown_timeout = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "ad962e1f0085"
  url = "http://192.168.211.131"
  id = 3
  token = "glrt-qqaZ5gB-VTskoZLBcWBU"
  token_obtained_at = 2024-02-21T22:40:13Z
  token_expires_at = 0001-01-01T00:00:00Z
  executor = "docker"
  [runners.cache]
    MaxUploadedArchiveSize = 0
  [runners.docker]
    tls_verify = false
    image = "docker:dind"
    privileged = true
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/var/run/docker.sock:/var/run/docker.sock","/cache"]
    shm_size = 0
</pre>

Modificar las lineas
<pre>
privileged = true

volumes = ["/var/run/docker.sock:/var/run/docker.sock","/cache"]
</pre>

Luego guardar y salir del contenedor

ejecutar

docker stop gitlab-runner

docker start gitlab-runner

- Vamos a verificar que nuestro runner esta corriendo en gitlab en:

    Volver a pantalla principal de Gitlab y buscar el proyecto e ingresar

    Acceder en la opcion "Setings" --> CI/CD

    - Desplegar el item Runners

5 - Nos creamos un usuario en Docker Hub

6 - Agregamos 2 variables de entorno para acceder a Docker Hub

 Acceder en la opcion "Setings" --> CI/CD

 * Desplegamos la opcion "Variables" y en add variables agregamos en mi caso:

DOCKERHUB_USER -> En valor ponemos el usuario de docker hub
DOCKERHUB_PASSWORD -> En valor ponemos la password de docker hub

Con esto terminamos las configuraciones y pasamos a nuestro equipo local para probar

------------------------------------------------------------

En nuestro equipo vamos a bajar el proyecto de gitlab, en mi caso

git clone  http://192.168.211.131/devops/test

usamos nuestro usuario root y clave obtenidos

ingresamos al proyecto y cremos ls archivos para probar 

a - Archivo .gitlab-ci.yml

    <pre>
    build master:
  image: docker:dind
  stage: build
  services:
    - docker:dind

  before_script:
    - export CI_REGISTRY_IMAGE='sincables/webnginx'
    - docker login -u "$DOCKERHUB_USER" -p "$DOCKERHUB_PASSWORD" 

  script:
    - docker pull $CI_REGISTRY_IMAGE:latest || true
    - >
      docker build -f docker/Dockerfile
      --pull
      --cache-from $CI_REGISTRY_IMAGE:latest
      --label "org.opencontainers.image.title=$CI_PROJECT_TITLE"
      --label "org.opencontainers.image.url=$CI_PROJECT_URL"
      --label "org.opencontainers.image.created=$CI_JOB_STARTED_AT"
      --label "org.opencontainers.image.revision=$CI_COMMIT_SHA"
      --label "org.opencontainers.image.version=$CI_COMMIT_REF_NAME"
      --tag $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
      .
    - docker tag $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA $CI_REGISTRY_IMAGE:latest
    - docker push $CI_REGISTRY_IMAGE:latest
    </pre>


b - Carpeta denominada docker con:
    - Archivo Dockerfile con contenido siguiente

    <pre>
        FROM nginx:latest

        # Copia un archivo index.html que contiene el mensaje "FELICITACIONES!!" en el directorio raíz del servidor web de nginx
        COPY ./docker/index.html /usr/share/nginx/html/

        # Define el comando predeterminado a ejecutar cuando se inicie el contenedor
        CMD ["nginx", "-g", "daemon off;"]
    </pre>

    - Archivo index.html con contenido 

    <pre>
        MI NUEVA WEB
    </pre>

Luego de creado todo esto subimos los archivos al repositorio

git add .gitlab-ci.yml
git add *

git commit -m 'primer codigo pipeline'

git push
Ingresamos nuevamente el usuario / clave de acceso a gitlab

Con esto tenemos que ver que se esta ejecutando nuestro primer pipeline y deberia hacerlo con exito
