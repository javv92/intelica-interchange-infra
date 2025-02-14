## Secrets

### Secret database

En el módulo database se crea el secreto `secret-database-app`, en el cual hay que almacenar la siguiente información

```json
{
  "username": "<APP_USERNAME>",
  "password": "<APP_PASSWORD>",
  "engine": "postgres",
  "host": "<host>",
  "port": 5432
}
```

### Secret SMTP

En el módulo smtp se crea el secreto `secret-smtp-app`, en el cual hay que almacenar la siguiente información

```json
{
  "email_user": "<APP_USERNAME>",
  "email_password": "<APP_PASSWORD>",
  "server_smtp": "smtp.office365.com",
  "server_port": "587"
}
```

## Applications

### EC2 Instance

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

#### Notification

Se ejecuta con el siguiente script `./interchange/Build/SH/Notification.sh`, el cual contiene

```shell
#!/usr/bin/env bash
source ~/interchange/interchange_env/bin/activate
python -u ~/interchange/Module/Notification/Notification.py
```

##### Configuración

La configuración se encuentra en el archivo ~/interchange/.env. Las variables utilizadas por el script de notificación
son los siguientes:
- USER_NOTIFICATION_AWS_KEY
- USER_NOTIFICATION_AWS_ACCESS_KEY
- SECRET_RDS
- REGION_NAME
- SEND_MAIN_LAMBDA_NAME # gregado

##### Errores
1.- el eejcutar el script `./interchange/Build/SH/Notification.sh` se obtenía el siguiente error
```shell
SCRAM authentication requires libpq version 10 or above
```
para solucionarlo se instaló pip3 y se instaló la librerpia `psycopg2-binary`

```shell
source ~/interchange/interchange_env/bin/activate
pip install psycopg2-binary -U
```