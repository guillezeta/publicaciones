echo "INICIO DE SCRIPT"
cd terraform
terraform init
echo "Se descargan los recursos necesarios de terraform"
terraform apply -auto-approve
echo "Se solicita la creacion de los nodos master (140) y worker (141) "
echo "Eliminamos si existen registros en known hosts de accesos previos"
ssh-keygen -f "/home/guillez/.ssh/known_hosts" -R "192.168.211.140" 
ssh-keygen -f "/home/guillez/.ssh/known_hosts" -R "192.168.211.141" 
cd ..
cd ansible
ansible-playbook playbook.yml
sleep 20
cd ..
cd k0s
k0sctl apply --config k0sctl.yaml
echo "Desplegando cluster K0S - Demora 2 minutos dependiendo de los recursos"


