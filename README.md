# 📊 Piscine Data Science – Module 0  

<p align="center">
  <img src="https://img.shields.io/badge/42-School-000000?style=for-the-badge&logo=42&logoColor=white" alt="42 School">
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker">
  <img src="https://img.shields.io/badge/Data%20Engineer-FF6B6B?style=for-the-badge" alt="Data Engineer">
</p>

---

## 🎯 ¿De qué trata este proyecto?

Creación de una base de datos (DB)...

Imagina que es tu **primer día** en una empresa que vende productos por Internet (como una versión pequeña de Amazon o Zara online).  

Es finales de febrero de 2023. Tu jefe se va de viaje y te deja una carpeta llena de archivos CSV con **todas las ventas de los últimos 4 meses**.  

Tu misión como **Data Engineer** es:

1. Crear un “almacén digital” (una base de datos) limpio y bien organizado.
2. Meter todos esos datos de forma correcta y eficiente.
3. Dejarlos listos para que los analistas y data scientists puedan estudiarlos y proponer ideas para **aumentar la facturación** de la empresa.

Si no lo haces bien (tipos de datos incorrectos, tablas mal nombradas, datos sin limpiar…), más adelante te quedarás bloqueado. Por eso este módulo es la base de todo lo que viene después.

> 💡 **Analogía de la vida real**  
> Es como recibir cientos de cajas de cartón desordenadas con tickets de compra, facturas y listados de productos.  
> En vez de dejarlas tiradas por el suelo, construyes un almacén moderno con estanterías etiquetadas, códigos de barras y un sistema de búsqueda instantánea.

---

## 🧠 Rol del Data Engineer (lo que realmente estás aprendiendo)

En los dos primeros módulos de la piscine verás el trabajo de un **Data Engineer**:

- Recibe datos “crudos” (CSV, logs, APIs…).
- Los limpia, organiza y transforma.
- Los almacena de forma eficiente y segura.
- Los deja listos para que los Data Scientists / Analysts puedan analizarlos sin perder tiempo.

Este módulo se centra en la **creación y carga inicial** de la base de datos.

---

## 📋 Estructura general del proyecto

Debes entregar tu trabajo en las carpetas siguientes (exactamente con estos nombres):

```
ex00/          → Crear la base de datos PostgreSQL
ex01/          → Visualizar la base de datos con una herramienta gráfica
ex02/          → Crear la primera tabla manualmente
ex03/          → Crear automáticamente todas las tablas de customer/
ex04/          → Crear la tabla items
```

---

## ⚙️ Requisitos generales (Chapter I)

- Trabaja desde un ordenador del cluster (VM o máquina física).
- Si usas VM, instala y configura todo lo necesario.
- Si usas la máquina del campus, asegúrate de tener espacio (usa `goinfre` si tu campus lo tiene).
- Todo debe estar instalado **antes** de las evaluaciones.
- Tus programas no deben fallar de forma inesperada (segfault, etc.).
- Se recomienda crear tests (no se entregan ni se evalúan, pero son muy útiles).
- Solo se evalúa lo que esté en tu repositorio Git.
- La evaluación se hace en el ordenador del alumno que está siendo evaluado.

---

## 🛠️ Ejercicio 00 – Create Postgres DB

**Carpeta de entrega:** `ex00/`  
**Archivos:** `docker-compose.yml` **o** `setup.sh` **o** `VM-instructions.txt`

### Objetivo
Crear una base de datos PostgreSQL lista para usar.

### Condiciones obligatorias
| Parámetro          | Valor obligatorio          |
|--------------------|----------------------------|
| Usuario            | Tu login de estudiante     |
| Nombre de la BD    | `piscineds`                |
| Contraseña         | `mysecretpassword`         |

Debemos poder conectarnos con este comando:

```bash
psql -U tu_login -d piscineds -h localhost -W
# Cuando pida la contraseña → mysecretpassword
```

### Cómo implementarlo desde cero

#### Opción recomendada: Docker Compose (estándar Inception)

