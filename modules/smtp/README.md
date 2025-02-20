# Módulo SMTP

Este módulo crea un recurso de AWS Secrets Manager para almacenar credenciales SMTP de forma segura con cifrado KMS.

## Descripción General

El módulo implementa un secreto en AWS Secrets Manager con las siguientes características:

- Cifrado mediante una clave KMS personalizada

## Variables

#### `stack_number`

- **Descripción**: Identificador numérico para evitar conflictos en múltiples despliegues
- **Tipo**: `string`
- **Valor por defecto**: `"00"`
- **Validación**: Debe ser un número de dos dígitos (00 al 99)

#### `prefix_resource_name`

- **Descripción**: Prefijo para nombrar recursos en formato `{coid}-{assetid}-{appid}`
- **Tipo**: `string`
- **Valor por defecto**: `"aply-0001-gen-all"`
- **Validación**: Solo letras minúsculas, números y guiones

#### `name`

- **Descripción**: Identificador específico para el secreto SMTP
- **Tipo**: `string`
- **Requerido**: Sí

#### `kms_key_arn`

- **Descripción**: ARN de la clave KMS utilizada para cifrar el secreto
- **Tipo**: `string`
- **Requerido**: Sí

## Recursos Creados

El módulo crea el siguiente recurso:

1. **AWS Secrets Manager Secret**
    - Nombre generado con el formato: `{prefix_resource_name}-secret-smtp-{name}-{stack_number}`
    - Cifrado mediante la clave KMS especificada

## Ejemplo de Uso

```hcl
module "smtp_credentials" {
  source = "ruta/al/modulo"

  name                 = "mailserver-prod"
  stack_number         = "01"
  prefix_resource_name = "myapp-0001-mail-prod"

  kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/1234abcd-12ab-34cd-56ef-1234567890ab"
}
```