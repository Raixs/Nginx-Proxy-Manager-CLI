# Nginx Proxy Manager CLI

## Descripción

Este proyecto es una interfaz de línea de comandos (CLI) para gestionar el Nginx Proxy Manager. Está diseñado para facilitar la interacción con el Nginx Proxy Manager a través de comandos simples ejecutados desde la terminal. Actualmente se encuentra en una etapa temprana de desarrollo y utiliza una API no documentada del Nginx Proxy Manager, por lo que aunque es funcional, se deben esperar cambios y posibles mejoras.

## Estado del Proyecto

Este proyecto está en su fase inicial. Estamos trabajando para añadir más características y mejorar la estabilidad y seguridad del CLI. Es importante tener en cuenta que, dado que la API de Nginx Proxy Manager no está documentada, este CLI podría dejar de funcionar si la API cambia en futuras actualizaciones.

## Instalación

Para utilizar este CLI, necesitas tener instalado `bash`, `curl`, `jq`, y `yq`. Estas herramientas son necesarias para ejecutar los scripts y manejar la entrada/salida de datos en formato JSON y YAML.

### Dependencias

-   Bash
-   Curl
-   jq (Para procesamiento de JSON)
-   yq (Para salida en formato YAML)

Puedes instalar `jq` y `yq` en sistemas basados en Debian/Ubuntu usando:

`sudo apt-get install jq

sudo snap install yq` 

## Uso

Para utilizar el CLI, debes proporcionar las credenciales de usuario (nombre de usuario y contraseña) para obtener un token de acceso. A continuación se muestran los comandos disponibles y cómo utilizarlos.

### Comandos Disponibles

-   `list-proxies`: Lista todos los hosts proxy.
-   `get-proxy`: Obtiene detalles de un host proxy específico.
-   `create-proxy`: Crea un nuevo host proxy.
-   `update-proxy`: Actualiza un host proxy existente.
-   `delete-proxy`: Elimina un host proxy.

### Sintaxis General

`./nombre_del_script.sh [-u BASE_URL] [-U USERNAME] [-P PASSWORD] COMMAND [OPTIONS]` 

### Ejemplos de Uso

1.  **Listar todos los proxies en formato tabla**
    
    `./nombre_del_script.sh -U miUsuario -P miContraseña list-proxies -o table` 
    
2.  **Obtener detalles de un proxy específico en formato YAML**
    
    `./nombre_del_script.sh -U miUsuario -P miContraseña get-proxy 123 -o yaml` 
    
3.  **Crear un nuevo proxy desde un archivo JSON**
    
    `./nombre_del_script.sh -U miUsuario -P miContraseña create-proxy nuevo_proxy.json` 
    
4.  **Actualizar un proxy existente desde un archivo JSON**
    
    `./nombre_del_script.sh -U miUsuario -P miContraseña update-proxy 123 actualizacion_proxy.json` 
    
5.  **Eliminar un proxy**
    
    `./nombre_del_script.sh -U miUsuario -P miContraseña delete-proxy 123` 
    

## Contribuciones

Las contribuciones son bienvenidas, especialmente para expandir la funcionalidad o mejorar la robustez del CLI. Por favor, envía tus pull requests o abre un issue si encuentras un bug o tienes una sugerencia.
