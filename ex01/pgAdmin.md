# 🖥️ Guía de conexión: pgAdmin ↔ PostgreSQL

<p align="center">
  <img src="../imgs/banner_01.jpg" alt="Piscine Data Science – Module 0 – ex01 – pgAdmin" width="100%">
</p>

[← Volver al README de EX01](README.md) · [← README principal](../README.md)

---

## 📑 Índice

1. [Antes de empezar: qué estamos conectando](#-antes-de-empezar-qué-estamos-conectando)
2. [Paso 0 — Comprobar que todo está levantado](#-paso-0--comprobar-que-todo-está-levantado)
3. [Paso 1 — Entrar en pgAdmin](#-paso-1--entrar-en-pgadmin)
4. [Paso 2 — Registrar un servidor nuevo](#-paso-2--registrar-un-servidor-nuevo)
5. [Paso 3 — Pestaña General](#-paso-3--pestaña-general)
6. [Paso 4 — Pestaña Connection](#-paso-4--pestaña-connection-la-importante)
7. [Paso 5 — Guardar](#-paso-5--guardar)
8. [Paso 6 — Explorar la base de datos](#-paso-6--explorar-la-base-de-datos)
9. [Resumen de los datos de conexión](#-resumen-de-los-datos-de-conexión)
10. [Si algo falla](#-si-algo-falla)
11. [Orden mental para no liarte](#-orden-mental-para-no-liarte)
12. [¿Cumple esto el subject?](#-cumple-esto-el-subject)
13. [Qué debemos tener cumplido hasta aquí](#-qué-debemos-tener-cumplido-hasta-aquí)
14. [Cerrar el navegador y apagar servicios](#-cerrar-el-navegador-y-apagar-servicios)
15. [Navegación](#-navegación)

---

## 🧩 Antes de empezar: qué estamos conectando

Tienes **dos piezas distintas**:

### 1. PostgreSQL (el almacén de datos)

Vive dentro de un contenedor Docker llamado `piscineds`.

| Dato | Valor |
|------|--------|
| Usuario | Tu login de 42 (ejemplo: `pepito-`) |
| Contraseña | `mysecretpassword` |
| Base de datos | `piscineds` |
| Puerto | `5432` |
| Host desde tu máquina | `localhost` |

### 2. pgAdmin (el panel visual)

Es la interfaz web en el navegador.

| Dato | Valor |
|------|--------|
| Dirección | `http://127.0.0.1:5050` |
| Usuario de pgAdmin | El **email** que creaste la primera vez |
| Contraseña de pgAdmin | La que elegiste al primer arranque |

> ⚠️ **Importante:** el usuario/contraseña de **pgAdmin** no son los mismos que los de **PostgreSQL**.

Lo que vamos a hacer es decirle a pgAdmin:

> «Conéctate a ese PostgreSQL que está en `localhost`, puerto `5432`».

[↑ Volver al índice](#-índice)

---

## 🔍 Paso 0 — Comprobar que todo está levantado

### A) PostgreSQL debe estar corriendo

En una terminal:

```bash
docker ps
```

Debes ver una línea con `postgres_piscineds` (alias asignado a nuestra DB piscineds en nuestro docker-compose lo que **no contradice las instrucciones del proyecto**) y el puerto `5432`.

**Si no aparece**, arráncalo desde EX00:

```bash
cd ruta/a/tu/ex00
docker-compose up -d
docker ps
```

También puedes usar el script de EX01:

```bash
cd ruta/a/tu/ex01
./start.sh
```

y elegir la opción de comprobar / preparar PostgreSQL (o ejecutar el `start.sh` de EX00 desde el menú).

### B) pgAdmin debe responder en el navegador

Abre:

```text
http://127.0.0.1:5050
```

**Si no carga**, desde la carpeta `ex01`:

```bash
./start.sh
```

y elige **Arrancar pgAdmin**.

Equivalente orientativo por terminal (si ya tienes la instalación hecha):

```bash
# Arrancar pgAdmin en segundo plano (concepto)
PYTHONPATH="$HOME/sgoinfre/pgadmin4/config:$PYTHONPATH" \
  "$HOME/sgoinfre/pgadmin4/venv/bin/pgadmin4" >/dev/null 2>&1 &
```

Cuando veas la pantalla de login de pgAdmin, continúa.

[↑ Volver al índice](#-índice)

---

## 🔐 Paso 1 — Entrar en pgAdmin

1. Abre el navegador.
2. Ve a: `http://127.0.0.1:5050`
3. Introduce el **email** y la **contraseña de pgAdmin**  
   (los del primer arranque, **no** los de PostgreSQL).
4. Pulsa **Login**.

Si entras y ves un panel con un árbol a la izquierda (donde pone **Servers**), vas bien.

[↑ Volver al índice](#-índice)

---

## 📂 Paso 2 — Registrar un servidor nuevo

En el panel izquierdo:

1. Localiza la palabra **Servers**.
2. **Clic derecho** sobre **Servers**.
3. En el menú: **Register**.
4. Luego: **Server…**.

Se abrirá una ventana con pestañas: **General**, **Connection**, etc.

[↑ Volver al índice](#-índice)

---

## 🏷️ Paso 3 — Pestaña General

1. Entra en la pestaña **General**.
2. En **Name** escribe un nombre cualquiera, por ejemplo:

```text
Piscine DS
```

Ese nombre es solo una etiqueta para ti. No afecta a la conexión real.

No hace falta rellenar más campos en esta pestaña.

[↑ Volver al índice](#-índice)

---

## 🔌 Paso 4 — Pestaña Connection (la importante)

Haz clic en la pestaña **Connection**.

Rellena **exactamente** así:

| Campo | Qué escribir | Ejemplo |
|-------|--------------|---------|
| **Host name/address** | `localhost` | `localhost` |
| **Port** | `5432` | `5432` |
| **Maintenance database** | `piscineds` | `piscineds` |
| **Username** | Tu login de 42 | `sternero` |
| **Password** | Contraseña de PostgreSQL | `mysecretpassword` |

### Por qué cada campo

- **Host name/address = `localhost`**  
  El contenedor publica el puerto 5432 en tu máquina.
- **Port = `5432`**  
  El mismo que en el `docker-compose.yml` de EX00.
- **Maintenance database = `piscineds`**  
  La base creada en EX00.
- **Username = tu login**  
  El valor de `POSTGRES_USER` del `.env` de EX00.
- **Password = `mysecretpassword`**  
  La de PostgreSQL, **no** la cuenta de pgAdmin.

### Recomendado

Marca **Save password** para no tener que escribirla cada vez.

Para recordar tus valores de EX00:

```bash
cat ../ex00/.env
```

[↑ Volver al índice](#-índice)

---

## 💾 Paso 5 — Guardar

1. Abajo a la derecha, pulsa **Save**.
2. Si todo va bien, la ventana se cierra y en el árbol aparece tu servidor (**Piscine DS** o el nombre que pusiste).

Si hay error de conexión, ve a [Si algo falla](#-si-algo-falla).

[↑ Volver al índice](#-índice)

---

## 🌳 Paso 6 — Explorar la base de datos

1. Flecha junto a **Piscine DS** (expandir).
2. **Databases** → **piscineds**
3. **Schemas** → **public**
4. **Tables**

Cuando en EX02, EX03 y EX04 crees tablas, aparecerán aquí.

Para ver datos de una tabla (cuando exista):

- Clic derecho sobre la tabla  
- **View/Edit Data** → **All Rows**

[↑ Volver al índice](#-índice)

---

## 📋 Resumen de los datos de conexión

```text
Host:                  localhost
Port:                  5432
Maintenance database:  piscineds
Username:              sternero              ← tu login
Password:              mysecretpassword      ← la de PostgreSQL
```

Comprobación equivalente por terminal (sin pgAdmin):

```bash
psql -U "$(whoami)" -d piscineds -h localhost -W
# o
docker exec -it postgres_piscineds psql -U "$(whoami)" -d piscineds -W
```

[↑ Volver al índice](#-índice)

---

## 🛠️ Si algo falla

### Error: connection refused / could not connect

**Causa habitual:** el contenedor no está corriendo.

```bash
docker ps
```

Si no está `postgres_piscineds`:

```bash
cd ruta/a/ex00
docker-compose up -d
```

O desde `ex01`:

```bash
./start.sh
# opción de comprobar / preparar PostgreSQL
```

---

### Error: password authentication failed

**Causa habitual:** usuario o contraseña incorrectos.

```bash
cat ../ex00/.env
```

Usa **exactamente** esos valores en la pestaña Connection de pgAdmin.

---

### No encuentro “Register → Server”

Haz **clic derecho** sobre la carpeta **Servers** del panel izquierdo, no sobre otro elemento.

---

### pgAdmin pide email/contraseña y no los recuerdo

Son los de la **cuenta de pgAdmin**, no los de PostgreSQL.

Si los perdiste del todo, como último recurso:

```bash
# 1) Detener y, si hace falta, eliminar la instalación de pgAdmin
./off_del.sh

# 2) Reinstalación limpia
./install.sh

# 3) Arrancar de nuevo
./start.sh
```

La primera vez volverá a pedirte email y contraseña de pgAdmin.

[↑ Volver al índice](#-índice)

---

## 🧠 Orden mental para no liarte

1. PostgreSQL **encendido** → `docker ps` muestra `postgres_piscineds`
2. pgAdmin **encendido** → `http://127.0.0.1:5050` responde
3. En pgAdmin: **Register → Server…**
4. Connection: `localhost` / `5432` / `piscineds` / tu login / `mysecretpassword`
5. **Save** y expandir el árbol

[↑ Volver al índice](#-índice)

---

## ✅ ¿Cumple esto el subject?

### EX00 — Create Postgres DB

El subject exige:

| Requisito | ¿Lo cumplimos? |
|-----------|----------------|
| Usuario = login de estudiante | ✅ |
| Base de datos = `piscineds` | ✅ |
| Contraseña = `mysecretpassword` | ✅ |
| Conexión con `psql -U login -d piscineds -h localhost -W` | ✅ |
| Entregable: `docker-compose.yml` / `setup.sh` / `VM-instructions.txt` | ✅ |
| Docker con buenas prácticas tipo Inception | ✅ |

**pgAdmin no forma parte de EX00.**  
EX00 solo pide que la base exista y sea accesible con `psql`.

### EX01 — Show me your DB

El subject pide:

- Una herramienta gráfica (pgAdmin, Postico, DBeaver u otra)
- Que permita visualizar y manipular datos fácilmente, sobre todo por IDs

**No impone** el método de conexión.  
Usar:

```text
Host: localhost | Port: 5432 | DB: piscineds | User: login | Password: mysecretpassword
```

es correcto porque usa exactamente las credenciales de EX00.

| Pregunta | Respuesta |
|----------|-----------|
| ¿Los pasos de pgAdmin son requisitos de EX00? | No (EX00 no pide pgAdmin) |
| ¿Usan las credenciales correctas de EX00? | **Sí** |
| ¿Cumplen EX01? | **Sí** |
| ¿Contradicen el subject? | **No** |

[↑ Volver al índice](#-índice)

---

## 🏁 Qué debemos tener cumplido hasta aquí

El “paso 6” es solo el final de la **guía de conexión**.  
Hasta aquí, lo demostrable en evaluación es:

### EX00

| Requisito | Cómo comprobarlo |
|-----------|------------------|
| Usuario = tu login | Conexión con ese usuario |
| Base = `piscineds` | Existe y entras en ella |
| Password = `mysecretpassword` | Funciona al conectar |
| Comando del subject | `psql -U tu_login -d piscineds -h localhost -W` |
| Archivo en `ex00/` | `docker-compose.yml` (u opción permitida) |

### EX01

| Requisito | Cómo comprobarlo |
|-----------|------------------|
| Herramienta gráfica | Abres pgAdmin |
| Ves la base | Aparece `piscineds` en el árbol |
| Puedes navegar | Schemas → public → Tables |

Todavía **no hay tablas** (EX02+). En EX01 basta con abrir pgAdmin, conectar y mostrar `piscineds`.

### Qué NO entra todavía

- Crear tablas desde CSV → **EX02**
- Tablas automáticas de `customer/` → **EX03**
- Tabla `items` → **EX04**

```text
EX00  →  PostgreSQL vivo (login / piscineds / mysecretpassword)
EX01  →  pgAdmin conectado y pudiendo ver piscineds
```

[↑ Volver al índice](#-índice)

---

## 🧹 Cerrar el navegador y apagar servicios

### ¿Basta con cerrar la pestaña?

**Sí.** Cerrar el navegador **no borra** nada importante.

| Qué | ¿Se pierde al cerrar el navegador? |
|-----|-------------------------------------|
| Instalación de pgAdmin | **No** |
| Usuario/contraseña de pgAdmin | **No** |
| Servidor registrado (Piscine DS) | **No** (si marcaste *Save password*) |
| Datos de PostgreSQL | **No** |
| Contenedor Docker | **No** (sigue en segundo plano) |

pgAdmin guarda su configuración en SQLite bajo `~/sgoinfre/pgadmin4/data/`.

### Qué sigue activo al cerrar la pestaña

- El contenedor `postgres_piscineds`
- El proceso de pgAdmin (puerto 5050), si lo arrancaste con `start.sh`

### Apagar sin borrar nada

**Con script (recomendado):**

```bash
cd ruta/a/ex01
./start.sh
# opción: Detener servicios (pgAdmin y/o PostgreSQL)
```

O:

```bash
./off_del.sh
# elegir solo detener (sin eliminar)
```

**Por comandos de terminal:**

```bash
# Detener solo pgAdmin (procesos del usuario)
pkill -u "$(id -un)" -f 'pgadmin4|pgAdmin4' || true

# Detener solo PostgreSQL (conserva volumen y datos)
docker stop postgres_piscineds
```

### Volver a trabajar otro día

```bash
# PostgreSQL
cd ruta/a/ex00
docker-compose up -d

# pgAdmin
cd ruta/a/ex01
./start.sh
# → Arrancar pgAdmin
```

Luego abre de nuevo `http://127.0.0.1:5050`.

[↑ Volver al índice](#-índice)

---

## 🔗 Navegación

- [← README de EX01](README.md)
- [← README principal](../README.md)
- [← EX00](../ex00/README.md)
- [Siguiente: EX02 →](../ex02/README.md)

---

*Piscine Data Science – sternero – 42 Málaga – Septiembre de 2026*
