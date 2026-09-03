# 🛠️ Ejercicio 00 – Create Postgres DB

<p align="center">
  <img src="../imgs/banner_00.jpg" alt="Piscine Data Science – Module 0 – ex00" width="100%">
</p>

[← Volver al README principal](../README.md)

---

## 🎯 ¿Qué se pide exactamente?

Crear una base de datos **PostgreSQL** lista para usar, con los siguientes datos obligatorios:

| Parámetro          | Valor obligatorio          |
|--------------------|----------------------------|
| **Usuario**        | Tu login de estudiante     |
| **Nombre de la BD**| `piscineds`                |
| **Contraseña**     | `mysecretpassword`         |

Debemos poder conectarnos con este comando (según el subject, pero no la más apropiada):

```bash
psql -U «tu_login» -d piscineds -h localhost -W
```

Cuando pida la contraseña, escribes: `mysecretpassword`

---

## 📁 Archivos a entregar

Dentro de la carpeta `ex00/` debes entregar **uno** de estos archivos:

- `docker-compose.yml`    ← **recomendado**
- o `setup.sh`
- o `VM-instructions.txt`

---

## 🧠 Explicación sencilla

Imagina que PostgreSQL es un **almacén grande y profesional**.  
Docker es como una **caja mágica** que contiene ese almacén ya montado y listo para usar.  

En vez de instalar PostgreSQL a mano (que puede ser complicado y diferente en cada ordenador), usamos Docker para que **todo el mundo tenga exactamente el mismo entorno**.

---

## 🚀 Cómo implementarlo paso a paso (opción recomendada: Docker)

### Paso 1: Crear el archivo `docker-compose.yml`

Abre un editor de texto y crea el archivo `ex00/docker-compose.yml` con este contenido:

```yaml
services:                                 # lista de todos los elementos o "servicios".
  postgres:                               # "postgres" es el nombre que le damos a nuestro servicio.
    image: postgres:15                    # descargamos la versión exacta número 15 del sistema
                                          # de base de datos PostgreSQL.
    container_name: postgres_piscineds    # alias o nombre propio que llevará este contenedor.
    environment:                          # Ajustes del Entorno (credenciales)
      POSTGRES_USER: ${POSTGRES_USER}     # ← ¡Cambia esto por tu login real!
      POSTGRES_PASSWORD: ${POSTGRES_USER} # ← mysecretpassword
      POSTGRES_DB: ${POSTGRES_DB}         # ← piscineds
    ports:
      - "5432:5432"                             # "PuertoDeTuEquipo : PuertoDentroDelContenedor".
    volumes:
      - postgres_data:/var/lib/postgresql/data  # enlaza una carpeta de tu máquina real llamada 
                                                # 'postgres_data' con la carpeta interna del contenedor 
                                                # donde se guardan los datos reales.
    restart: unless-stopped               # regla de supervivencia del contenedor.

volumes:
  postgres_data:                          # "Separa permanentemente un bloque de memoria con este nombre".
```

**Importante:** sustituye `«tu_login»` por tu login real de 42 (ejemplo: `sternero`).

> Se ha eliminado la línea `version: '3.8'` porque es obsoleta en las versiones modernas de Docker Compose.

### 🔐 ¿Es necesario usar un archivo `.env`?

No es obligatorio para superar este ejercicio, pero sí es **muy recomendable** para mantener las credenciales separadas de la configuración de Docker.

#### ¿Qué nos piden realmente?

En este módulo (`ex00`) **no se exige explícitamente** el uso de un archivo `.env`. Sin embargo, se nos indica que:

> *If you choose to use Docker, your setup must follow the same standards and good practices as required in the Inception project.*

Por eso conviene aplicar la misma buena práctica que en Inception: **evitar escribir las credenciales directamente en `docker-compose.yml`**.

#### Recomendación práctica

| Opción | ¿Es válida? | ¿Recomendada? | Comentario |
|---|:---:|:---:|---|
| Escribir las credenciales directamente en `docker-compose.yml` | ✅ | ⚠️ Aceptable | Cumple el subject, pero deja la contraseña visible en el archivo de configuración. |
| Usar un archivo `.env` | ✅ | ⭐ Sí | Es más profesional y sigue las buenas prácticas de Inception. |

Con `.env`, el `docker-compose.yml` queda sin credenciales expuestas:

```yaml
environment:
  POSTGRES_USER: ${POSTGRES_USER}
  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
  POSTGRES_DB: ${POSTGRES_DB}
```

Crea **manualmente** un archivo `.env` en la misma carpeta:

