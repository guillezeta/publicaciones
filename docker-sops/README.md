# Uso de SOPS en Postgres 

## Descargar Proyecto 

```
git clone https://github.com/guillezeta/publicaciones

cd docker-sops

```


## Configuraciones de SOPS (ruta archivo key de sops)

La variable *DEPLOY_MODE* en archivo docker-compose.yml va a especificar el modo de uso de sops, estos son 3:

1 - Para inicializar el archivo de key dejandolo en /sops/key.txt -> Realizar esto una sola vez
2 - Para encriptar archivo de variables (en este caso /secrets/postgres.env.age) -> Realizar esto una sola vez
3 - Para usarlo en el despliegue de Postgres desencriptando el archivo /secrets/postgres.env.age y colocandolo en la carpeta /secrets/postgres.env 
```

  sops:
    image: mozilla/sops:latest
    container_name: "sops"    
    environment:
      - DEPLOY_MODE=3  # Cambia según sea necesario (iniciar/encriptar/desencriptar)
    command: /bin/bash -c "/startup.sh"
    volumes:
      - ./secrets:/secrets
      - ./sops:/sops
      - ./startup.sh:/startup.sh:ro

```

## Desplegar el sistema

```
docker-compose up -d
```

## Bajar sistema

```
docker-compose down
```


