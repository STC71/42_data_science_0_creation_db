# 📦 Ejercicio 04 – Items table

<p align="center">
  <img src="../imgs/banner_04.jpg" alt="Piscine Data Science – Module 0 – ex04" width="100%">
</p>

[← Volver al README principal](../README.md)

---

## 🎯 ¿Qué se pide exactamente?

Crear una tabla llamada **`items`** a partir del archivo CSV que está en la carpeta `items/` (normalmente `item.csv` o `items.csv`).

### Condiciones

| Requisito | Detalle |
|-----------|---------|
| Nombre de la tabla | Exactamente **`items`** |
| Nombres de columnas | Deben coincidir con los del CSV |
| Tipos de datos | Al menos **3 tipos de datos diferentes** |
| Tipos apropiados | Elige el tipo correcto para cada columna |

---

## 📁 Archivos a entregar

Dentro de `ex04/` debes entregar un archivo llamado `items_table.*`  
(puede ser `.sql`, `.py`, `.sh`…).

---

## 🧠 Explicación sencilla

Hasta ahora has trabajado con los datos de **eventos de clientes** (compras, vistas, etc.).  

Este ejercicio crea la tabla de **productos / artículos**.  

Es como crear la estantería donde se guardan las fichas de cada producto que vende la tienda (id, categoría, marca…).

---

## 📂 Estructura esperada

```
./items/
└── item.csv          (o items.csv)
```

### Columnas reales del archivo `item.csv` (según el subject de este repo)

```
product_id,category_id,category_code,brand
```

---

## 🚀 Cómo implementarlo paso a paso

### Paso 1: Mirar el CSV

Las columnas son:

- `product_id` → número grande → `BIGINT`
- `category_id` → número grande → `BIGINT`
- `category_code` → texto (puede estar vacío) → `VARCHAR(255)`
- `brand` → texto (puede estar vacío) → `VARCHAR(100)`

Con estos 4 campos ya tienes **más de 3 tipos diferentes**.

### Paso 2: Crear el script

#### Opción A – SQL puro

Crea el archivo `ex04/items_table.sql`:

```sql
DROP TABLE IF EXISTS items;

CREATE TABLE items (
    product_id      BIGINT,             -- 1
    category_id     BIGINT,             -- 2
    category_code   VARCHAR(255),       -- 3
    brand           VARCHAR(100)        -- 4
);

-- Importación rápida
COPY items
FROM '/ruta/completa/al/archivo/item.csv'
WITH (FORMAT csv, HEADER true);
```

#### Opción B – Python

Puedes reutilizar casi el mismo código del ejercicio 03, cambiando solo el nombre de la tabla y la ruta del CSV.

### Paso 3: Ejecutar y verificar

```bash
psql -U tu_login -d piscineds -h localhost -W -f items_table.sql
```

Dentro de `psql`:

```sql
\dt                          -- Debe aparecer la tabla "items"
SELECT COUNT(*) FROM items;
SELECT * FROM items LIMIT 10;
\d items                     -- Ver la estructura
```

---

## ✅ Checklist de este ejercicio

- [ ] La tabla se llama exactamente `items`
- [ ] Los nombres de las columnas coinciden con el CSV
- [ ] Hay al menos 3 tipos de datos diferentes
- [ ] Los datos se han importado correctamente
- [ ] El archivo se llama `items_table.*`

---

## 💡 Nota importante

Algunas filas del CSV tienen campos vacíos (`category_code` o `brand`).  
PostgreSQL los acepta sin problema si no pones `NOT NULL`.

---

## 🔗 Navegación

- [← README principal](../README.md)
- [← Ejercicio anterior: ex03](../ex03/README.md)

---

*Piscine Data Science – sternero – 42 Málaga – Septiembre de 2026*