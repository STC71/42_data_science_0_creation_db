# 📘 Guía SQL – EX02 First table

<p align="center">
  <img src="../imgs/banner_07_sql.jpg" alt="Piscine Data Science – Module 0 – EX02 – SQL" width="100%">
</p>

[← Volver al README de EX02](README.md) · [← README principal](../README.md)

---

## 📑 Índice

1. [¿Para quién es esta guía?](#-para-quién-es-esta-guía)
2. [¿Qué es SQL? (sin asumir nada)](#-qué-es-sql-sin-asumir-nada)
3. [Analogía del almacén](#-analogía-del-almacén)
4. [Qué pide exactamente el EX02](#-qué-pide-exactamente-el-ex02)
5. [El CSV: de qué hablan las columnas](#-el-csv-de-qué-hablan-las-columnas)
6. [Tipos de datos en PostgreSQL](#-tipos-de-datos-en-postgresql)
7. [Crear y borrar una tabla](#-crear-y-borrar-una-tabla)
8. [Meter datos: COPY (no miles de INSERT)](#-meter-datos-copy-no-miles-de-insert)
9. [Flujo completo paso a paso (Docker)](#-flujo-completo-paso-a-paso-docker)
10. [Comandos útiles dentro de psql](#-comandos-útiles-dentro-de-psql)
11. [Comprobar que todo está bien](#-comprobar-que-todo-está-bien)
12. [Errores frecuentes y cómo resolverlos](#-errores-frecuentes-y-cómo-resolverlos)
13. [Archivo a entregar (`table.*`)](#-archivo-a-entregar-table)
14. [Checklist de evaluación](#-checklist-de-evaluación)
15. [Mini glosario](#-mini-glosario)
16. [Navegación](#-navegación)

---

## 👋 ¿Para quién es esta guía?

Para cualquier persona que:

- esté en la **Piscine Data Science – Module 0**,
- tenga **EX00** (PostgreSQL) y **EX01** (herramienta gráfica) razonablemente listos,
- y vaya a hacer **EX02: First table**,
- **aunque no haya escrito nunca una línea de SQL**.

No hace falta saber programar en SQL de antemano.  
Sí hace falta tener la base `piscineds` en marcha (contenedor Docker u otra alternativa permitida).

[↑ Volver al índice](#-índice)

---

## 💬 ¿Qué es SQL? (sin asumir nada)

**SQL** significa *Structured Query Language* (lenguaje de consulta estructurado).

Es el idioma con el que hablamos a una **base de datos relacional** como PostgreSQL.

Con SQL puedes, entre otras cosas:

| Acción | Idea en lenguaje cotidiano |
|--------|----------------------------|
| `CREATE TABLE` | “Crea una estantería nueva con estos huecos” |
| `DROP TABLE` | “Tira esa estantería si existe” |
| `COPY` / `INSERT` | “Mete estos datos en la estantería” |
| `SELECT` | “Muéstrame filas que cumplan esto” |

No es un lenguaje de programación general (como C o Python).  
Es un **lenguaje de datos**: crear estructuras y preguntar por información.

En EX02 casi solo necesitas:

1. Crear una tabla (`CREATE TABLE`)
2. Llenarla desde un CSV (`COPY`)
3. Comprobar el resultado (`SELECT`, `\d`)

[↑ Volver al índice](#-índice)

---

## 🏭 Analogía del almacén

Imagina una tienda online enorme.

- **PostgreSQL** = el almacén grande.
- **Base de datos `piscineds`** = una zona del almacén dedicada a este proyecto.
- **Tabla** = una estantería concreta (por ejemplo: “eventos de diciembre 2022”).
- **Columna** = un tipo de dato que guardas en cada hueco (fecha, precio, usuario…).
- **Fila (row)** = un evento concreto (una persona vio un producto a una hora dada).
- **CSV** = una caja de cartón llena de tickets de papel, aún sin ordenar en la estantería.

**EX02** consiste en:

1. Montar la estantería con los huecos correctos (`CREATE TABLE`).
2. Vaciar la caja del CSV en esa estantería de forma masiva (`COPY`).

[↑ Volver al índice](#-índice)

---

## 🎯 Qué pide exactamente el EX02

Según las instrucciones dadas:

| Requisito | Detalle |
|-----------|---------|
| Origen de los datos | Un CSV de la carpeta `customer/` |
| Nombre de la tabla | Igual que el CSV **sin** `.csv` (ej.: `data_2022_dec.csv` → `data_2022_dec`) |
| Nombres de columnas | **Exactamente** los del CSV |
| Primera columna | Tipo fecha/hora (**DATETIME** en el subject → en PostgreSQL: `TIMESTAMP` o `TIMESTAMPTZ`) |
| Tipos de datos | **Al menos 6 tipos distintos** y apropiados (no todo `TEXT`) |
| Entrega | Carpeta `ex02/` con un archivo `table.*` (por ejemplo `table.sql` o `table.py`) |

No pide todavía automatizar todos los CSV (eso es **EX03**).  
En EX02 basta **una** tabla bien hecha a partir de **un** CSV.

[↑ Volver al índice](#-índice)

---

## 📄 El CSV: de qué hablan las columnas

Ejemplo de cabecera real de un fichero del subject:

```text
event_time,event_type,product_id,price,user_id,user_session
```

Ejemplo de fila:

```text
2022-12-01 00:00:00 UTC,remove_from_cart,5712790,6.27,576802932,51d85cb0-897f-48d2-918b-ad63965c12dc
```

| Columna | Significado sencillo | Ejemplo |
|---------|----------------------|---------|
| `event_time` | **Cuándo** ocurrió el evento | `2022-12-01 00:00:00 UTC` |
| `event_type` | **Qué hizo** el usuario | `view`, `cart`, `remove_from_cart`… |
| `product_id` | **Qué producto** | `5712790` |
| `price` | **Precio** del producto | `6.27` |
| `user_id` | **Quién** (usuario) | `576802932` |
| `user_session` | **En qué visita/sesión** del navegador | un UUID tipo `51d85cb0-...` |

En una frase:

> El 1 de diciembre de 2022 a las 00:00, el usuario `576802932`, en la sesión `51d85cb0-...`, **quitó del carrito** el producto `5712790`, que costaba **6,27**.

Si tu CSV tiene **exactamente** estas 6 columnas, la tabla debe tener **esas 6** (ni más ni menos).  
Si otro fichero del subject trae más columnas, la tabla debe incluirlas todas con nombres idénticos.

[↑ Volver al índice](#-índice)

---

## 🧩 Tipos de datos en PostgreSQL

El subject habla de **DATETIME**. En PostgreSQL el equivalente habitual es:

- `TIMESTAMP` → fecha y hora **sin** zona horaria  
- `TIMESTAMPTZ` (`TIMESTAMP WITH TIME ZONE`) → fecha y hora **con** zona  

Para valores como `2022-12-01 00:00:00 UTC`, **`TIMESTAMPTZ`** suele ir muy bien.

### Propuesta de tipos (≥ 6 distintos) para este CSV

| Columna | Tipo PostgreSQL | Por qué |
|---------|-----------------|--------|
| `event_time` | `TIMESTAMPTZ` | Fecha/hora (obligatoria la 1ª) |
| `event_type` | `VARCHAR(50)` | Texto corto |
| `product_id` | `INTEGER` | Entero |
| `price` | `NUMERIC(10,2)` | Dinero / decimales |
| `user_id` | `BIGINT` | Entero grande |
| `user_session` | `UUID` | Identificador UUID |

Eso son **6 tipos diferentes**:

1. `TIMESTAMPTZ`  
2. `VARCHAR`  
3. `INTEGER`  
4. `NUMERIC`  
5. `BIGINT`  
6. `UUID`  

### Ideas rápidas sobre cada tipo

- **`INTEGER`**: números enteros “normales”.  
- **`BIGINT`**: enteros más grandes (IDs de usuario suelen ir aquí).  
- **`NUMERIC(10,2)`**: número con 2 decimales (precios).  
- **`VARCHAR(n)`**: texto de hasta *n* caracteres.  
- **`UUID`**: formato estándar de identificadores `8-4-4-4-12` hexadecimales.  
- **`TIMESTAMPTZ`**: instante en el tiempo con zona.

Si al importar `UUID` fallara por algún valor raro, puedes usar `VARCHAR(36)` en `user_session`, pero entonces asegúrate de seguir teniendo **6 tipos distintos** en el conjunto de la tabla.

[↑ Volver al índice](#-índice)

---

## 🏗️ Crear y borrar una tabla

### Borrar si existe (útil al reintentar)

```sql
DROP TABLE IF EXISTS data_2022_dec;
```

- Si la tabla existe → la elimina.  
- Si no existe → no falla (solo un aviso).

### Crear la tabla

```sql
CREATE TABLE data_2022_dec (
    event_time    TIMESTAMPTZ,
    event_type    VARCHAR(50),
    product_id    INTEGER,
    price         NUMERIC(10,2),
    user_id       BIGINT,
    user_session  UUID
);
```

Lectura línea a línea:

- `CREATE TABLE data_2022_dec` → crea la estantería con ese nombre.  
- Cada línea dentro del paréntesis → una columna: `nombre` + `tipo`.  
- La **primera** columna es la de fecha/hora, como pide el subject.

> Sustituye `data_2022_dec` por el nombre de **tu** CSV sin extensión  
> (`data_2022_oct`, `data_2022_nov`, `data_2023_jan`, …).

[↑ Volver al índice](#-índice)

---

## 📦 Meter datos: COPY (no miles de INSERT)

### Por qué no usar INSERT fila a fila

Un CSV del subject puede tener **millones** de filas.  
Hacer un `INSERT` por fila sería lentísimo e impráctico.

### Qué es COPY

`COPY` es la forma de PostgreSQL de **cargar (o volcar) datos en bloque** desde un fichero.

Ejemplo:

```sql
COPY data_2022_dec
FROM '/tmp/data_2022_dec.csv'
WITH (FORMAT csv, HEADER true);
```

Significado:

| Parte | Significado |
|-------|-------------|
| `COPY data_2022_dec` | Destino: esta tabla |
| `FROM '...'` | Ruta del fichero **vista por el servidor PostgreSQL** |
| `FORMAT csv` | El fichero es CSV |
| `HEADER true` | La primera línea son nombres de columna → **no** se inserta como dato |

### Detalle importante con Docker

Si PostgreSQL corre **dentro de un contenedor**, la ruta de `FROM` es una ruta **dentro del contenedor**, no necesariamente la de tu home en el campus.

Por eso en el flujo habitual:

1. Copias el CSV al contenedor (`docker cp` → por ejemplo `/tmp/archivo.csv`).  
2. En el `COPY` usas esa ruta interna (`/tmp/archivo.csv`).

Alternativa: `\copy` desde el cliente `psql` (lee el fichero **en tu máquina**).  
En esta guía priorizamos `COPY` + `docker cp` por ser muy explícito y didáctico.

[↑ Volver al índice](#-índice)

---

## 🚀 Flujo completo paso a paso (Docker)

Asumimos:

- Contenedor llamado `postgres_piscineds` (como en EX00).  
- Base `piscineds`, usuario = **tu login de 42**, contraseña = `mysecretpassword`.  
- CSV de ejemplo: `data_2022_dec.csv` en la carpeta `customer/` del subject.

Adapta nombres y rutas a tu caso.

---

### Paso 0 — Contenedor en marcha

```bash
docker ps
```

Debes ver `postgres_piscineds`. Si no:

```bash
cd ruta/a/ex00
docker-compose up -d
```

---

### Paso 1 — Localizar el CSV

```bash
find /sgoinfre/students/$(whoami) -name 'data_2022_dec.csv' 2>/dev/null
# o busca en la carpeta del subject de tu proyecto
```

Anota la **ruta completa**.

Comprueba la cabecera:

```bash
head -n 2 "RUTA_COMPLETA/data_2022_dec.csv"
```

---

### Paso 2 — Escribir `ex02/table.sql`

Crea el archivo `ex02/table.sql` con algo como:

```sql
-- Quitar la tabla si ya existía (reintentos limpios)
DROP TABLE IF EXISTS data_2022_dec;

-- Crear la tabla (todas las columnas del CSV, ≥ 6 tipos)
CREATE TABLE data_2022_dec (
    event_time    TIMESTAMPTZ,     -- cuándo
    event_type    VARCHAR(50),     -- qué acción
    product_id    INTEGER,         -- qué producto
    price         NUMERIC(10,2),   -- precio
    user_id       BIGINT,          -- qué usuario
    user_session  UUID             -- qué sesión
);

-- Cargar el CSV (ruta DENTRO del contenedor)
COPY data_2022_dec
FROM '/tmp/data_2022_dec.csv'
WITH (FORMAT csv, HEADER true);
```

---

### Paso 3 — Copiar el CSV al contenedor

```bash
docker cp "RUTA_COMPLETA/data_2022_dec.csv" \
  postgres_piscineds:/tmp/data_2022_dec.csv
```

En algunos campus aparece un aviso `Lchown` / `invalid argument`.  
Si después el fichero **existe**, puedes ignorarlo:

```bash
docker exec postgres_piscineds ls -la /tmp/data_2022_dec.csv
```

---

### Paso 4 — Copiar el SQL al contenedor

```bash
docker cp ruta/a/ex02/table.sql postgres_piscineds:/tmp/table.sql
docker exec postgres_piscineds ls -la /tmp/table.sql
```

---

### Paso 5 — Ejecutar el SQL

```bash
docker exec -it postgres_piscineds \
  psql -U "$(whoami)" -d piscineds -W -f /tmp/table.sql
```

Contraseña: `mysecretpassword`

Salida deseable:

```text
DROP TABLE
CREATE TABLE
COPY 3533286
```

(El número de filas depende del CSV; lo importante es que aparezca `COPY` seguido de un entero.)

---

### Paso 6 — Comprobar (comandos de uno en uno)

```bash
docker exec -it postgres_piscineds \
  psql -U "$(whoami)" -d piscineds -W
```

Dentro de `psql`, **Enter después de cada línea**:

```sql
\d data_2022_dec
```

```sql
SELECT COUNT(*) FROM data_2022_dec;
```

```sql
SELECT * FROM data_2022_dec LIMIT 5;
```

```sql
\q
```

También puedes revisar la tabla en pgAdmin (EX01):  
**Databases → piscineds → Schemas → public → Tables**.

[↑ Volver al índice](#-índice)

---

## ⌨️ Comandos útiles dentro de psql

| Comando | Qué hace |
|---------|----------|
| `\dt` | Lista tablas |
| `\d nombre_tabla` | Describe columnas y tipos |
| `\conninfo` | Muestra a qué base/usuario estás conectado |
| `\q` | Salir de `psql` |
| `SELECT COUNT(*) FROM nombre_tabla;` | Cuántas filas hay |
| `SELECT * FROM nombre_tabla LIMIT 5;` | Primeras 5 filas |

**Importante:** los comandos que empiezan por `\` son de **psql** (el cliente).  
Los que terminan en `;` son **SQL**.  
No pegues varios de golpe la primera vez: ejecuta uno, mira el resultado, luego el siguiente.

[↑ Volver al índice](#-índice)

---

## ✅ Comprobar que todo está bien

Señales de éxito:

1. `\d data_2022_dec` muestra las 6 columnas con tipos razonables.  
2. `COUNT(*)` devuelve un número grande (> 0).  
3. `LIMIT 5` muestra filas parecidas a las del CSV.  
4. La primera columna es de tipo fecha/hora.  
5. Hay al menos 6 tipos distintos en la definición de la tabla.

Ejemplo de aspecto correcto de `\d`:

```text
 event_time   | timestamp with time zone
 event_type   | character varying(50)
 product_id   | integer
 price        | numeric(10,2)
 user_id      | bigint
 user_session | uuid
```

[↑ Volver al índice](#-índice)

---

## 🛠️ Errores frecuentes y cómo resolverlos

### 1. `syntax error at or near "DELIMITER"`

**Causa:** sintaxis antigua o incorrecta en el `COPY`.

**Solución:** usa solo:

```sql
COPY data_2022_dec
FROM '/tmp/data_2022_dec.csv'
WITH (FORMAT csv, HEADER true);
```

---

### 2. `could not open file "/home/..."` / permission denied

**Causa:** `COPY` busca la ruta **dentro del contenedor**.

**Solución:** `docker cp` del CSV a `/tmp/...` y usa esa ruta en el `COPY`.

---

### 3. Aviso `Lchown` al hacer `docker cp`

**Causa:** limitación de UIDs en el Docker del campus.

**Qué hacer:** comprueba con `docker exec ... ls -la /tmp/archivo`.  
Si el fichero está y tiene tamaño > 0, **continúa**.

---

### 4. Error de tipo en `event_time`

**Prueba:** cambia `TIMESTAMPTZ` por `TIMESTAMP` (o al revés), vuelve a ejecutar el script completo (`DROP` + `CREATE` + `COPY`).

---

### 5. Error de tipo en `user_session` (UUID)

**Prueba:**

```sql
user_session  VARCHAR(36)
```

y asegúrate de seguir teniendo 6 tipos distintos en total.

---

### 6. `password authentication failed`

Usuario = **tu login de 42** (el de `POSTGRES_USER` / `.env`).  
Contraseña = `mysecretpassword`.

```bash
cat ruta/a/ex00/.env
```

---

### 7. Pegaste varios comandos a la vez en psql

`\d` se confunde y dice `extra argument ignored`.  
Solución: un comando → Enter → leer resultado → siguiente.

[↑ Volver al índice](#-índice)

---

## 📁 Archivo a entregar (`table.*`)

El subject indica entregar en `ex02/` un fichero del estilo **`table.*`**.

Opciones habituales:

| Archivo | Contenido típico |
|---------|------------------|
| `table.sql` | `DROP` + `CREATE` + `COPY` (o instrucciones claras) |
| `table.py` | Script Python que conecta, crea la tabla y carga el CSV |

Lo evaluable es que **se pueda crear y llenar la tabla** de forma reproducible, no solo que exista “a mano” en tu máquina un día concreto.

Recomendación: deja en el repo un `table.sql` limpio (como el de esta guía) y, si usas pasos Docker, documenta en el README de EX02 el `docker cp` y el comando de ejecución.

[↑ Volver al índice](#-índice)

---

## ☑️ Checklist de evaluación

Antes de la corrección, comprueba:

- [ ] Existe `ex02/table.sql` (o `table.py`, etc.)
- [ ] El nombre de la tabla = nombre del CSV sin extensión
- [ ] Columnas = nombres exactos del CSV
- [ ] Primera columna = tipo fecha/hora
- [ ] Al menos **6 tipos de datos distintos**
- [ ] Tipos apropiados (no todo texto)
- [ ] `SELECT COUNT(*)` > 0
- [ ] Sabes explicar qué significa cada columna
- [ ] Sabes explicar por qué usaste `COPY` y no miles de `INSERT`
- [ ] PostgreSQL arranca y te puedes conectar (EX00)
- [ ] (Opcional pero útil) Ves la tabla en pgAdmin (EX01)

[↑ Volver al índice](#-índice)

---

## 📖 Mini glosario

| Término | Significado breve |
|---------|-------------------|
| SQL | Lenguaje para hablar con la base de datos |
| PostgreSQL | El motor de base de datos que usamos |
| Base de datos | Contenedor lógico de tablas (`piscineds`) |
| Tabla | Conjunto de filas con las mismas columnas |
| Columna | Un campo (precio, fecha, id…) |
| Fila | Un registro concreto |
| CSV | Fichero de texto con valores separados por comas |
| `CREATE TABLE` | Crear la estructura de una tabla |
| `DROP TABLE` | Eliminar una tabla |
| `COPY` | Carga masiva desde fichero |
| `SELECT` | Consultar datos |
| `psql` | Cliente en terminal para PostgreSQL |
| `TIMESTAMPTZ` | Fecha y hora con zona horaria |
| Primary key | Identificador único de fila (EX02 no la exige) |

[↑ Volver al índice](#-índice)

---

## 🔗 Navegación

- [← README de EX02](README.md)
- [← README principal](../README.md)
- [← EX00](../ex00/README.md)
- [← EX01](../ex01/README.md)
- [Guía pgAdmin](../ex01/pgAdmin.md)
- [Siguiente: EX03 →](../ex03/README.md)

---

*Piscine Data Science – Module 0 – EX02 – Guía SQL*  
sternero – 42 Málaga – Septiembre de 2026*
