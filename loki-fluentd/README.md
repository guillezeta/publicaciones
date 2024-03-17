
# Visualizacion de logs usando Loki, Fluentd y Grafana

## Despliegue de loki

Ingresamos en la carpeta loki y ejecutamos

<pre>
kubectl apply -k .
</pre>

En grafana debemos buscar el Servicio de Loki acorde al servicio

<pre>
http://loki-service.kube-logging.svc.cluster.local:3100
</pre>

## Despliegue de fluentd

Ingresamos a carpeta fluentd y ejecutamos

<pre>
kubectl apply -k .
</pre>

Luego debemos ingresar a nuestro grafana e ingresar en connections --> Data Sources agregando loki y especificando la coneccion 

<pre>
http://loki-service.kube-logging.svc.cluster.local:3100
</pre>
