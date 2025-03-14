# Intelica Intercambio

Esta infraestructura despliega una solución completa para el procesamiento de archivos y datos

La arquitectura consta de:

- Servidor SFTP para la recepción de archivos
- Sistema de colas para el procesamiento de mensajes
- Cluster de base de datos en RDS
- Instancia EC2 para procesamiento
- Funciones Lambda para diferentes propósitos
- Cluster de OpenSearch para búsqueda y análisis
- Sistema de almacenamiento en S3
- Configuración SMTP para envío de correos

  ![diagrama.png](assets/diagrama.png)

## Módulos

| Módulo                                       | Descripción                                                                        |
|----------------------------------------------|------------------------------------------------------------------------------------|
| [Base](modules/base)                         | Crea recursos compartidos como llaves KMS utilizadas por otros módulos             |
| [Storage](modules/storage)                   | Gestiona los buckets S3 para diferentes propósitos (landing, enriched, logs, etc.) |
| [SFTP](modules/sftp)                         | Configura un servidor SFTP seguro con acceso a S3                                  |
| [SFTP-NLB](modules/sftp-nlb)                 | Configura un Network Load Balancer para el acceso al servidor SFTP                 |
| [Main Queue](modules/main-queue)             | Configura las colas SQS para diferentes tipos de mensajes                          |
| [Database](modules/database)                 | Gestiona el cluster de base de datos RDS                                           |
| [Main Lambda](modules/main-lambda)           | Configura funciones Lambda para el procesamiento principal                         |
| [Fileload Lambda](modules/fileload-lambda)   | Lambda específica para la carga de archivos                                        |
| [EC2 Instance](modules/ec2-instance)         | Configura una instancia EC2 para procesamiento                                     |
| [SMTP](modules/smtp)                         | Configura recursos para el envío de correos                                        |
| [Send Mail Lambda](modules/send-mail-lambda) | Lambda para el envío de correos electrónicos                                       |
| [OpenSearch](modules/opensearch)             | Configura un dominio de OpenSearch                                                 |

### Dependencias del Módulo

```mermaid
flowchart TD
    Base[base] -->|key_arn| S[storage]
    Base -->|key_arn| MQ[main-queue]
    Base -->|key_arn| DB[database]
    Base -->|key_arn| SMTP[smtp]
    Base -->|key_arn| OS[opensearch]
    S -->|bucket_arn| SFTP[sftp]
    S -->|bucket_arn| ML[main-lambda]
    S -->|bucket_arn| EC2[instance]
    SFTP -->|server_id| FL[fileload-lambda]
    SFTP -->|server_ips| NLB[sftp-nlb]
    DB -->|secret_arn| FL
    DB -->|secret_arn| EC2
    MQ -->|queue_arn| ML
    MQ -->|queue_arn| EC2
    SMTP -->|secret_arn| SML[sendmail-lambda]
    SML -->|function_arn| EC2
    classDef storage fill: #f9f, stroke: #333, stroke-width: 2px
    classDef compute fill: #bbf, stroke: #333, stroke-width: 2px
    classDef database fill: #bfb, stroke: #333, stroke-width: 2px
    classDef network fill: #fbb, stroke: #333, stroke-width: 2px
    class Base,S,MQ storage
    class ML,FL,EC2,SML compute
    class DB,OS database
    class SFTP,NLB,SMTP network
```

## Variables

### Variables de Entorno

##### `global_tags`

- **Descripción**: Mapa de etiquetas globales que se aplicarán a los recursos.
- **Tipo**: `map(string)`
- **Valor por defecto**: `{}`

##### `stack_number`

- **Descripción**: Usado para evitar conflictos al desplegar varias instancias de esta infraestructura con el mismo
  nombre.
- **Tipo**: `string`
- **Valor por defecto**: `"00"`
- **Validación**:
    - Debe ser un número de dos dígitos (00 al 99)
    - Mensaje de error: "Stack Number solo permite valores de 00 al 99."

##### `prefix_resource_name`

- **Descripción**: Prefijo requerido para nombrar los recursos en el formato `{coid}-{assetid}-{appid}` o similar.
- **Tipo**: `string`
- **Valor por defecto**: `"aply-0001-gen-all"`
- **Validación**:
    - Debe contener solo letras minúsculas, números y guiones (`-`)

