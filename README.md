## Configuración aplicación

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