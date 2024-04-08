#!/bin/bash

echo "DEPLOY_MODE: $DEPLOY_MODE"

if [[ "$DEPLOY_MODE" == 1 ]]; then
    echo "Iniciando el key contenedor..."
    apt-get update
    apt-get install -y age
    age-keygen -o /sops/key.txt
    chmod 777 /sops/key.txt
elif [[ "$DEPLOY_MODE" == 2 ]]; then
    echo "Encriptando archivos..."
    # Exporta la variable de entorno SOPS_AGE_KEY_FILE
    export SOPS_AGE_KEY_FILE=/sops/key.txt
    # Cifra todos los archivos en la carpeta /secrets
    sops --encrypt --age $(cat $SOPS_AGE_KEY_FILE |grep -oP "public key: \K(.*)") -i /secrets/postgres.env.age
    
elif [[ "$DEPLOY_MODE" == 3 ]]; then
    echo "Desencriptando archivos..."
    # Exporta la variable de entorno SOPS_AGE_KEY_FILE
    export SOPS_AGE_KEY_FILE=/sops/key.txt
    # Cifra todos los archivos en la carpeta /secrets
    sops --decrypt /secrets/postgres.env.age > /secrets/postgres.env    
else
    echo "Modo de despliegue no válido"
fi



