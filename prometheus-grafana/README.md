## INSTALACION DE PROMETHEUS Y GRAFANA

# Instalamos stack de prometheus con grafana
<pre>
helm install prometheus prometheus-community/kube-prometheus-stack


NAME: prometheus
LAST DEPLOYED: Wed Mar 13 23:26:56 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace default get pods -l "release=prometheus"

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.
</pre>

# Verificamos que todo este correctamente levantado

<pre>

 kubectl get all -n default
NAME                                                         READY   STATUS    RESTARTS   AGE
pod/alertmanager-prometheus-kube-prometheus-alertmanager-0   2/2     Running   0          3m56s
pod/prometheus-grafana-84b7c78578-s59x9                      3/3     Running   0          4m54s
pod/prometheus-kube-prometheus-operator-67f787f678-ckwv6     1/1     Running   0          4m54s
pod/prometheus-kube-state-metrics-6b9ff84f5f-vz6nz           1/1     Running   0          4m54s
pod/prometheus-prometheus-kube-prometheus-prometheus-0       2/2     Running   0          3m55s
pod/prometheus-prometheus-node-exporter-9nlkh                1/1     Running   0          4m54s

NAME                                              TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
service/alertmanager-operated                     ClusterIP   None             <none>        9093/TCP,9094/TCP,9094/UDP   3m57s
service/kubernetes                                ClusterIP   10.96.0.1        <none>        443/TCP                      2d
service/prometheus-grafana                        ClusterIP   10.106.122.251   <none>        80/TCP                       4m56s
service/prometheus-kube-prometheus-alertmanager   ClusterIP   10.105.151.159   <none>        9093/TCP,8080/TCP            4m56s
service/prometheus-kube-prometheus-operator       ClusterIP   10.103.82.189    <none>        443/TCP                      4m56s
service/prometheus-kube-prometheus-prometheus     ClusterIP   10.104.142.187   <none>        9090/TCP,8080/TCP            4m56s
service/prometheus-kube-state-metrics             ClusterIP   10.108.38.170    <none>        8080/TCP                     4m56s
service/prometheus-operated                       ClusterIP   None             <none>        9090/TCP                     3m56s
service/prometheus-prometheus-node-exporter       ClusterIP   10.108.87.65     <none>        9100/TCP                     4m56s

NAME                                                 DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/prometheus-prometheus-node-exporter   1         1         1       1            1           kubernetes.io/os=linux   4m55s

NAME                                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/prometheus-grafana                    1/1     1            1           4m55s
deployment.apps/prometheus-kube-prometheus-operator   1/1     1            1           4m55s
deployment.apps/prometheus-kube-state-metrics         1/1     1            1           4m55s

NAME                                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/prometheus-grafana-84b7c78578                    1         1         1       4m55s
replicaset.apps/prometheus-kube-prometheus-operator-67f787f678   1         1         1       4m55s
replicaset.apps/prometheus-kube-state-metrics-6b9ff84f5f         1         1         1       4m55s

NAME                                                                    READY   AGE
statefulset.apps/alertmanager-prometheus-kube-prometheus-alertmanager   1/1     3m57s
statefulset.apps/prometheus-prometheus-kube-prometheus-prometheus       1/1     3m56s
</pre>

# Realizamos un acceso con port forward

<pre>
kubectl port-forward service/prometheus-grafana 3000:80
</pre>

# accedemos en navegador http://localhost:3000

# El acceso por defecto es con  admin -> prom-operator

# Para obtener los valores por defecto del despliegue con helm

helm show values prometheus-community/kube-prometheus-stack > prometheus-default-values.yaml






