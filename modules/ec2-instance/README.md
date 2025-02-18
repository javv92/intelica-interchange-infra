# EC2 Instance

## Aplicaciones

Iniciar sesión en la instancia como el usuario ec2-user

```shell
sudo su ec2-user
cd $HOME
```

Listar las tareas de crontab

```shell
crontab -l
```

Salida

```shell
# Notification: Invoca el lambda que realiza el envió de correos
0 * * * * ./interchange/Build/SH/Notification.sh >> ./interchange/Log/OPERATIONAL/Notification_log.log 2>&1
45 21 * * * ./interchange/Build/SH/exchange_rate.sh
5 21 * * * ./interchange/Build/SH/exchange_rate.sh
```

## Notification

Se ejecuta con el siguiente script `./interchange/Build/SH/Notification.sh`, el cual contiene

```shell
#!/usr/bin/env bash
source ~/interchange/interchange_env/bin/activate
python -u ~/interchange/Module/Notification/Notification.py
```

### Configuración

La configuración se encuentra en el archivo ~/interchange/.env. Las variables utilizadas por el script de notificación
son los siguientes:

- USER_NOTIFICATION_AWS_KEY
- USER_NOTIFICATION_AWS_ACCESS_KEY
- SECRET_RDS
- REGION_NAME
- SEND_MAIN_LAMBDA_NAME # gregado

### Errores

1.- el eejcutar el script `./interchange/Build/SH/Notification.sh` se obtenía el siguiente error

```shell
SCRAM authentication requires libpq version 10 or above
```

para solucionarlo se instaló pip3 y se instaló la librerpia `psycopg2-binary`

```shell
source ~/interchange/interchange_env/bin/activate
pip install psycopg2-binary -U
```

### Cambios

- Se quitó el uso a aws_access_key_id y aws_secret_key, para los clientes de boto 3, esto para que se utilicen los
  permisos otorgados via Instance Profile

> Ver archivo con los cambios [aquí](src/orchestrator.py)

## Orchestrator

El script de orchestrator se encuentra en `~/interchange/orchestrator.py`, se ejecuta con el siguiente comando
`nohup ./interchange/Build/SH/orchestrator.sh &/dev/null 2>&1 &` el cual contiene

```shell
#!/usr/bin/env bash
source ~/interchange/interchange_env/bin/activate
python -u ~/interchange/orchestrator.py
```

### Configuración

La configuración se encuentra en el archivo ~/interchange/.env. Las variables utilizadas por el script de notificación
son los siguientes:

- AWS_DEFAULT_REGION_1
- ENV_TYPE
- BUCKETS
- POSTGRE_DATABASE
- POSTGRE_HOST
- POSTGRE_PORT
- POSTGRE_USER
- POSTGRE_PASSWORD

### Cambios

#### archivo /home/ec2-user/interchange/orchestrator.py

- Se quitó el uso a aws_access_key_id y aws_secret_key, para los clientes de boto 3, esto para que se utilicen los
  permisos otorgados via Instance Profile
- Se ajustó la forma de obtener el nombre y urls de las colas sqs para ajustarlas a la nueva nomenclatura

```python
...
ACCOUNT_ID = boto3.client('sts').get_caller_identity().get('Account')
# QUEUE_URL = f"https://sqs.us-east-1.amazonaws.com/818835242461/app-interchange-"
QUEUE_NAME = "itl-0004-itx-%s-sqs-app-%s-01"  # (dev, client)
QUEUE_URL = "https://sqs.us-east-1.amazonaws.com/%s/%s"  # (ACCOUNT_ID, QUEUE_NAME)
...
# queue_name = "app-interchange-%s-sqs-%s" % (client.lower(), env_type)
queue_name = QUEUE_NAME % (env_type, client.lower())
...
response = sqs_client.receive_message(
    # QueueUrl=QUEUE_URL + client.lower() + "-sqs-" + env_type,
    QueueUrl=QUEUE_URL % (ACCOUNT_ID, queue_name),
    MaxNumberOfMessages=1,
    WaitTimeSeconds=10,
)
...
sqs_client.delete_message(
    # QueueUrl=QUEUE_URL + client.lower() + "-sqs-" + env_type,
    QueueUrl=QUEUE_URL % (ACCOUNT_ID, queue_name),
    ReceiptHandle=receipt_handle,
)
...
```

> Ver archivo con los cambios [aquí](src/orchestrator.py)

#### archivo /home/ec2-user/interchange/Module/Persistence/connection.py

- Se quitó el uso a aws_access_key_id y aws_secret_key, para los clientes de boto 3, esto para que se utilicen los
  permisos otorgados via Instance Profile

> Ver archivo con los cambios [aquí](src/persistence_connection.py)