1. Crea un archivo `docker-compose.yml`:

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15
    container_name: postgres_piscineds
    environment:
      POSTGRES_USER: tu_login          # ← cambia por tu login
      POSTGRES_PASSWORD: mysecretpassword
      POSTGRES_DB: piscineds
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  postgres_data:
```

2. Arranca el servicio:

```bash
docker-compose up -d
```

3. Verifica que funciona:

```bash
psql -U tu_login -d piscineds -h localhost -W
```

> 📌 Si prefieres no usar Docker, puedes instalar PostgreSQL nativo o en una VM y documentar los pasos en `setup.sh` o `VM-instructions.txt`.

---

## 🖥️ Ejercicio 01 – Show me your DB

**Carpeta de entrega:** `ex01/`

### Objetivo
Encontrar y configurar una herramienta gráfica para visualizar y manipular fácilmente tu base de datos (especialmente navegando por IDs de registros).

### Herramientas permitidas
- **pgAdmin** (la más común y recomendada)
- Postico (Mac)
- DBeaver
- Cualquier otra de tu elección

### Cómo implementarlo
1. Instala pgAdmin (o la herramienta que elijas).
2. Conéctala a tu PostgreSQL:
   - Host: `localhost`
   - Port: `5432`
   - Database: `piscineds`
   - Username: tu login
   - Password: `mysecretpassword`
3. Demuestra que puedes navegar por las tablas y ver los registros fácilmente.

---

## 📄 Ejercicio 02 – First table

**Carpeta de entrega:** `ex02/`  
**Archivos:** `table.*` (script SQL, Python, bash… lo que uses)

### Objetivo
Crear **una sola tabla** a partir de **un CSV** de la carpeta `customer/`.

### Condiciones estrictas
- Nombre de la tabla = nombre del CSV **sin la extensión**  
  Ejemplo: `data_2022_oct.csv` → tabla `data_2022_oct`
- Los nombres de las columnas deben coincidir **exactamente** con los del CSV.
- Debes usar **al menos 6 tipos de datos diferentes**.
- La **primera columna** debe ser de tipo **DATETIME** (o `TIMESTAMP`).
- Los tipos de datos deben ser **apropiados** (no todo `TEXT`).

> ⚠️ PostgreSQL tiene tipos de datos distintos a MariaDB/MySQL. Investiga los correctos (`TIMESTAMP`, `BIGINT`, `NUMERIC`, `VARCHAR`, `BOOLEAN`, etc.).

### Cómo implementarlo desde cero

1. Mira la estructura del CSV (cabecera + algunas filas).
2. Crea el script que:
   - Crea la tabla con los tipos correctos.
   - Importa los datos de forma eficiente (recomendado: `COPY` de PostgreSQL).

Ejemplo de estructura típica (adapta a tu CSV real):

```sql
CREATE TABLE data_2022_oct (
    event_time      TIMESTAMP,          -- 1. DATETIME (obligatorio primero)
    event_type      VARCHAR(50),        -- 2
    product_id      BIGINT,             -- 3
    category_id     BIGINT,             -- 4
    category_code   VARCHAR(255),       -- 5
    brand           VARCHAR(100),       -- 6
    price           NUMERIC(10,2),      -- 7
    user_id         BIGINT,             -- 8
    user_session    UUID                -- 9 (opcional extra)
);
```

Luego importa con:

```sql
COPY data_2022_oct FROM '/ruta/al/archivo.csv' 
WITH (FORMAT csv, HEADER true);
```

---

## 🤖 Ejercicio 03 – Automatic table

**Carpeta de entrega:** `ex03/`  
**Archivos:** `automatic_table.*`

### Objetivo
Automatizar completamente la creación de tablas para **todos** los CSV que haya en la carpeta `customer/`.

### Condiciones
- Lee automáticamente todos los `.csv` de `customer/`.
- Crea una tabla por cada uno.
- Nombre de la tabla = nombre del archivo sin extensión.
- Misma lógica de tipos de datos que en el ejercicio 02 (al menos 6 tipos diferentes, DATETIME primero, etc.).

### Estructura de directorios esperada (ejemplo del subject)

```
.
├── customer/
│   ├── data_2022_dec.csv
│   ├── data_2022_nov.csv
│   ├── data_2022_oct.csv
│   └── data_2023_jan.csv
└── items/
    └── items.csv