### Variables de Red

##### `vpc_id`

- **Descripción**: ID de la VPC donde se desplegarán los recursos.
- **Tipo**: `string`

##### `public_subnet_ids`

- **Descripción**: Lista de IDs de subredes públicas.
- **Tipo**: `list(string)`

##### `private_subnet_ids`

- **Descripción**: Lista de IDs de subredes privadas.
- **Tipo**: `list(string)`

##### `restricted_subnet_ids`

- **Descripción**: Lista de IDs de subredes restringidas.
- **Tipo**: `list(string)`

### Variables de SFTP

##### `sftp`

- **Descripción**: Configuración del servidor SFTP.
- **Tipo**: `object`
- **Atributos**:
    - **`enabled`**:
        - **Tipo**: `bool`
        - **Valor por defecto**: `true`
        - **Descripción**: Habilita o deshabilita el despliegue del servidor SFTP
    - **`subnet`**:
        - **Tipo**: `string`
        - **Descripción**: ID de la subred para el servidor SFTP
    - **`certificate_arn`**:
        - **Tipo**: `string`
        - **Valor por defecto**: `null`
        - **Descripción**: ARN del certificado SSL
    - **`custom_host_name`**:
        - **Tipo**: `string`
        - **Valor por defecto**: `null`
        - **Descripción**: Nombre de host personalizado
    - **`hosted_zone_id`**:
        - **Tipo**: `string`
        - **Valor por defecto**: `null`
        - **Descripción**: ID de la zona DNS
    - **`allowed_cidr`**:
        - **Tipo**: `map(string)`
        - **Valor por defecto**: `{}`
        - **Descripción**: Mapa de CIDRs permitidos
    - **`allowed_security_group`**:
        - **Tipo**: `map(string)`
        - **Valor por defecto**: `{}`
        - **Descripción**: Mapa de security groups permitidos

##### `sftp_nlb`

- **Descripción**: Configuración del Network Load Balancer para SFTP.
- **Tipo**: `object`
- **Atributos**:
    - **`enabled`**:
        - **Tipo**: `bool`
        - **Valor por defecto**: `true`
        - **Descripción**: Habilita o deshabilita el despliegue del NLB
    - **`certificate_arn`**:
        - **Tipo**: `string`
        - **Valor por defecto**: `null`
        - **Descripción**: ARN del certificado SSL
    - **`custom_host_name`**:
        - **Tipo**: `string`
        - **Valor por defecto**: `null`
        - **Descripción**: Nombre de host personalizado
    - **`hosted_zone_id`**:
        - **Tipo**: `string`
        - **Valor por defecto**: `null`
        - **Descripción**: ID de la zona DNS
    - **`allowed_cidr`**:
        - **Tipo**: `map(string)`
        - **Valor por defecto**: `{}`
        - **Descripción**: Mapa de CIDRs permitidos
    - **`allowed_security_group`**:
        - **Tipo**: `map(string)`
        - **Valor por defecto**: `{}`
        - **Descripción**: Mapa de security groups permitidos

### Variables de Base de Datos

##### `database`

- **Descripción**: Configuración de la base de datos.
- **Tipo**: `object`
- **Atributos**:
    - **`snapshot_identifier`**:
        - **Tipo**: `string`
        - **Descripción**: Identificador del snapshot para restaurar la base de datos
    - **`allowed_cidr`**:
        - **Tipo**: `map(string)`
        - **Valor por defecto**: `{}`
        - **Descripción**: Mapa de CIDRs permitidos para acceder a la base de datos
    - **`allowed_security_group`**:
        - **Tipo**: `map(string)`
        - **Valor por defecto**: `{}`
        - **Descripción**: Mapa de security groups permitidos para acceder a la base de datos

### Variables de Instancia EC2

##### `instance`