```dotenv
POSTGRES_USER=tu_login
POSTGRES_PASSWORD=mysecretpassword
POSTGRES_DB=piscineds
```

¡O MEJOR AÚN! ... puedes generar el archivo **automáticamente** usando el login de tu sistema, ejecuta
este comando en la terminal desde la carpeta `ex00/`:

```bash
echo "POSTGRES_USER=$(id -un)
POSTGRES_PASSWORD=mysecretpassword
POSTGRES_DB=piscineds" > .env
```

El comando crea o reemplaza `.env`, y `id -un` obtiene el usuario con el que has
iniciado sesión. Puedes comprobar el resultado con:

```bash
cat .env
```

> ⚠️ Añade `.env` a `.gitignore` para evitar subir credenciales reales.

```bash
echo ".env" >> .gitignore
```

### ✅ Conclusión

| Objetivo | Decisión recomendada |
|---|---|
| 📋 **Solo cumplir** | No necesitas crear un archivo `.env`. Las credenciales pueden estar directamente en `docker-compose.yml`. |
| 🧼 **Trabajo limpio y profesional** | **Sí, crea `.env`**. Mantendrás la configuración más ordenada y seguirás el espíritu de las buenas prácticas de Inception. |

> ⭐ **Recomendación:** utiliza `.env` y mantenlo fuera de Git. No es obligatorio, pero es la opción más clara, segura y profesional.

### Paso 2: Arrancar el servicio

Abre una terminal en la carpeta `ex00/` y ejecuta:

```bash
docker-compose up -d
```

- `docker-compose` → lee el archivo de configuración
- `up` → construye y levanta el servicio
- `-d` → lo deja corriendo en segundo plano (detached)

### Paso 3: Comprobar que el contenedor está vivo

```bash
docker ps
```

Debes ver algo similar a esto:

```
CONTAINER ID   IMAGE         ...   PORTS                                       NAMES
xxxxxxxxxxxx   postgres:15   ...   0.0.0.0:5432->5432/tcp                      postgres_piscineds
```

---

## 🔌 Cómo conectarse a la base de datos

### Forma oficial del subject (cuando tienes `psql` instalado)

```bash
psql -U «tu_login» -d piscineds -h localhost -W
```

--- 

### Forma mejorada (no hace falta instalar nada dentro del contenedor)

La imagen oficial `postgres:15` **ya trae el comando `psql` instalado**.  
Por eso este comando funciona perfectamente:

```bash
docker exec -it postgres_piscineds psql -U «tu_login» -d piscineds
```

---

#### ¿Qué pasa si intentas hacer `apt install` dentro del contenedor?

Puedes hacerlo, pero **no es recomendable** por estas razones:

- Los cambios se pierden cuando borras o recreas el contenedor.
- Estás modificando una imagen oficial (mala práctica).
- No ganas casi nada, porque `psql` ya está disponible.

Si aún así quieres probarlo (solo para experimentación):

```bash
# Entrar como root al contenedor
docker exec -it -u root postgres_piscineds bash

# Dentro del contenedor:
apt update
apt install -y postgresql-client

# Salir
exit
```

Pero RECUERDA: <br>
Cuando haces docker-compose down, solo se destruye el contenedor (la “caja”), pero el volumen (el “disco duro”) sigue existiendo.<br>
Al hacer up de nuevo, el nuevo contenedor se vuelve a conectar al mismo volumen y recupera todos los datos.<br>
A menos que hagas esto otro:
```bash
docker-compose down -v  # Esto para el contenedor y borra los volúmenes (💥 SE PERDERÍA TODO 💥)
```


### Forma recomendada y práctica (usando Docker)

En la mayoría de los ordenadores del campus **no está instalado el cliente `psql`**.  
Instalarlo requiere permisos de administrador (`sudo`), algo que no siempre está disponible o no es conveniente.

Por esa razón utilizamos el comando a través de Docker:

```bash
docker exec -it postgres_piscineds psql -U sternero -d piscineds
```

#### ¿Qué significa cada parte?

| Parte                        | Significado |
|-----------------------------|-----------|
| `docker exec`               | Ejecuta un comando **dentro** de un contenedor que ya está corriendo |
| `-it`                       | Modo interactivo + terminal (para poder escribir) |
| `postgres_piscineds`        | Nombre del contenedor |
| `psql -U sternero -d piscineds` | Entra a PostgreSQL con tu usuario y la base de datos |

#### ¿Por qué no me pide la contraseña?

Cuando usas `docker exec`, el comando `psql` se ejecuta **dentro del propio contenedor**.  
Dentro del contenedor, PostgreSQL está configurado por defecto con autenticación `trust` para las conexiones locales (desde el mismo contenedor).  

