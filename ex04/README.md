# 📦 Ejercicio 04 – Items table

<p align="center">
  <img src="../imgs/banner_04.jpg" alt="Piscine Data Science – Module 0 – ex04" width="100%">
</p>

[← Volver al README principal](../README.md)

---

## 📑 Índice

1. [¿Qué se pide exactamente?](#-qué-se-pide-exactamente)
2. [Archivos a entregar](#-archivos-a-entregar)
3. [Explicación sencilla](#-explicación-sencilla)
4. [Datos reales del ejercicio](#-datos-reales-del-ejercicio)
5. [Cómo implementarlo](#-cómo-implementarlo)
6. [Ejecutar el script paso a paso](#-ejecutar-el-script-paso-a-paso)
7. [Comprobar el resultado](#-comprobar-el-resultado)
8. [Errores frecuentes](#-errores-frecuentes)
9. [Checklist](#-checklist-de-este-ejercicio)
10. [Navegación](#-navegación)

---

## 🎯 ¿Qué se pide exactamente?

Crear una tabla llamada **`items`** a partir del CSV de productos del subject.

### Condiciones

| Requisito | Detalle |
|-----------|---------|
| Archivo de origen | `item.csv` |
| Tabla | Debe llamarse exactamente `items` |
| Columnas | Deben coincidir con la cabecera del CSV |
| Tipos | Al menos 3 tipos de datos diferentes y apropiados |
| Entrega | `ex04/items_table.*` |

[↑ Volver al índice](#-índice)

---

## 📁 Archivos a entregar

Dentro de `ex04/`:

```text
items_table.*    # .sql, .py, .sh, …
```

En este repositorio se utiliza:

| Archivo | Rol |
|---------|-----|
| [`items_table.sql`](./items_table.sql) | Elimina y crea la tabla `items` |

La carga del CSV se ejecuta aparte con `COPY`, porque el archivo está en el host y PostgreSQL funciona dentro de Docker.

[↑ Volver al índice](#-índice)

---

## 🧠 Explicación sencilla

En los ejercicios anteriores se crearon tablas con eventos de clientes. En EX04 se crea una tabla de catálogo: cada registro representa un producto y sus datos de categoría y marca.

El flujo es:

1. Localizar el CSV.
2. Leer su cabecera para conocer las columnas.
3. Crear la tabla `items` con tipos adecuados.
4. Copiar el CSV al contenedor de PostgreSQL.
5. Cargar sus filas con `COPY`.
6. Comprobar la estructura y el número de registros.

[↑ Volver al índice](#-índice)

---

## 📂 Datos reales del ejercicio

En este repositorio, el archivo se encuentra en:

```text
./subject/item/item.csv
```

La carpeta se llama `item` en singular. La cabecera real es:

```text
product_id,category_id,category_code,brand
```

Las primeras filas muestran que `category_code` y `brand` pueden estar vacíos:

```text
product_id,category_id,category_code,brand
5712790,1487580005268456192,,f.o.x
5764655,1487580005411062528,,cnd
4958,1487580009471148032,,runail
5848413,1487580007675986944,,freedecor
```

[↑ Volver al índice](#-índice)

---

## 🚀 Cómo implementarlo

### Elección de tipos

| Columna | Tipo SQL | Motivo |
|---------|----------|--------|
| `product_id` | `INTEGER` | Sus valores caben en un entero estándar |
| `category_id` | `BIGINT` | Puede contener números muy grandes |
| `category_code` | `VARCHAR(255)` | Texto y puede estar vacío |
| `brand` | `VARCHAR(100)` | Texto y puede estar vacío |

Estos campos utilizan tres tipos SQL apropiados: `INTEGER`, `BIGINT` y `VARCHAR`.

### Crear `items_table.sql`

El archivo entregado contiene:

```sql
DROP TABLE IF EXISTS items;

CREATE TABLE items (
  product_id      INTEGER,
  category_id     BIGINT,
  category_code   VARCHAR(255),
  brand           VARCHAR(100)
);
```

La instrucción `COPY` se ejecuta después desde `/tmp/item.csv`, que es la ruta visible dentro del contenedor.

### Alternativa Python

También sería válido crear un `items_table.py` reutilizando el patrón de EX03: conectar a PostgreSQL, crear la tabla `items` y cargar el CSV con `copy_expert`. Para este ejercicio, el SQL separado hace más visible cada etapa.

[↑ Volver al índice](#-índice)

---

## ▶️ Ejecutar el script paso a paso

### 1. Localizar el CSV

Desde `data_science_0_creation_db/`:

```bash
find . -iname '*item*.csv' 2>/dev/null
```

Resultado esperado:

```text
./subject/item/item.csv
```

Puedes comprobar la cabecera y algunas filas:

```bash
head -n 5 ./subject/item/item.csv
```

### 2. Crear la carpeta de EX04 (Si no lo está ya)

```bash
mkdir -p ex04
```

### 3. Comprobar que PostgreSQL está activo

```bash
docker ps | grep postgres_piscineds
```

Debe aparecer el contenedor `postgres_piscineds` en estado `Up`.

### 4. Copiar los archivos al contenedor

```bash
docker cp ./subject/item/item.csv postgres_piscineds:/tmp/item.csv
docker cp ./ex04/items_table.sql postgres_piscineds:/tmp/items_table.sql
```

En algunos entornos del campus aparece un aviso como este después de copiar:

```text
Error response from daemon: failed to Lchown ... invalid argument
```

Si antes aparece `Successfully copied`, el archivo se ha copiado correctamente. El aviso se debe a los permisos del entorno Docker; no impide continuar cuando los archivos existen dentro del contenedor.

### 5. Crear la tabla

```bash
docker exec -it postgres_piscineds \
  psql -U "$(whoami)" -d piscineds -W -f /tmp/items_table.sql
```

Salida normal en la primera ejecución:

```text
NOTICE:  table "items" does not exist, skipping
DROP TABLE
CREATE TABLE
```

El `NOTICE` no es un error: `DROP TABLE IF EXISTS` avisa de que todavía no había una tabla que borrar y después `CREATE TABLE` confirma que se ha creado.

### 6. Cargar los datos

```bash
docker exec -it postgres_piscineds \
  psql -U "$(whoami)" -d piscineds -W -c \
  "COPY items FROM '/tmp/item.csv' WITH (FORMAT csv, HEADER true);"
```

Resultado obtenido con el CSV de este repositorio:

```text
COPY 109579
```

Esto significa que PostgreSQL ha insertado `109579` registros en `items`.

[↑ Volver al índice](#-índice)

---

## ✅ Comprobar el resultado

Abrir una sesión de PostgreSQL dentro del contenedor:

```bash
docker exec -it postgres_piscineds \
  psql -U "$(whoami)" -d piscineds -W
```

Dentro de `psql`, ejecutar cada consulta por separado:

```sql
\d items
```

Debe aparecer una estructura equivalente a:

```text
Column        | Type
--------------+------------------------
product_id    | integer
category_id   | bigint
category_code | character varying(255)
brand         | character varying(100)
```

Contar los registros:

```sql
SELECT COUNT(*) FROM items;
```

Resultado esperado:

```text
 count
--------
 109579
```

Ver algunas filas:

```sql
SELECT * FROM items LIMIT 5;
```

Para salir:

```sql
\q
```

<p align="center">
  <img src="./imgs/psql_02.png" alt="Vista de los comandos desde la terminal." width="100%">
</p>

#### La tabla también puede revisarse desde pgAdmin (ver EX01)...

<p align="center">
  <img src="./imgs/img_pgAdmin_08.png" alt="Captura de pgAdmin con las cuatro tablas incluidas + items_table" width="100%">
</p>

[↑ Volver al índice](#-índice)

---

## 🛠️ Errores frecuentes

| Síntoma | Qué significa o qué hacer |
|---------|---------------------------|
| `find` devuelve `./subject/item/item.csv` | La carpeta correcta es `item`, en singular |
| `head ./subject/items/item.csv` falla | La ruta contiene `items`, pero debe ser `item` |
| `NOTICE: table "items" does not exist, skipping` | Mensaje normal de `DROP TABLE IF EXISTS` en la primera ejecución |
| `failed to Lchown` después de `Successfully copied` | Aviso de permisos del campus; comprobar que el archivo está en `/tmp` y continuar |
| `COPY 109579` | Carga correcta de 109579 registros |
| `connection refused` | Arrancar PostgreSQL desde `ex00` con Docker Compose |
| `invalid input syntax` | Revisar que las columnas y tipos coinciden con la cabecera del CSV |

[↑ Volver al índice](#-índice)

---

## ✅ Checklist de este ejercicio

| Requisito | ¿Hecho? |
|-----------|---------|
| Se ha localizado el CSV real | ✅ |
| La tabla se llama exactamente `items` | ✅ |
| Los nombres de columnas coinciden con el CSV | ✅ |
| Se han utilizado tipos apropiados | ✅ |
| Hay al menos 3 tipos de datos diferentes | ✅ |
| Los tipos de datos son apropiados para las columnas | ✅ |
| Se han cargado los datos con `COPY` | ✅ |
| `COUNT(*)` devuelve `109579` | ✅ |
| Archivo `items_table.sql` preparado | ✅ |

[↑ Volver al índice](#-índice)

---

## 🔗 Navegación

- [← README principal](../README.md)
- [← Ejercicio anterior: ex03](../ex03/README.md)

---
