# 🐳 Guía Docker – EX00 y la Piscine Data Science

<p align="center">
  <img src="../imgs/banner_06_docker.jpg" alt="Piscine Data Science – Module 0 – Docker" width="100%">
</p>

[← Volver al README de EX00](README.md) · [← README principal](../README.md)

---

## 📑 Índice

1. [¿Para quién es esta guía?](#-para-quién-es-esta-guía)
2. [El objetivo de esta guía](#-el-objetivo-de-esta-guía)
3. [¿Qué problema resuelve Docker?](#-qué-problema-resuelve-docker)
4. [Ideas clave: imagen, contenedor, volumen, red](#-ideas-clave-imagen-contenedor-volumen-red)
5. [¿Qué es Docker Compose?](#-qué-es-docker-compose)
6. [Por qué Docker en EX00](#-por-qué-docker-en-ex00)
7. [Anatomía de un `docker-compose.yml` (PostgreSQL)](#-anatomía-de-un-docker-composeyml-postgresql)
8. [Qué hace el sistema “bajo el capó” (paso a paso)](#-qué-hace-el-sistema-bajo-el-capó-paso-a-paso)
9. [Archivo `.env` y buenas prácticas](#-archivo-env-y-buenas-prácticas)
10. [Comandos esenciales del día a día](#-comandos-esenciales-del-día-a-día)
11. [Ciclo de vida: arrancar, parar, borrar](#-ciclo-de-vida-arrancar-parar-borrar)
12. [`docker exec` y PostgreSQL](#-docker-exec-y-postgresql)
13. [Copiar archivos al contenedor (`docker cp`)](#-copiar-archivos-al-contenedor-docker-cp)
14. [Persistencia de datos (muy importante)](#-persistencia-de-datos-muy-importante)
15. [Buenas prácticas en el campus 42](#-buenas-prácticas-en-el-campus-42)
16. [Errores frecuentes](#-errores-frecuentes)
17. [Mapa con el resto del módulo](#-mapa-con-el-resto-del-módulo)
18. [Mini glosario](#-mini-glosario)
19. [Navegación](#-navegación)

---

## 👋 ¿Para quién es esta guía?

Para cualquier persona de la **Piscine Data Science** en 42 que:

- vaya a montar PostgreSQL con **Docker / Docker Compose** en EX00,
- no tenga clara la diferencia entre imagen, contenedor y volumen,
- necesite comandos fiables sin memorizar toda la documentación oficial,
- quiera evitar borrados accidentales de datos.

Es **genérica**: sirve para cualquier login.  
Donde veas **`tu_login`** (sustituye por tu login) o usa **`$(whoami)`** (que cogerá tu login del sistema).

[↑ Volver al índice](#-índice)

---

## 🎯 El objetivo de esta guía

Al terminarla deberías poder:

1. Explicar **qué es** Docker en una frase útil.  
2. Distinguir **imagen**, **contenedor** y **volumen**.  
3. Leer un `docker-compose.yml` mínimo de PostgreSQL.  
4. **Arrancar**, **comprobar**, **parar** y **reiniciar** el servicio.  
5. Saber cuándo un comando **borra datos** y cuándo no.  
6. Usar `docker exec` y `docker cp` con sentido en EX00–EX02.

No es un curso completo de Docker.  
Es el **kit mínimo** para no atascarte en esta piscine.

[↑ Volver al índice](#-índice)

---

## 🧩 ¿Qué problema resuelve Docker?

Sin Docker, cada persona instalaría PostgreSQL de forma distinta:

- versiones diferentes,
- rutas distintas,
- problemas de permisos (`sudo`),
- “en mi máquina funciona... ¿Por qué en la tuya no?”.

**Docker** empaqueta una aplicación (aquí, PostgreSQL) con su entorno en una **caja reproducible**.

Analogía:

| Idea | Comparación |
|------|-------------|
| Imagen | Receta / plano de la caja |
| Contenedor | La caja ya montada y en marcha |
| Volumen | Un cajón externo donde guardas lo importante |
| `docker-compose.yml` | Instrucciones para montar el escenario completo |

Docker permite que **todo el mundo** tenga el mismo PostgreSQL 15 sin tener que instalarlo a mano en el sistema.

[↑ Volver al índice](#-índice)

---

## 🧱 Ideas clave: imagen, contenedor, volumen, red

### Imagen (*image*)

Plantilla de solo lectura. Ejemplo: `postgres:15`.

```bash
# Docker la descarga la primera vez que la necesitas
docker-compose up -d
```

### Contenedor (*container*)

Instancia en ejecución (o detenida) creada a partir de una imagen.

En este proyecto suele llamarse, por ejemplo:

```text
postgres_piscineds
```

### Volumen (*volume*)

Almacenamiento **persistente** fuera del ciclo de vida efímero del contenedor.

Si solo borras el contenedor pero **conservas el volumen**, las bases y tablas siguen ahí.

### Red (*network*)

Canal por el que los contenedores se hablan entre sí.  
Con un solo servicio PostgreSQL casi no la tocas; Compose crea una red por defecto.

```text
imagen postgres:15
        ↓  (docker-compose up)
contenedor postgres_piscineds
        ↓
volumen postgres_data  →  datos de /var/lib/postgresql/data
        ↓
puerto 5432 publicado en localhost
```

[↑ Volver al índice](#-índice)

---

## 📦 ¿Qué es Docker Compose?

**Docker Compose** es la herramienta para definir y levantar **uno o varios** servicios con un fichero YAML.

En EX00 normalmente hay **un solo servicio**: PostgreSQL.

| Sin Compose | Con Compose |
|-------------|-------------|
| Largos `docker run` con muchos flags | Un archivo `docker-compose.yml` legible |
| Fácil olvidar puertos o variables | Todo versionado en el repo |
| Menos claro para el evaluador | El subject acepta `docker-compose.yml` como entregable |

Comandos típicos (en la carpeta del `docker-compose.yml`):

```bash
docker-compose up -d
docker-compose ps
docker-compose stop
docker-compose down
docker-compose down -v
```

> En instalaciones recientes el comando puede ser `docker compose` (sin guion).  
> Por lo generar suele funcionar `docker-compose`. Prueba ambos si uno no lo hace.

[↑ Volver al índice](#-índice)

---

## 🎓 Por qué Docker en EX00

El subject permite:

- PostgreSQL ya instalado en la máquina,
- una VM,
- o **Docker Compose**.

Docker es el camino más **homogéneo** en 42:

| Ventaja | Detalle |
|---------|---------|
| Reproducible | Misma imagen `postgres:15` para todos |
| Sin `sudo` para instalar Postgres en el host | El motor vive en el contenedor |
| Alineado con Inception | `.env`, no hardcodear secretos, volúmenes |
| Portable | El mismo `docker-compose.yml` en otra sesión |

Tu entregable típico en `ex00/`:

```text
docker-compose.yml
```

(podríamos decidir acompañarlo de scripts de ayuda y .md, pero el subject pide **uno** de: compose / `setup.sh` / `VM-instructions.txt`, así que: mejor **entregar solamente el fichero que nos piden**).

[↑ Volver al índice](#-índice)

---

## 📄 Anatomía de un `docker-compose.yml` (PostgreSQL)

Ejemplo mínimo válido (sin comentarios):

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

### Qué significa cada bloque

| Clave | Significado |
|-------|-------------|
| `services` | Lista de servicios a levantar |
| `postgres` | Nombre del servicio dentro de Compose |
| `image: postgres:15` | Imagen oficial, versión 15 |
| `container_name` | Nombre fijo del contenedor (más cómodo en `docker ps`) |
| `environment` | Usuario, contraseña y base creados al **primer** arranque |
| `ports` | `puerto_en_tu_máquina:puerto_en_el_contenedor` |
| `volumes` | Persistencia de los ficheros de PostgreSQL |
| `restart: unless-stopped` | Reinicia solo si no lo paraste tú a propósito |
| `volumes:` (al final) | Declaración del volumen nombrado |

### Sobre la línea `version:`

En Compose moderno la clave `version:` es **obsoleta** y se puede omitir.  
Si la dejas y aparece un *warning*, no suele impedir el arranque; pero también puedes quitarla (recomendado).

### Variables `${...}`

Leen valores del entorno o de un archivo **`.env`** en la misma carpeta.  
Así no escribes la contraseña dentro del YAML (buena práctica tipo Inception).

[↑ Volver al índice](#-índice)

---


## 🔍 Qué hace el sistema “bajo el capó” (paso a paso)

Cuando escribes, desde la carpeta donde está tu `docker-compose.yml`:

```bash
docker-compose up -d
```

**no** estás “encendiendo PostgreSQL con magia”.

Estás diciendo al sistema:

> “Lee este **plano** (`docker-compose.yml`), prepara lo que falte y deja el servicio corriendo en segundo plano.”

A continuación vemos **qué ocurre por dentro**, paso a paso, y con ejemplos para verlo todo con más claridad.

---

### Paso A — Leer y entender el plano

Compose abre el archivo `docker-compose.yml` y resuelve las variables del estilo `${POSTGRES_USER}`.

Si en la misma carpeta existe un archivo `.env`, **inyecta** esos valores en el plano.

**Ejemplo cotidiano:**  
Es como una receta de cocina que te dice “añade *la cantidad de sal que indica la nota del frigorífico*”.  
El `.env` es esa nota del frigorífico (una información que no has querido incluir directamente en la receta):

```text
POSTGRES_USER=tu_login
POSTGRES_PASSWORD=mysecretpassword
POSTGRES_DB=piscineds
```

Compose lee la receta + la nota y ya sabe:

```text
Usuario   = tu_login
Password  = mysecretpassword
Base      = piscineds
```

Si faltan datos en el `.env`, el resultado puede no coincidir con lo que pide el subject.

---

### Paso B — ¿Tengo ya la imagen `postgres:15`?

Una **imagen** es una **plantilla lista para usar**: no es todavía “tu” base de datos, es el molde.

**Ejemplo cotidiano:**  
La imagen es como el **plano y el pack de piezas** de un mueble del IKEA (PostgreSQL 15 ya preparado).  
Aún no es el mueble montado en tu salón; es el paquete cerrado.

- Si Docker **ya tiene** esa imagen en el ordenador (el paquete de cerrado con lo necesario para montar el mueble) → la reutiliza.  
- Si **no la tiene** → la **descarga del registro** (se encarga de pedir el paquete por Internet).

**¿Qué es “el registro”?**  
Un almacén en Internet (por ejemplo Docker Hub) donde están publicadas muchas imágenes oficiales.  
La primera vez, Docker va a ese almacén, descarga `postgres:15` y la guarda en tu ordenador para no volver a bajarla cada día.

```text
Primera vez:  Internet (registro)  →  descarga  →  imagen guardada en tu PC
Siguientes:   usa la imagen que ya tienes
```

---

### Paso C — ¿Existe el volumen de datos?

El YAML suele decir algo como:

```yaml
volumes:
  - postgres_data:/var/lib/postgresql/data
```

Un **volumen** es algo así como **las cajas de un trastero** donde se guardan datos importantes.

**Ejemplo cotidiano:**  
Mientras que el contenedor es una **furgoneta de mudanza** (se puede aparcar, mover o sustituir).  
El volumen sin embargo es el **trastero del edificio**: aunque cambies de furgoneta, las cajas del trastero siguen ahí.

- Si el volumen `postgres_data` **no existe** → Compose lo **crea**.  
- Si **ya existe** → lo **reutiliza** (ahí están tus tablas de ayer, las cajas en el trastrero).

Dentro del contenedor, ese cajón se “engancha” en la carpeta:

```text
/var/lib/postgresql/data
```

que es el sitio donde PostgreSQL guarda sus ficheros internos.

Por eso:

- borrar solo el contenedor (cambiar de furgoneta) **no** implica borrar siempre los datos,
- aunque ¡CUIDADO!`docker-compose down -v` sí que puede tirar el trastero entero (**se pierden los datos**).

---

### Paso D — Crear (o recrear) el contenedor

Aquí Docker monta la pieza central. Vamos término a término, sin dar nada por sentado.

#### ¿Qué es un contenedor?

Una **caja en marcha** creada a partir de la imagen.

**Ejemplo:** la imagen es el plano para un puesto de limonada; mientras que el contenedor es **tu** puesto ya montado en la calle hoy.

#### ¿Qué es una instancia?

Significa: “una copia concreta en ejecución”.  
Puedes tener la misma imagen y, en teoría, varios contenedores (varios puestos de limonada iguales); en EX00 normalmente tienes **uno**: `postgres_piscineds`.

#### ¿Qué es una capa?

Imagina transparencias apiladas:

1. Capa base del sistema.  
2. Capa con PostgreSQL instalado (viene de la imagen).  
3. Pequeños cambios de **este** contenedor.

Tú no gestionas las capas a mano; solo es útil saber que el contenedor **no copia todo desde cero** cada vez de forma absurda: reutiliza la plantilla y añade lo suyo.

#### ¿Qué es un volumen? (otra vez, porque importa)

El **trastero** enganchado a la caja.  
Los datos de la base viven ahí, no “solo en la memoria temporal del contenedor”.

#### ¿Qué son las variables de entorno?

Son **ajustes que se le pasan al programa al arrancar**, como interruptores, valore o instrucciones.

**Ejemplo cotidiano:**  
Al encender una lavadora eliges “algodón, 40 °C, centrifugado”.  
Eso no es la ropa en si misma; son **parámetros** para su lavado.

Aquí:

```text
POSTGRES_USER       → quién es el dueño inicial
POSTGRES_PASSWORD   → la llave
POSTGRES_DB         → el nombre del primer cajón de datos (piscineds)
```

#### ¿Qué es la red de Compose?

Un **pasillo privado** por el que los contenedores de un mismo proyecto podrían hablar entre sí.

En EX00 casi solo tienes PostgreSQL, así que apenas la notas.  
Compose igual crea una red por defecto para dejar el escenario ordenado.

#### ¿Qué es un puerto? (muy importante)

Un **puerto** es un **número de puerta** por donde un programa acepta conexiones.

**Ejemplo cotidiano:**  
En un bloque de pisos, el portal es la dirección (el ordenador).  
El **piso 5432** es el puerto: “llame usted al 5432 para hablar con PostgreSQL”.

PostgreSQL, por convención, escucha en el puerto **5432**.

#### ¿Qué es el mapeo de puertos?

Conectar una puerta de **tu ordenador** con una puerta **dentro** del contenedor.

```yaml
ports:
  - "5432:5432"
```

Se lee:

```text
puerto 5432 en TU máquina  →  puerto 5432 DENTRO del contenedor
```

**Ejemplo:**  
El contenedor es un local interior sin escaparate a la calle.  
El mapeo es poner un **timbre en la calle** (5432 de tu PC) que suena dentro del local (5432 de PostgreSQL).

Sin mapeo, PostgreSQL podría estar *dentro* de la caja y tú no podrías entrar desde fuera con `psql -h localhost` ni con pgAdmin.

Con la imagen, el volumen, las variables, la red y los puertos, Docker deja creado el contenedor `postgres_piscineds` (o el nombre que hayas puesto).

---

### Paso E — Inicializar datos (solo la primera vez) y arrancar PostgreSQL

Dentro de la imagen oficial de PostgreSQL hay un **script de arranque** (un programa que se ejecuta al iniciaar el contenedor).

#### ¿Dónde se inicializa el directorio de datos?

En la carpeta de datos de PostgreSQL, que en nuestro compose está ligada al volumen:

```text
/var/lib/postgresql/data
```

Ahí PostgreSQL guarda sus ficheros internos (no son tus CSV todavía; es el “sistema de archivadores” del motor).

#### ¿Cómo y por qué se inicializa?

- **Cómo:** el script de arranque prepara esa carpeta, crea el usuario, la contraseña y la base `piscineds` según las variables de entorno.  
- **Por qué:** un motor de base de datos necesita un espacio inicial ordenado antes de aceptar datos. Es como **montar las estanterías vacías** antes de guardar cajas.

Esto ocurre sobre todo cuando el volumen está **vacío** (primera vez).

Si el volumen **ya tenía datos**, no vuelve a “construir el almacén desde cero”: simplemente **reutiliza** lo que había y arranca el servidor.

#### ¿Qué significa “arrancar el servicio y dejarlo escuchando”?

- **Arrancar el servicio** = poner en marcha el programa PostgreSQL.  
- **Escuchando** = quedarse a la espera de peticiones en un puerto (el 5432 interno), como un mostrador abierto al público.

Hasta que no escucha, no puedes conectar con `psql` ni con pgAdmin.

---

### Paso F — Publicar el puerto (el timbre a la calle)

Aunque PostgreSQL ya escuche *dentro* del contenedor, falta el enlace con tu máquina.

Eso es otra vez el **mapeo de puertos**:

```text
localhost:5432 (tu PC)  →  5432 (PostgreSQL dentro del contenedor)
```

**Publicar el puerto** significa: “hacer accesible ese servicio desde fuera del contenedor”.

**Ejemplo:**  
La tienda ya está abierta en el patio interior (contenedor).  
Publicar el puerto es abrir la **entrada desde la acera** para que los clientes (psql, pgAdmin, scripts) puedan entrar.

Por eso el subject puede pedir:

```bash
psql -U tu_login -d piscineds -h localhost -W
```

`localhost` + puerto `5432` funcionan gracias a este mapeo.

---

### Paso G — Segundo plano (`-d`)

La opción `-d` significa *detached* (separado / en segundo plano).

**¿Qué implica?**

- El contenedor **sigue corriendo**.  
- Tu terminal **no se queda bloqueada** mostrando logs todo el tiempo.  
- Puedes seguir escribiendo otros comandos.

**Ejemplo cotidiano:**  
Encender la lavadora y **no** quedarte mirándola dos horas.  
La lavadora sigue; tú mientras tanto haces otra cosa.

Para mirar lo que ocurre dentro:

```bash
docker logs postgres_piscineds
```

`Ctrl+C` en un `docker logs -f` solo deja de mostrar logs; **no** apaga el contenedor.

---

### Resumen visual de los siete pasos

```text
A. Leer plano (YAML + .env)
B. ¿Imagen postgres:15? → usar o descargar del registro
C. ¿Volumen de datos? → crear o reutilizar (trastero)
D. Crear contenedor (caja + env + red + puertos)
E. Inicializar (1ª vez) y arrancar PostgreSQL escuchando
F. Publicar puerto 5432 en localhost
G. Quedar en segundo plano (-d)
        ↓
   Ya puedes conectar con psql / pgAdmin
```

[↑ Volver al índice](#-índice)


## 🔐 Archivo `.env` y buenas prácticas

Ejemplo de `.env` para esta piscine:

```bash
POSTGRES_USER=tu_login
POSTGRES_PASSWORD=mysecretpassword
POSTGRES_DB=piscineds
```

Creación rápida (usuario = login del sistema):

```bash
echo "POSTGRES_USER=$(id -un)
POSTGRES_PASSWORD=mysecretpassword
POSTGRES_DB=piscineds" > .env
```

Protección en Git:

```bash
echo ".env" >> .gitignore
```

| Buena práctica | Por qué |
|----------------|---------|
| Credenciales en `.env` | No hardcodear en el compose |
| `.env` en `.gitignore` | Impide subir secretos al repo |
| Misma contraseña del subject | `mysecretpassword` es única y obligatoria |
| Usuario = «tu_login« | También obligario. |

**Importante:** `POSTGRES_USER` / `POSTGRES_DB` se aplican sobre todo cuando el **volumen se crea por primera vez**.  
Si cambias el `.env` pero reutilizas un volumen antiguo, puedes ver usuarios o bases “viejas”. En ese caso hace falta recrear el volumen (destructivo) o gestionar usuarios a mano.

[↑ Volver al índice](#-índice)

---

## ⌨️ Comandos esenciales del día a día

Ejecuta estos comandos **desde la carpeta donde está tu `docker-compose.yml`** (salvo que indiques otra ruta).

### Arrancar

```bash
docker-compose up -d
```

`-d` = *detached* (en segundo plano, así puedes seguir trabajando en la misma terminal).

### ¿Está corriendo?

```bash
docker ps
docker-compose ps
```

Busca el nombre del contenedor y el puerto `0.0.0.0:5432->5432/tcp`.

### Logs

```bash
docker logs postgres_piscineds
docker logs --tail 20 postgres_piscineds
docker logs -f postgres_piscineds
```

`-f` sigue el log en vivo (Ctrl+C para dejar de seguir; **no** apaga el contenedor).

### Parar sin borrar datos

```bash
docker-compose stop
# o
docker stop postgres_piscineds
```

### Parar y eliminar contenedor/red (volumen se conserva por defecto)

```bash
docker-compose down
```

### ⚠️ Parar y eliminar también volúmenes (¡borra datos de PostgreSQL!)

```bash
docker-compose down -v
```

Usa `-v` solo cuando quieras un **reset total**.

[↑ Volver al índice](#-índice)

---

## 🔄 Ciclo de vida: arrancar, parar, borrar

| Acción | Comando típico | ¿Se pierden tablas/datos? |
|--------|----------------|---------------------------|
| Arrancar | `docker-compose up -d` | No |
| Ver estado | `docker ps` | No |
| Parar | `docker-compose stop` | No |
| Quitar contenedor | `docker-compose down` | No (si el volumen sigue) |
| ⚠️ Reset total | `docker-compose down -v` | **Sí** |

Regla práctica:

- Cerrar el portátil / parar el contenedor → **los datos pueden permanecer** en el volumen.  
- `down -v` o borrar el volumen a mano → **empiezas de cero**.

[↑ Volver al índice](#-índice)

---

## 🛠️ `docker exec` y PostgreSQL

`docker exec` ejecuta un comando **dentro** de un contenedor en marcha.

Conexión habitual a `psql` sin tener el cliente en el host:

```bash
docker exec -it postgres_piscineds \
  psql -U "$(whoami)" -d piscineds -W
```

| Flag | Significado |
|------|-------------|
| `-i` | Entrada interactiva |
| `-t` | Terminal |
| `postgres_piscineds` | Contenedor destino |

Otros ejemplos útiles:

```bash
# ¿PostgreSQL acepta conexiones?
docker exec postgres_piscineds pg_isready -U "$(whoami)" -d piscineds

# Variables de entorno del contenedor
docker exec postgres_piscineds env | grep POSTGRES
```

Más detalle de `psql` en [postgresql.md](./postgresql.md).

[↑ Volver al índice](#-índice)

---

## 📂 Copiar archivos al contenedor (`docker cp`)

PostgreSQL, al hacer `COPY FROM '/ruta/archivo.csv'`, lee rutas **del servidor** (dentro del contenedor), no de tu home automáticamente.

Por eso en EX02 es frecuente:

```bash
docker cp /ruta/en/tu/maquina/data_2022_dec.csv \
  postgres_piscineds:/tmp/data_2022_dec.csv
```

Comprobación:

```bash
docker exec postgres_piscineds ls -la /tmp/data_2022_dec.csv
```

### Aviso `Lchown` / `invalid argument`

En algunos entornos del campus `docker cp` muestra un error de `Lchown` **después** de copiar.  
Si `ls` dentro del contenedor ve el fichero con tamaño correcto, **puedes continuar**.

Alternativa: `\copy` desde `psql` en el host (el cliente lee el fichero local).  
Eso se detalla en la [guía SQL de EX02](../ex02/SQL.md).

[↑ Volver al índice](#-índice)

---

## 💾 Persistencia de datos (muy importante)

Los datos de PostgreSQL viven, con el compose de ejemplo, en:

```text
volumen Docker → montado en /var/lib/postgresql/data
```

| Operación | Efecto sobre los datos |
|-----------|-------------------------|
| `stop` / reinicio del PC (con `restart` y volumen intacto) | Suele conservarlos |
| `down` sin `-v` | Conserva el volumen |
| ⚠️ `down -v` | **Borra** el volumen y los datos |
| Borrar el volumen a mano | **Borra** los datos |

Para la piscine:

- Durante el trabajo diario: `stop` / `up -d` es suficiente.  
- Solo usa `-v` si quieres recrear usuario/base desde cero o estás seguro de no necesitar las tablas.

[↑ Volver al índice](#-índice)

---

## 🏫 Buenas prácticas en el campus 42

1. Trabaja el compose en una ruta con espacio (`sgoinfre` / proyecto del módulo).  
2. No subas `.env` a GitHub.  
3. Usa `container_name` fijo para no adivinar IDs en cada comando.  
4. Publica `5432:5432` si quieres el comando del subject con `-h localhost`.  
5. Comprueba `docker ps` **antes** de depurar SQL o pgAdmin.  
6. Documenta cómo arrancar (o usa el `start.sh`).  
7. Recuerda: el evaluador debe poder levantar tu entorno con lo entregado en `ex00/`.

[↑ Volver al índice](#-índice)

---

## 🛠️ Errores frecuentes

### `port is already allocated` / `bind: address already in use`

Otro proceso (u otro contenedor) usa el 5432.

```bash
docker ps
# detén el contenedor antiguo o cambia el puerto host en el compose (ej. "5433:5432")
```

Si cambias el puerto host, en `psql` / pgAdmin deberás usar ese puerto.

### `container name already in use`

```bash
docker-compose down
# o: docker rm -f postgres_piscineds
```

### `connection refused` a localhost:5432

El contenedor no está *Up* o el puerto no está publicado.

```bash
docker-compose up -d
docker ps
```

### Cambié el `.env` y el usuario no existe

El volumen antiguo se inicializó con otras credenciales.

- ⚠️ Solución destructiva: `docker-compose down -v` y volver a `up -d`.  
- Solo si puedes permitirte perder los datos.

### `docker-compose: command not found`

Prueba:

```bash
docker compose version
```

y usa `docker compose` en lugar de `docker-compose`.

### Aviso `version is obsolete`

Quita la línea `version:` del YAML. No afecta a la lógica del servicio, es sólo una molestia.

[↑ Volver al índice](#-índice)

---

## 🗺️ Mapa con el resto del módulo

| Recurso | Contenido |
|---------|-----------|
| [README EX00](README.md) | Setup del ejercicio, entregable, checklist |
| [postgresql.md](./postgresql.md) | Qué es PostgreSQL y cómo usar `psql` |
| [README EX01](../ex01/README.md) | Herramienta gráfica |
| [pgAdmin.md](../ex01/pgAdmin.md) | Conectar la UI a `localhost:5432` |
| [SQL.md](../ex02/SQL.md) | Tablas, tipos, `COPY`, `docker cp` |

Orden mental:

```text
Docker (esta guía) → PostgreSQL arriba → psql / pgAdmin → CREATE / COPY (EX02+)
```

[↑ Volver al índice](#-índice)

---

## 📖 Mini glosario

| Término | Significado breve |
|---------|-------------------|
| Docker | Plataforma de contenedores |
| Imagen | Plantilla inmutable del servicio |
| Contenedor | Instancia en ejecución de una imagen |
| Volumen | Almacenamiento persistente |
| Compose | Orquestación simple con YAML |
| `up -d` | Crear/arrancar en segundo plano |
| `down` | Parar y eliminar contenedores/redes del proyecto |
| `down -v` | Además elimina volúmenes (borra datos) |
| `exec` | Comando dentro de un contenedor en marcha |
| `cp` | Copiar ficheros host ↔ contenedor |
| Puerto 5432 | Puerto por defecto de PostgreSQL |
| `.env` | Variables de entorno para Compose |

[↑ Volver al índice](#-índice)

---

## 🔗 Navegación

- [← README de EX00](README.md)
- [← README principal](../README.md)
- [Guía PostgreSQL + psql](./postgresql.md)
- [Siguiente: EX01 →](../ex01/README.md)
- [Guía SQL EX02](../ex02/SQL.md)

---

<br>
<p align=center>
   Piscine Data Science – Module 0 – Guía Docker – Material didáctico genérico <br><br>
   sternero – 42 Málaga – septiembre 2026
</p>