Por eso **no te pide contraseña**.  

Esto es completamente normal y seguro en este contexto.  
La contraseña `mysecretpassword` sigue existiendo y se usaría si te conectaras desde fuera del contenedor con el comando oficial del subject.

---

## Alias recomendado (muy útil)

### ¿Qué es un alias?

Un **alias** es simplemente un **apodo** o un **atajo** que le das a un comando largo.

Imagina que cada vez que quieres entrar a la base de datos tienes que escribir esto:

```bash
docker exec -it postgres_piscineds psql -U sternero -d piscineds
```

Es largo y fácil de equivocarte.  
Con un alias puedes crear un nombre corto (por ejemplo `pspiscine`) que haga exactamente lo mismo.

### Cómo crear el alias

Copia y pega este comando en tu terminal:

```bash
echo 'alias pspiscine="docker exec -it postgres_piscineds psql -U sternero -d piscineds"' >> ~/.zshrc
```

Luego recarga la configuración de tu terminal:

```bash
source ~/.zshrc
```

### ¿Qué ha pasado?

A partir de ahora, cada vez que escribas:

```bash
pspiscine
```

será exactamente igual que haber escrito el comando largo.  
Es como ponerle un botón rápido a una acción que haces muchas veces.

### Ejemplo práctico

**Antes** (comando largo):
```bash
docker exec -it postgres_piscineds psql -U sternero -d piscineds
```

**Después** (con el alias):
```bash
pspiscine
```

Ambos hacen exactamente lo mismo.

---

## Comandos útiles de Docker

```bash
# Ver si el contenedor está corriendo
docker ps

# Ver los logs del contenedor
docker logs postgres_piscineds

# Ver los logs en tiempo real
docker logs -f postgres_piscineds

# Ver solo las últimas 20 líneas de los logs
docker logs --tail 20 postgres_piscineds

# Parar el servicio
docker-compose down

# Parar el servicio y borrar TODOS los datos (💥 ¡cuidado! 💥)
docker-compose down -v
```

---

## 📝 Alternativas (si no quieres usar Docker)

### Opción A: `setup.sh`
Un script de bash que instale y configure PostgreSQL nativamente.

### Opción B: `VM-instructions.txt`
Un archivo de texto con las instrucciones exactas para instalar PostgreSQL dentro de una máquina virtual.

---

## ✅ Cómo saber que lo has hecho bien

- El contenedor aparece en `docker ps`.
- Puedes entrar a la base de datos con el comando `docker exec` (o con el `psql` oficial si lo tienes instalado).
- El usuario, la contraseña y el nombre de la BD son exactamente los que pide el subject.
- El archivo `docker-compose.yml` está limpio (sin la línea `version` obsoleta).

---

## El comando psql -U «tu_login» -d piscineds -h localhost -W 

- Sirve para **abrir una sesión** interactiva en una base de datos PostgreSQL utilizando la terminal. 
- Al ejecutarlo, dejas la línea de comandos habitual de tu sistema operativo y **entras directamente a la consola de PostgreSQL** para escribir consultas SQL (SELECT, INSERT, etc.).
- Las flags (los añadidos con guion) sirven para darle al programa las credenciales y la dirección exacta a la que debe dirigirse.
- A continuación tienes el desglose completo de qué hace, para qué sirve y qué ocurre si omites cada una de ellas de forma individual:

**👤 -U «tu_login» (User / Usuario)**

- ¿Qué hace exactamente? Le dice a PostgreSQL que intente **iniciar sesión con el nombre de cuenta de usuario «tu_login»** (un marcador que debes cambiar por tu usuario real).Para qué sirve: Para el control de accesos y permisos. 
- El sistema necesita saber quién eres para **aplicar tus reglas de seguridad** (por ejemplo, saber si puedes borrar tablas o solo leerlas).
- ¿Qué ocurre si NO se introduce? psql intentará conectarse utilizando de forma automática el mismo nombre de usuario que tienes en la sesión de tu sistema operativo (tu usuario de Mac, Linux o Windows). Si ese nombre no coincide exactamente con un usuario registrado dentro de PostgreSQL, **el servidor rechazará la conexión** con un error de autenticación.

**🗄️ -d piscineds (Database / Base de datos)**

