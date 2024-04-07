# Uso de SOPS en Postgres 

## Descargar Proyecto 

```
git clone 

```


## Configuraciones de SOPS (ruta archivo key de sops)

```

export SOPS_AGE_KEY_FILE=$HOME/.sops/key.txt

```

## Encriptacion de archivos 

```
sops --encrypt --age $(cat $SOPS_AGE_KEY_FILE |grep -oP "public key: \K(.*)") -i postgres.env.age

```

## Desencriptar archivos 

```
sops --decrypt --age $(cat $SOPS_AGE_KEY_FILE |grep -oP "public key: \K(.*)") -i postgres.env.age

```

## Desplegar el sistema

```
docker-compose up -d
```

## Bajar sistema

```
docker-compose down
```


