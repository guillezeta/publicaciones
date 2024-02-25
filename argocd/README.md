INSTALACION DE ARGOCD EN KUBERNETES

Agregamos el repo de Helm

<pre>
helm repo add argo https://argoproj.github.io/argo-helm
</pre>

Hacemos pull del Chart para descargarlo

<pre>
helm pull argo/argo-cd --version 5.8.2
</pre>

Descomprimimos el paquete TGZ del Chart descargado

<pre>
tar -zxvf argo-cd-5.8.2.tgz
</pre>

Hacemos la instalación con nuestras configuraciones

<pre>
helm install argo-cd argo-cd/ \
  --namespace argocd \
  --create-namespace --wait 
</pre>

Obtenemos la contraseña del usuario "admin" por defecto que se ha generado automáticamente en la instalación

<pre>
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
</pre>

Levantamos un Port-Forward para poder acceder a ArgoCD UI desde localhost:8080

<pre>
kubectl port-forward service/argo-cd-argocd-server -n argocd 8181:443
</pre>

Al ingresar con el navegador en http://localhost:8181 , e ingresamos con admin y la contraseña antes optenida

Y dentro Argocd vamos a incorporar un repositorio que sera donde se suba los cambios del proyecto y en el cual se bassa el despliegue de kubernetes.

Procedemos a ingresar a:

Settings -> Repositories

- Metodo de Coneccion: https
- Tipo: git
- Proyect: test
- Repository URL: http://192.168.211.129/devops/test.git
- Username: root
- Password: XXXXXXX

Para la configuracion del Cluster es simple dado aque al tener desplegado Argo CD en el mismo, ya tendremos la configuracion realizada, siempre y cuando nuestra intencion sea usar el mismo cluster para los despliegues.

Ya con la confirmacion de que Argo CD esta ok con el repositorio vamos a bajar en nuestro equipo local el repositorio, en nuestro caso es:

<pre>
git clone http://192.168.211.129/devops/test.git
</pre>

Ingresamos nuestro usuario y password

Bajado el repositorio , ingresamos y procedemos a crear una carpeta, en mi caso una llamada webnginx, dentro vamos a crear 2 archivos:

deploy.yaml

<pre>
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webnginx
spec:
  replicas: 1
  revisionHistoryLimit: 3
  selector:
    matchLabels:
      app: webnginx
  template:
    metadata:
      labels:
        app: webnginx
    spec:
      containers:
      - image: sincables/webnginx
        name: webnginx-ui
        ports:
        - containerPort: 80
</pre>

service.yaml

<pre>
apiVersion: v1
kind: Service
metadata:
  name: webnginx
spec:
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: webnginx
</pre>

Luego lo subimos al repositorio 

<pre>
git add webnginx/*

git commit -m 'Despliegue de nginx en cluster'

git push 
</pre>

Una vez subidos estos archivos estamos en condiciones de usar Argo para que lo despliegue

En nustro entorno Argo CD web, (http://localhost:8181) 

Creamos un proyecto de pruebas en el que solo se puedan crear aplicaciones en el namespace "testing" y con determinado repositorio de código


kubectl create ns webnginx -> opcional en caso de indicar a Argo CD que lo cree 

Ahora creamos nuestra primera aplicación de pruebas en el proyecto que hemos creado anteriormente

Settings -> Projects 

- New Project -> Asignamos Nombre, en mi caso webnginx

Luego debemos definir

SOURCE REPOSITORIES: http://192.168.211.129/devops/test.git -> en mi caso

DESTINATIONS: Server-> https://kubernetes.default.svc -> de querer indicar un namespace especifico debemos crearlo antes para asignarlo.

Luego en el menu principal de Argo CD, ingreso a la opcion Aplicaciones

- NEW APP

* Asigno nombre a la aplicacion , en micaso le di el nombre "webnginx"
* Aelecciono de la lista el proyecto creado webnginx en mi caso
* SYNC POLICY: Automatic -> esto puede ser Manual tambien
* Si no tengo creado el namespace puedo tildar la opcion "AUTO-CREATE NAMESPACE"

en SOURCE:

* Repository URL: http://192.168.211.129/devops/test.git
* Revision - "Rama" main en mi caso
* path: webnginx -> que es la carpeta dentro del repositorio donde se tienen los archivos de kubernetes.

en DESTINATIONS

* Cluster URL: https://kubernetes.default.svc
* Namespace: webnginx

Luego al final hay un boton CREATE en la parte superior

Con esto vas a observar que se va a desplegar un nginx y que podras acceder creando en tu cluster un port-worward -> es importante oservar que se creen todos los recursos, incluso el POD que es el ultimo en aparecer en Argo CD.

<pre>
kubectl port-forward service/webnginx -n webnginx 8282:443
</pre>

Abris en el navegador la url: http://localhost:8282 y veras el nginx corriendo una web ejemplo

----------------------------------------------------

En caso de querer desinstalar Argo CD del cluster

<pre>
helm list -n argocd
</pre>
Desinstalamos Argo!

<pre>
helm uninstall argo-cd -n argocd
</pre>

Ahora podemos eliminar los Namespaces que hemos creado

<pre>
kubectl delete ns argocd
</pre>