- ¿Qué hace exactamente? Indica que, una vez que logres entrar, te sitúe inmediatamente dentro de la base de datos llamada piscineds.
- ¿Para qué sirve? Para ahorrar tiempo e ir directo al grano. Un único servidor de PostgreSQL puede albergar decenas de bases de datos diferentes; esta flag te evita tener que buscar y cambiar de base de datos de forma manual una vez dentro.
- ¿Qué ocurre si NO se introduce? Por defecto, el programa intentará conectarse a una base de datos que se llame exactamente igual que tu nombre de usuario. Si esa base de datos por defecto no existe en el sistema, la terminal te lanzará un error y no te dejará iniciar la sesión.

**🌐 -h localhost (Host / Servidor)**

- ¿Qué hace exactamente? Especifica la **dirección de red donde está corriendo el servidor de PostgreSQL**. La palabra localhost es una dirección interna que significa **"este mismo equipo"**.
- ¿Para qué sirve? Para la **comunicación IP**. Le dice a la terminal que busque el servicio de base de datos de forma local **en tu máquina** en lugar de buscar un servidor externo en internet o en la nube.
- ¿Qué ocurre si NO se introduce? psql intentará conectarse mediante un método interno llamado sockets de dominio Unix (un canal de comunicación local del sistema operativo) en lugar de usar la red local (TCP/IP). En sistemas Mac o Linux esto suele funcionar bien si todo está en la misma máquina, pero en Windows o en ciertos entornos virtuales (como Docker o contenedores) suele fallar estrepitosamente dando un error de **"Conexión rechazada"**.

**🔑 -W (Password / Contraseña)**

- ¿Qué hace exactamente? Fuerza al programa a **pedirte la contraseña** de manera obligatoria en la pantalla antes de intentar la conexión.
- ¿Para qué sirve? Es una **medida de seguridad proactiva**. Te asegura que la terminal se detenga y te muestre el mensaje Contraseña para usuario «tu_login»: para que puedas teclearla. 
(Nota: cuando la escribas no verás letras ni asteriscos por privacidad; escríbela a ciegas y pulsa Enter).
- ¿Qué ocurre si NO se introduce? El programa intentará conectarse directamente. Si el servidor PostgreSQL requiere contraseña, te la va a pedir de todas formas de manera automática. Sin embargo, si el servidor está configurado en modo "confianza" (trust) o tienes tus credenciales guardadas en un archivo oculto de tu sistema (.pgpass), entrarás directamente sin que te pida teclear absolutamente nada.


## ¿Y si no uso las Flags?

Cuando no utilizas las flags (-U, -d, -h), psql interpreta tus palabras en un orden estricto y predeterminado basado en su manual de uso. 

El orden que espera psql cuando pones argumentos sueltos es:
- Primer argumento sin flag: El nombre de la Base de datos.
- Segundo argumento sin flag: El nombre del Usuario. Por lo tanto, si escribes psql «tu_login» piscineds localhost: psql pensará que quieres entrar a una base de datos llamada «tu_login». Pensará que tu nombre de usuario es piscineds.
- Tercer argumento (localhost) romperá el comando porque el sistema no sabrá qué hacer con él (te dará un error de sintaxis como "extra command-line argument").

## ¿Cómo SÍ se podría sustituir para escribir menos?

Si quieres evitar escribir las flags y acortar el comando al máximo, tienes dos opciones válidas:

- **Opción 1:** Respetar el orden nativo de psql (Sin flags) Si quitas las flags, debes poner primero la base de datos y luego el usuario.
<br> ⚠️ Usa el código con precaución. <br>
¿Por qué funciona? Al ver dos palabras, psql asume automáticamente que la primera (piscineds) es la base de datos y la segunda «tu_login» es el usuario.<br>
¿Y el host (-h) y la contraseña (-W)? <br> Al omitir el host, el sistema asumirá por defecto que te conectas a localhost. <br>Al omitir la -W, si el servidor requiere contraseña, te la pedirá automáticamente de todos modos.

```bash
psql piscineds «tu_login»
```

- **Opción 2:** Utilizar el formato de URI (El más moderno) <br>PostgreSQL permite conectarte usando una estructura similar a un enlace web (URL). Es una sola cadena de texto muy limpia 
<br>⚠️ Usa el código con precaución. <br>
¿Por qué funciona? Este formato (protocolo://usuario@servidor/base_de_datos) es estándar en desarrollo. El sistema descompone la URL automáticamente y sabe exactamente quién eres y a dónde vas, sin necesidad de usar guiones.

```bash
psql postgres://tu_login@localhost/piscineds
```
---


## 🔗 Navegación

- [← README principal](../README.md)
- [Siguiente ejercicio: ex01 →](../ex01/README.md)

---

*Piscine Data Science – sternero – 42 Málaga – Septiembre de 2026*
