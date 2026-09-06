# 🛠️ Ejercicio 00 – Create Postgres DB

<p align="center">
  <img src="../imgs/banner_00.jpg" alt="Piscine Data Science – Module 0 – ex00" width="100%">
</p>

[← Volver al README principal](../README.md)

---

## 📑 Índice

1. [¿Qué se pide exactamente?](#-qué-se-pide-exactamente)
2. [Archivos a entregar](#-archivos-a-entregar)
3. [Explicación sencilla](#-explicación-sencilla)
4. [Scripts de este ejercicio](#-scripts-de-este-ejercicio)
5. [Cómo implementarlo paso a paso (Docker)](#-cómo-implementarlo-paso-a-paso-opción-recomendada-docker)
6. [Archivo `.env` y buenas prácticas](#-es-necesario-usar-un-archivo-env)
7. [Cómo conectarse a la base de datos](#-cómo-conectarse-a-la-base-de-datos)
8. [Alias recomendado](#alias-recomendado-muy-útil)
9. [Comandos útiles de Docker](#comandos-útiles-de-docker)
10. [Alternativas sin Docker](#-alternativas-si-no-quieres-usar-docker)
11. [Cómo saber que lo has hecho bien](#-cómo-saber-que-lo-has-hecho-bien)
12. [Navegación](#-navegación)

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

[↑ Volver al índice](#-índice)

---

## 📁 Archivos a entregar

Dentro de la carpeta `ex00/` debes entregar **uno** de estos archivos:

- `docker-compose.yml`  ← **recomendado**
- o `setup.sh`
- o `VM-instructions.txt`

En este repositorio también encontrarás un script de ayuda (opcional, pero muy útil en el campus 42):

| Archivo | Función |
|---------|---------|
| [`docker-compose.yml`](docker-compose.yml) | Define el servicio PostgreSQL 15 |
| [`start.sh`](start.sh) | Automatiza `.env`, arranque, comprobaciones y menú de conexión |

[↑ Volver al índice](#-índice)

---

## 🧠 Explicación sencilla

Imagina que PostgreSQL es un **almacén grande y profesional**.  
Docker es como una **caja mágica** que contiene ese almacén ya montado y listo para usar.  

En vez de instalar PostgreSQL a mano (que puede ser complicado y diferente en cada ordenador), usamos Docker para que **todo el mundo tenga exactamente el mismo entorno**.

[↑ Volver al índice](#-índice)

---

## 🧰 Scripts de este ejercicio

### `start.sh` — Asistente interactivo de EX00

Script pensado para el campus 42. Te guía paso a paso y evita errores típicos.

**Qué puede hacer:**

| Fase | Acción |
|------|--------|
| Gestión inicial | Apagar el contenedor (conservando datos) o limpieza completa (`down -v`) |
| Paso 1 | Crear / validar el archivo `.env` |
| Paso 1B | Proteger `.env` con `.gitignore` |
| Paso 2 | Instalar el cliente `psql` en el host **sin sudo** (opcional) |
| Paso 3 | Arrancar PostgreSQL con `docker-compose up -d` |
| Paso 4 | Verificar que el contenedor está corriendo |
| Menú final | Logs, conexión a la BD, arrancar/parar, recrear `.env`, etc. |

**Qué NO hace:**

- No usa `sudo`
- No borra datos sin confirmación explícita (`si` / opciones claras)
- No modifica EX01 ni pgAdmin
- No hardcodea tu login: usa `$(id -un)` / `$(whoami)`

**Cómo usarlo:**

```bash
cd ruta/a/ex00
chmod +x start.sh
./start.sh
```

🔗 También puedes llamar a **start.sh** desde el script con el mismo nombre presente en **ex01** que además arranca pgAdmin, lo que auna ambos procesos en uno solo. 🔗

**Menú final típico:**

```text
1) Confirmar que el contenedor está corriendo
2) Ver los logs completos del contenedor
3) Ver solo las últimas 20 líneas de los logs
4) Parar el servicio y borrar TODOS los datos (¡cuidado!)
5) Conectar con la base de datos
6) Arrancar el contenedor si está detenido
7) Añadir .env a .gitignore
8) Crear el archivo .env si falta
0) Salir
```

**Equivalentes manuales (sin el script):**

```bash
# Crear .env
echo "POSTGRES_USER=$(id -un)
POSTGRES_PASSWORD=mysecretpassword
POSTGRES_DB=piscineds" > .env

# Proteger .env
echo ".env" >> .gitignore

# Arrancar
docker-compose up -d

# Comprobar
docker ps

# Conectar (dentro del contenedor)
docker exec -it postgres_piscineds psql -U "$(whoami)" -d piscineds -W

# Conectar (si tienes psql en el host)
psql -U "$(whoami)" -d piscineds -h localhost -W
```

[↑ Volver al índice](#-índice)

---

## 🚀 Cómo implementarlo paso a paso (opción recomendada: Docker)

### Opción rápida (recomendada)

```bash
./start.sh
```

Sigue las preguntas en pantalla. Al final deberías poder conectar a `piscineds`.

### Opción manual

#### Paso 1: Crear el archivo `docker-compose.yml`

Abre un editor de texto y crea el archivo `ex00/docker-compose.yml` con este contenido:

```yaml
services:
  postgres:
    image: postgres:15
    container_name: postgres_piscineds
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  postgres_data:
```

> Se ha eliminado la línea `version: '3.8'` porque es obsoleta en las versiones modernas de Docker Compose.

El archivo del repositorio incluye comentarios didácticos línea a línea; la versión mínima válida es la de arriba.

[↑ Volver al índice](#-índice)

---

## 🔐 ¿Es necesario usar un archivo `.env`?

No es obligatorio, pero **sí es muy recomendable**.

El subject indica que si usas Docker debes seguir las buenas prácticas del proyecto **Inception**.  
Una de esas buenas prácticas es **no hardcodear las credenciales** en el `docker-compose.yml`.

### Cómo crear el archivo `.env` automáticamente

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

Añade el archivo a `.gitignore` para no subirlo al repositorio:

```bash
echo ".env" >> .gitignore
```

Con `start.sh`, estos pasos se ofrecen de forma interactiva (pasos 1 y 1B, y opciones 7 y 8 del menú).

[↑ Volver al índice](#-índice)

---

## 🔌 Cómo conectarse a la base de datos

### 1. Forma oficial del subject (cuando tienes `psql` instalado en el host)

```bash
psql -U $(whoami) -d piscineds -h localhost -W
```

> `$(whoami)` obtiene automáticamente el usuario del sistema.

---

### 2. Forma recomendada y más sencilla (usando Docker)

En la mayoría de los ordenadores del campus **no está instalado** el cliente `psql`.  
La imagen oficial `postgres:15` **ya trae el comando `psql` instalado**, por eso la forma más limpia y fiable es:

```bash
docker exec -it postgres_piscineds psql -U $(whoami) -d piscineds -W
```

#### ¿Qué significa cada parte?

| Parte | Significado |
|-------|-------------|
| `docker exec` | Ejecuta un comando **dentro** de un contenedor que ya está corriendo |
| `-it` | Modo interactivo + terminal |
| `postgres_piscineds` | Nombre del contenedor |
| `psql -U $(whoami) -d piscineds` | Entra a PostgreSQL con tu usuario y la base de datos |
| `-W` | Fuerza a que pida la contraseña |

#### ¿Por qué a veces no pide la contraseña?

- Cuando usas `docker exec`, el comando se ejecuta **dentro del contenedor**.  
- Dentro del contenedor PostgreSQL está configurado con autenticación `trust` para conexiones locales, por eso no siempre pide contraseña.
- Esto es normal. La contraseña `mysecretpassword` sigue existiendo y se usa cuando te conectas desde fuera del contenedor (comando oficial del subject o pgAdmin).
- Desde `start.sh`, la **opción 5** elige automáticamente host o contenedor según tengas `psql` instalado.

---

### 3. Opción avanzada: instalar `psql` en el host sin `sudo` (opcional)

Si quieres el comando oficial del subject fuera del contenedor:

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

Después podrás usar:

```bash
psql -U $(whoami) -d piscineds -h localhost -W
```

`start.sh` ofrece este mismo proceso en el **PASO 2** (solo si aún no tienes `psql`).

[↑ Volver al índice](#-índice)

---

## Alias recomendado (muy útil)

Un **alias** es un atajo para no escribir el comando largo cada vez.

```bash
echo 'alias pspiscine="docker exec -it postgres_piscineds psql -U \$(whoami) -d piscineds -W"' >> ~/.zshrc
source ~/.zshrc
```

A partir de ahora:

```bash
pspiscine
```

[↑ Volver al índice](#-índice)

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
# o solo detener:
docker-compose stop

# Parar el servicio y borrar TODOS los datos (¡cuidado!)
docker-compose down -v
```

En `start.sh`:

- Apagar conservando datos → gestión inicial opción **1** (`docker-compose stop`)
- Limpieza completa → gestión inicial opción **2** o menú opción **4** (`down -v`, con confirmación)

[↑ Volver al índice](#-índice)

---

## 📝 Alternativas (si no quieres usar Docker)

- **`setup.sh`**: script que instala y configura PostgreSQL nativamente.
- **`VM-instructions.txt`**: instrucciones para instalar PostgreSQL dentro de una máquina virtual.

[↑ Volver al índice](#-índice)

---

## ✅ Cómo saber que lo has hecho bien

- El contenedor aparece en `docker ps`.
- Puedes entrar a la base de datos con `docker exec` o con el comando oficial del subject.
- El usuario, la contraseña y el nombre de la BD son exactamente los que pide el subject.
- El archivo `docker-compose.yml` está limpio (sin la línea `version` obsoleta).
- (Recomendado) Existe `.env` y está en `.gitignore`.

Comprobación rápida:

```bash
docker ps --filter "name=postgres_piscineds"
docker exec -it postgres_piscineds psql -U "$(whoami)" -d piscineds -W
# dentro de psql:
# \conninfo
# \q
```

[↑ Volver al índice](#-índice)

---

## 🔗 Navegación

- [← README principal](../README.md)
- [Siguiente ejercicio: ex01 →](../ex01/README.md)

---

*Piscine Data Science – sternero – 42 Málaga – Septiembre de 2026*