- **Descripción**: Configuración de la instancia EC2.
- **Tipo**: `object`
- **Atributos**:
    - **`ami`**:
        - **Tipo**: `string`
        - **Descripción**: ID de la AMI a utilizar
    - **`instance_type`**:
        - **Tipo**: `string`
        - **Descripción**: Tipo de instancia
    - **`key_pair`**:
        - **Tipo**: `string`
        - **Valor por defecto**: `null`
        - **Descripción**: Nombre del key pair
    - **`allowed_cidr`**:
        - **Tipo**: `object`
        - **Valor por defecto**: `{}`
        - **Descripción**: Objeto con CIDRs permitidos
        - **Atributos**:
            - **`all_traffic`**:
                - **Tipo**: `map(string)`
                - **Valor por defecto**: `{}`
                - **Descripción**: CIDRs permitidos para todo el tráfico
            - **`ssh`**:
                - **Tipo**: `map(string)`
                - **Valor por defecto**: `{}`
                - **Descripción**: CIDRs permitidos para SSH
    - **`allowed_security_group`**:
        - **Tipo**: `object`
        - **Valor por defecto**: `{}`
        - **Descripción**: Objeto con security groups permitidos
        - **Atributos**:
            - **`all_traffic`**:
                - **Tipo**: `map(string)`
                - **Valor por defecto**: `{}`
                - **Descripción**: Security groups permitidos para todo el tráfico
            - **`ssh`**:
                - **Tipo**: `map(string)`
                - **Valor por defecto**: `{}`
                - **Descripción**: Security groups permitidos para SSH

### Variables de OpenSearch

##### `opensearch`

- **Descripción**: Configuración del dominio OpenSearch.
- **Tipo**: `object`
- **Atributos**:
    - **`engine_version`**:
        - **Tipo**: `string`
        - **Valor por defecto**: `"OpenSearch_2.3"`
        - **Descripción**: Versión del motor
    - **`instance_type`**:
        - **Tipo**: `string`
        - **Valor por defecto**: `"t3.small.search"`
        - **Descripción**: Tipo de instancia
    - **`storage_size`**:
        - **Tipo**: `number`
        - **Valor por defecto**: `100`
        - **Descripción**: Tamaño de almacenamiento en GB
    - **`instance_count`**:
        - **Tipo**: `number`
        - **Valor por defecto**: `1`
        - **Descripción**: Número de instancias

## Ejemplo

```hcl
global_tags = {
  coid    = "example"
  assetid = "0001"
  appid   = "data"
  env     = "dev"
}
stack_number         = "01"
prefix_resource_name = "example-0001-data-dev"

vpc_id = "vpc-0123456789abcdef0"
private_subnet_ids = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
public_subnet_ids = ["subnet-0123456789abcdef2", "subnet-0123456789abcdef3"]
restricted_subnet_ids = ["subnet-0123456789abcdef4", "subnet-0123456789abcdef5"]

sftp = {
  enabled           = true
  subnet           = "subnet-0123456789abcdef0"
  certificate_arn  = "arn:aws:acm:region:account:certificate/12345678-1234-1234-1234-123456789012"
  custom_host_name = "sftp.example.com"
  hosted_zone_id   = "Z1234567890ABCDEF"
  allowed_cidr = { office = "10.0.0.0/16" }
}

sftp_nlb = {
  enabled           = true
  certificate_arn  = "arn:aws:acm:region:account:certificate/12345678-1234-1234-1234-123456789012"
  custom_host_name = "sftp-nlb.example.com"
  hosted_zone_id   = "Z1234567890ABCDEF"
}

database = {
  snapshot_identifier = "arn:aws:rds:region:account:cluster-snapshot:example-snapshot"
  allowed_cidr = { office = "10.0.0.0/16" }
  allowed_security_group = { app_servers = "sg-0123456789abcdef0" }
}

instance = {
  ami           = "ami-0123456789abcdef0"
  instance_type = "t3.medium"
  key_pair      = "example-key"
  allowed_cidr = {
    all_traffic = { office = "10.0.0.0/16" }
    ssh = { vpn = "172.16.0.0/16" }
  }
}

opensearch = {
  engine_version = "OpenSearch_2.3"
  instance_type  = "t3.medium.search"
  storage_size   = 200
  instance_count = 2
}
```

## Procedimientos

