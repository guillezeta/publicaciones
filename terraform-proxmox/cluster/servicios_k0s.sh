echo "INICIO DE SCRIPT SERVICIOS CLUSTER"
cd k0s
k0sctl kubeconfig > kubeconfig.yaml
echo "En la carpeta k0s se crea un archivo kubeconfig que contiene los datos de acceso al cluster"
echo "-----------kubeconfig---------"
echo ./kubeconfig.yaml
export KUBECONFIG=./kubeconfig.yaml
echo "-----------matallb---------"
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.10/config/manifests/metallb-native.yaml
kubectl apply -f config-pool.yml
echo "-----------calico---------"
kubectl apply -f calico.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.0/deploy/static/provider/cloud/deploy.yaml
echo "FIN DE SCRIPT"

