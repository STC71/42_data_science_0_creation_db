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

Debemos poder conectarnos con este comando (según el subject):

```bash
psql -U «tu_login» -d piscineds -h localhost -W
```

Cuando pida la contraseña, escribes: `mysecretpassword`

---

## 📁 Archivos a entregar

Dentro de la carpeta `ex00/` debes entregar **uno** de estos archivos:

- `docker-compose.yml`  ← **recomendado**
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
  postgres:                                 # "postgres" es el nombre que le damos a nuestro servicio.
    image: postgres:15                        # descargamos la versión exacta número 15 del sistema
                                              # de base de datos PostgreSQL.
    container_name: postgres_piscineds        # alias o nombre propio que llevará este contenedor.
    environment:                              # Variables de entorno (credenciales)
      POSTGRES_USER: ${POSTGRES_USER}           # ← ¡Cambia esto por tu login real!
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}   # ← mysecretpassword
      POSTGRES_DB: ${POSTGRES_DB}               # ← piscineds
    ports:
      - "5432:5432"                             # "PuertoDeTuEquipo : PuertoDentroDelContenedor".
    volumes:
      - postgres_data:/var/lib/postgresql/data  # enlaza una carpeta de tu máquina real llamada 
                                                # 'postgres_data' con la carpeta interna del contenedor 
                                                # donde se guardan los datos reales.
    restart: unless-stopped                     # regla de supervivencia del contenedor.

volumes:
  postgres_data:                          # "Separa permanentemente un bloque de memoria con este nombre".
```

> Se ha eliminado la línea `version: '3.8'` porque es obsoleta en las versiones modernas de Docker Compose.

---

### 🔐 ¿Es necesario usar un archivo `.env`?

No es obligatorio, pero **sí es muy recomendable**.

El subject indica que si usas Docker debes seguir las buenas prácticas del proyecto **Inception**.  
Una de esas buenas prácticas es **no hardcodear las credenciales** en el `docker-compose.yml`.

#### Cómo crear el archivo `.env` automáticamente

Desde la carpeta `ex00/` ejecuta:

```bash
echo "POSTGRES_USER=$(id -un)
POSTGRES_PASSWORD=mysecretpassword
POSTGRES_DB=piscineds" > .env
```

Comprueba el contenido:

```bash
cat .env
```

Si fuese necesario: añade el archivo a `.gitignore` para no subirlo a ningún repositorio:

```bash
echo ".env" >> .gitignore
```

---

### Paso 2: Arrancar el servicio

```bash
docker-compose up -d
```

### Paso 3: Comprobar que el contenedor está vivo

```bash
docker ps
```

Debes ver el contenedor `postgres_piscineds` en estado **Up**.

---

## 🔌 Cómo conectarse a la base de datos

### 1. Forma oficial del subject (cuando tienes `psql` instalado en el host)

```bash
psql -U $(whoami) -d piscineds -h localhost -W
```

> `$(whoami)` obtiene automáticamente el usuario del sistema.

Adelanta al punto 3 (opciones avanzadas) para más información

---

### 2. Forma recomendada y más sencilla (usando Docker)

En la mayoría de los ordenadores del campus **no está instalado** el cliente `psql`.  
La imagen oficial `postgres:15` **ya trae el comando `psql` instalado**, por eso la forma más limpia y fiable es:

```bash
docker exec -it postgres_piscineds psql -U $(whoami) -d piscineds -W
```

---

#### ¿Qué significa cada parte?

| Parte                              | Significado |
|------------------------------------|-----------|
| `docker exec`                      | Ejecuta un comando **dentro** de un contenedor que ya está corriendo |
| `-it`                              | Modo interactivo + terminal |
| `postgres_piscineds`               | Nombre del contenedor |
| `psql -U $(whoami) -d piscineds`   | Entra a PostgreSQL con tu usuario y la base de datos |
| `-W`                               | Fuerza a que pida la contraseña |

#### ¿Por qué a veces no pide la contraseña?

Cuando usas `docker exec`, el comando se ejecuta **dentro del contenedor**.  
Dentro del contenedor PostgreSQL está configurado con autenticación `trust` para conexiones locales, por eso no siempre pide contraseña.  

Esto es normal. La contraseña `mysecretpassword` sigue existiendo y se usa cuando te conectas desde fuera del contenedor.

---

### 3. Opción avanzada: Instalar `psql` en el host sin `sudo` (opcional)

Si quieres tener el comando `psql` disponible fuera del contenedor:

```bash
CURRENT_DIR=$(pwd)

mkdir -p ~/goinfre/bin
cd /tmp
wget https://github.com/IxDay/psql/releases/download/15.10.0/psql-x86-linux-static.tar.gz
tar -xzf psql-x86-linux-static.tar.gz
cp psql ~/goinfre/bin/
echo 'export PATH="$HOME/goinfre/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

cd "$CURRENT_DIR"
```

Después de esto ya podrás usar el comando oficial del subject desde cualquier lugar.

---

## Alias recomendado (muy útil)

Un **alias** es un atajo para no tener que escribir un comando largo cada vez.

Crea el alias con este comando:

```bash
echo 'alias pspiscine="docker exec -it postgres_piscineds psql -U \$(whoami) -d piscineds -W"' >> ~/.zshrc
source ~/.zshrc
```

A partir de ahora solo tienes que escribir:

```bash
pspiscine
```

---

## Comandos útiles de Docker

```bash
# Arrancar el servicio
docker-compose up -d

# Ver si el contenedor está corriendo
docker ps

# Ver los logs
docker logs postgres_piscineds

# Ver los logs en tiempo real
docker logs -f postgres_piscineds

# Ver solo las últimas 20 líneas
docker logs --tail 20 postgres_piscineds

# Parar el servicio (los datos se conservan)
docker-compose down

# Parar el servicio y borrar TODOS los datos (¡cuidado!)
docker-compose down -v
```

---

## 📝 Alternativas (si no quieres usar Docker)

- **`setup.sh`**: script que instala y configura PostgreSQL nativamente.
- **`VM-instructions.txt`**: instrucciones para instalar PostgreSQL dentro de una máquina virtual.

---

## ✅ Cómo saber que lo has hecho bien

- El contenedor aparece en `docker ps`.
- Puedes entrar a la base de datos con `docker exec` o con el comando oficial del subject.
- El usuario, la contraseña y el nombre de la BD son exactamente los que pide el subject.
- El archivo `docker-compose.yml` está limpio (sin la línea `version` obsoleta).

---

## 🔗 Navegación

- [← README principal](../README.md)
- [Siguiente ejercicio: ex01 →](../ex01/README.md)

---

*Piscine Data Science – sternero – 42 Málaga – Septiembre de 2026*