### Agregar cola de cliente
#### Creación de cola y captura de salidas
1. Las colas de clientes se crean en el módulo [Main Queue](modules/main-queue), archivo [modules/main-queue/main.tf](modules/main-queue/main.tf), para agregar una nueva cola de cliente
   con las configuración por defecto se debe crea un nuevo módulo como el siguiente:
    ```hcl
   #...
    module "<COD_CLIENTE>" {
        source = "git@github.com:ITL-ORG-INFRA/intelica-module-sqs//queue"
        
        name                 = "${var.name}-<COD_CLIENTE>"
        stack_number         = var.stack_number
        prefix_resource_name = var.prefix_resource_name
        kms_key_arn          = var.kms_key_arn
        fifo                 = false
    }
   #...
    ```
2. Configurar la salida del módulo [Main Queue](modules/main-queue), archivo [modules/main-queue/outputs.tf](modules/main-queue/outputs.tf), para poder utilizar sus datos (arn y kms, entre otros), por ejemplo
    ```hcl
    #...
    output "<COD_CLIENTE>_queue_arn" {
      value = module.<COD_CLIENTE>.queue_arn
    }
    output "<COD_CLIENTE>_queue_name" {
      value = module.<COD_CLIENTE>.queue_name
    }
    output "<COD_CLIENTE>_queue_id" {
      value = module.<COD_CLIENTE>.queue_id
    }
    output "<COD_CLIENTE>_kms_key_arn" {
      value = module.<COD_CLIENTE>.kms_key_arn
    }
    output "<COD_CLIENTE>_queue_url" {
      value = module.<COD_CLIENTE>.queue_url
    }
    #...
    ```
3. Desplegar con `terraform apply` y se crearán las colas SQS

#### Configuración de Lambda de captura de eventos de S3 y notificaciones a las colas

1. Actualizar los parámetros del módulo [Main Lambda](modules/main-lambda), archivo [main.tf](main.tf), para indicarle que tome fuente de eventos
   las colas, y pueda leer y procesar los mensajes de la nueva cola, para esto se utiliza la variable `targets.queues`, por ejemplo:
   ```hcl 
    module "main_lambda" {
        source = "./modules/main-lambda"
        
        stack_number         = var.stack_number
        prefix_resource_name = var.prefix_resource_name
        name                 = "app"    
        #...
        targets = {
            queues = {
                "<COD_CLIENTE>" = { # este nombre es importante, ya que debe coincidir con la carpeta en donde se almacena el archivo, la función lambda toma la primera carpeta en donde está el archivo para identificar la cola a enviar el mensaje
                    arn         = module.main_queue.<COD_CLIENTE>_queue_arn
                    kms_key_arn = module.main_queue.<COD_CLIENTE>_kms_key_arn
                }
            }
        }
    }
   #...
    ``` 
2. Desplegar con `terraform apply` y se realizará lo siguiente:
    * Se actualizarán los permisos para que la función lambda pueda enviar mensajes a la cola SQS, permisos de SQS y
      KMS en caso se indique
    * Se configurará la información necesaria para que la función lambda utilice la cola se configura
      automáticamente en las
      variables de entorno
        * `QUEUES_URL_MAP`, que tiene el siguiente formato
           ```json
           {"<COD_CLIENTE>":"<COLA_CLIENTE_URL>"}  
           ```
#### Configuración de Instancia EC2 para que lea mensajes de la cola y los procese

1. Actualizar los parámetros del módulo [Instance](modules/ec2-instance), archivo [main.tf](main.tf), para indicarle que tome como fuente de eventos
   las colas, y pueda leer y procesar los mensajes de la nueva cola, para esto se utiliza la variable `queues`, por ejemplo:
   ```hcl 
    module "instance" {
      source               = "./modules/ec2-instance"
      stack_number         = var.stack_number
      prefix_resource_name = var.prefix_resource_name
      name                 = "app"
      #...
      queues = {
          "<COD_CLIENTE>" = {
              arn         = module.main_queue.<COD_CLIENTE>_queue_arn
              kms_key_arn = module.main_queue.<COD_CLIENTE>_kms_key_arn
          }
      }
      #...
    }
   ```
2. Desplegar con `terraform apply` y se realizará lo siguiente:
    * Se actualizarán los permisos para que la instancia pueda recibir y eliminar mensajes a la cola SQS, permisos de SQS y
      KMS en caso se indique