```

### Cómo implementarlo
Puedes usar:
- Un script en **Python** (psycopg2 + pandas o solo SQL)
- Un script **Bash** + `psql`
- Un script SQL dinámico

Lo importante es que sea **automático**: no hardcodees los nombres de los archivos.

---

## 📦 Ejercicio 04 – Items table

**Carpeta de entrega:** `ex04/`  
**Archivos:** `items_table.*`

### Objetivo
Crear la tabla `items` a partir del archivo `items.csv` (o `item.csv`) que está en la carpeta `items/`.

### Condiciones
- Nombre de la tabla: **`items`** (exactamente).
- Nombres de columnas = los del CSV.
- Al menos **3 tipos de datos diferentes**.

### Estructura esperada

```
./items/
└── items.csv
```

---

## 🚀 Guía de implementación completa desde cero (recomendación práctica)

### 1. Preparación del entorno
```bash
# Clona tu repo
git clone <tu-repo>
cd piscine_data_science_0

# Crea la estructura de carpetas
mkdir -p ex00 ex01 ex02 ex03 ex04
```

### 2. Arranca PostgreSQL (ex00)
```bash
cd ex00
# Crea tu docker-compose.yml
docker-compose up -d
```

### 3. Configura la herramienta gráfica (ex01)
Instala y conecta pgAdmin.

### 4. Crea la primera tabla (ex02)
Escribe y prueba tu script hasta que la tabla se cree e importe correctamente.

### 5. Automatiza (ex03)
Convierte el script del ejercicio 02 en un bucle que procese todos los CSV de `customer/`.

### 6. Crea la tabla items (ex04)
Haz un script específico (o reutiliza lógica) para `items.csv`.

### 7. Verifica todo
```sql
\dt                          -- Lista todas las tablas
SELECT COUNT(*) FROM data_2022_oct;
SELECT * FROM items LIMIT 5;
```

---

## ✅ Checklist final antes de entregar

- [ ] `ex00/` tiene el archivo correcto y la BD se puede conectar con los datos obligatorios.
- [ ] `ex01/` permite visualizar la BD fácilmente.
- [ ] `ex02/` crea una tabla con ≥ 6 tipos de datos y DATETIME como primera columna.
- [ ] `ex03/` crea automáticamente **todas** las tablas de `customer/`.
- [ ] `ex04/` crea la tabla `items` con ≥ 3 tipos de datos.
- [ ] Nombres de carpetas y archivos son **exactos**.
- [ ] Todo está en tu repositorio Git.
- [ ] Puedes demostrar todo en la evaluación.

---

## 💡 Consejos de oro

1. **Usa `COPY`** en vez de `INSERT` fila a fila → es **mucho** más rápido.
2. Comprueba siempre los tipos de datos reales del CSV antes de definir la tabla.
3. Si un CSV tiene valores nulos o formatos raros de fecha, prepárate para manejarlos.
4. Documenta bien tus scripts (comentarios claros).
5. Prueba todo desde cero en una máquina limpia antes de la evaluación.

---

## 📚 Recursos útiles

- [Documentación oficial de PostgreSQL – Data Types](https://www.postgresql.org/docs/current/datatype.html)
- [Documentación de COPY](https://www.postgresql.org/docs/current/sql-copy.html)
- [Docker Compose – PostgreSQL](https://hub.docker.com/_/postgres)
- Subject oficial de Inception (para buenas prácticas de Docker)

---

<p align="center">
  <strong>¡Éxito con el Day 0!</strong><br>
  Este es el cimiento de toda la piscine de Data Science.<br>
  Hazlo bien y el resto será mucho más fácil.
</p>

---


*Piscine Data Science – Module 0 – Creation of a DB – Version 1.2*
<br>
*42 Málaga – sternero (septiembre 2026)*

