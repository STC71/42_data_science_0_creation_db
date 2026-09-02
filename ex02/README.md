# 📄 Ejercicio 02 – First table

<p align="center">
  <img src="../imgs/banner_02.jpg" alt="Piscine Data Science – Module 0 – ex02" width="100%">
</p>

[← Volver al README principal](../README.md)

---

## 🎯 ¿Qué se pide exactamente?

Crear **una sola tabla** en PostgreSQL a partir de **un archivo CSV** que se encuentra en la carpeta `customer/`.

### Condiciones obligatorias del subject

| Requisito | Detalle |
|-----------|---------|
| Nombre de la tabla | Exactamente el nombre del CSV **sin la extensión**<br>Ejemplo: `data_2022_oct.csv` → tabla `data_2022_oct` |
| Nombres de columnas | Deben coincidir **exactamente** con los del CSV |
| Primera columna | Debe ser de tipo **DATETIME** (en PostgreSQL se llama `TIMESTAMP`) |
| Tipos de datos | Debes usar **al menos 6 tipos de datos diferentes** |
| Tipos apropiados | No puedes poner todo como `TEXT`. Elige el tipo correcto para cada columna |

> ⚠️ **Importante:** Los tipos de datos de PostgreSQL **no son iguales** a los de MariaDB/MySQL. Investiga los correctos.

---

## 📁 Archivos a entregar

Dentro de `ex02/` debes entregar un archivo llamado `table.*`  
(puede ser `.sql`, `.py`, `.sh`… el que uses).

---

## 🧠 Explicación sencilla

Un archivo CSV es como una hoja de Excel guardada en texto plano.  
Cada fila es un registro y cada columna es un tipo de información.

Crear una tabla es como preparar una estantería específica dentro del almacén:

- Decides el nombre de la estantería (`data_2022_oct`)
- Decides qué cajones tendrá (las columnas)
- Decides el tipo de cada cajón (número, texto, fecha…)
- Luego vuelcas el contenido del CSV dentro de esa estantería.

---

## 🚀 Cómo implementarlo paso a paso

### Paso 1: Mirar el contenido del CSV

Abre el archivo CSV (por ejemplo `data_2022_oct.csv`) y mira la **primera línea** (la cabecera).  

Ejemplo típico de cabecera en este proyecto:

```
event_time,event_type,product_id,category_id,category_code,brand,price,user_id,user_session
```

### Paso 2: Decidir los tipos de datos (mínimo 6 diferentes)

Aquí tienes una propuesta típica y correcta:

| Columna         | Tipo PostgreSQL     | Por qué |
|-----------------|---------------------|---------|
| event_time      | `TIMESTAMP`         | Es una fecha y hora (obligatorio primero) |
| event_type      | `VARCHAR(50)`       | Texto corto |
| product_id      | `BIGINT`            | Número entero grande |
| category_id     | `BIGINT`            | Número entero grande |
| category_code   | `VARCHAR(255)`      | Texto más largo |
| brand           | `VARCHAR(100)`      | Texto medio |
| price           | `NUMERIC(10,2)`     | Número con decimales (precio) |
| user_id         | `BIGINT`            | Número entero grande |
| user_session    | `UUID` o `VARCHAR`  | Identificador de sesión |

Con esta lista ya tienes **más de 6 tipos diferentes**.

### Paso 3: Crear el script

#### Opción A – Script SQL puro (recomendado para empezar)

Crea el archivo `ex02/table.sql`:

```sql
-- Borrar la tabla si ya existe (útil para pruebas)
DROP TABLE IF EXISTS data_2022_oct;

-- Crear la tabla
CREATE TABLE data_2022_oct (
    event_time      TIMESTAMP,          -- 1. DATETIME obligatorio
    event_type      VARCHAR(50),        -- 2
    product_id      BIGINT,             -- 3
    category_id     BIGINT,             -- 4
    category_code   VARCHAR(255),       -- 5
    brand           VARCHAR(100),       -- 6
    price           NUMERIC(10,2),      -- 7
    user_id         BIGINT,             -- 8
    user_session    VARCHAR(100)        -- 9
);

-- Importar los datos de forma rápida y eficiente
COPY data_2022_oct
FROM '/ruta/completa/al/archivo/data_2022_oct.csv'
WITH (FORMAT csv, HEADER true);
```

#### Opción B – Script Python (más flexible)

Puedes usar `psycopg2` + `pandas` o solo `psycopg2`.

### Paso 4: Ejecutar el script

```bash
# Si es un archivo .sql
psql -U tu_login -d piscineds -h localhost -W -f table.sql

# O desde dentro de psql:
\i /ruta/a/table.sql
```

### Paso 5: Verificar

```sql
-- Ver que la tabla existe
\dt

-- Contar las filas
SELECT COUNT(*) FROM data_2022_oct;

-- Ver las primeras filas
SELECT * FROM data_2022_oct LIMIT 5;

-- Ver la estructura de la tabla
\d data_2022_oct
```

---

## 💡 Consejos importantes

1. **Usa siempre `COPY`** en vez de `INSERT` fila a fila. Es muchísimo más rápido.
2. La ruta del CSV debe ser accesible desde el contenedor Docker (puedes montar un volumen o copiar el archivo dentro).
3. Si hay valores vacíos o nulos, PostgreSQL los acepta si la columna no tiene `NOT NULL`.
4. Prueba primero con un CSV pequeño para no perder tiempo.

---

## ✅ Checklist de este ejercicio

- [ ] La tabla se llama exactamente como el CSV (sin `.csv`)
- [ ] La primera columna es `TIMESTAMP`
- [ ] Hay al menos 6 tipos de datos diferentes
- [ ] Los nombres de las columnas coinciden con el CSV
- [ ] Los datos se han importado correctamente
- [ ] El archivo se llama `table.*`

---

## 🔗 Navegación

- [← README principal](../README.md)
- [← Ejercicio anterior: ex01](../ex01/README.md)
- [Siguiente ejercicio: ex03 →](../ex03/README.md)

---

*Piscine Data Science – sternero – 42 Málaga – Septiembre de 2026*