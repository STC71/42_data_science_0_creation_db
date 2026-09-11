# 📊 Piscine Data Science – Module 0 – Creación de una base de datos

<p align="center">
  <img src="https://img.shields.io/badge/42-School-000000?style=for-the-badge&logo=42&logoColor=white" alt="42 School">
  <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python">
  <img src="https://img.shields.io/badge/SQL-336791?style=for-the-badge&logo=postgresql&logoColor=white" alt="SQL">
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker">
  <img src="https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white" alt="Bash">
  <img src="https://img.shields.io/badge/pgAdmin-336791?style=for-the-badge&logo=postgresql&logoColor=white" alt="pgAdmin">
  <img src="https://img.shields.io/badge/Data%20Engineer-FF6B6B?style=for-the-badge" alt="Data Engineer">
</p>

<p align="center">
  <img src="imgs/banner_0.jpg" alt="Piscine Data Science – Module 0" width="100%">
</p>

---

<a id="indice"></a>
## 📑 Índice

1. [¿De qué trata este proyecto?](#proyecto)
2. [Rol del Data Engineer](#rol)
3. [Estructura y enlaces](#estructura)
4. [Requisitos generales](#requisitos)
5. [Orden de trabajo](#orden)
6. [Asistentes start.sh](#asistentes)
7. [Checklist final](#checklist)
8. [Consejos](#consejos)
9. [Recursos](#recursos)

---

<a id="proyecto"></a>
## 🎯 ¿De qué trata este proyecto?

Imagina que es tu **primer día** en una empresa que vende productos por Internet.  
Finales de febrero de 2023: tu jefe te deja una carpeta de CSV con **ventas de los últimos meses** y el catálogo de productos.

Tu misión como **Data Engineer**:

1. Crear un almacén digital (PostgreSQL) limpio y organizado.  
2. Cargar los datos de forma correcta y eficiente.  
3. Dejarlos listos para análisis posteriores (aumentar facturación, etc.).

> **Analogía:** cajas de cartón desordenadas → almacén con estanterías etiquetadas y búsqueda rápida.

[↑ Volver al índice](#indice)

---

<a id="rol"></a>
## 🧠 Rol del Data Engineer

- Recibe datos crudos (CSV, logs, APIs…).  
- Los organiza y almacena de forma eficiente.  
- Los deja listos para Data Scientists / Analysts.

Este **Module 0** se centra en la **creación y carga inicial** de la base `piscineds`.

[↑ Volver al índice](#indice)

---

<a id="estructura"></a>
## 📋 Estructura del proyecto y enlaces

| Carpeta | Ejercicio | Qué entrega (mínimo) | README | Asistente |
|---------|-----------|----------------------|--------|-----------|
| [`ex00/`](ex00/README.md) | Create Postgres DB | Docker Compose + BD | [README](ex00/README.md) | [`start.sh`](ex00/start.sh) |
| [`ex01/`](ex01/README.md) | Show me your DB | pgAdmin / GUI | [README](ex01/README.md) | [`start.sh`](ex01/start.sh) → EX00 |
| [`ex02/`](ex02/README.md) | First table | Tabla manual (CSV customer) | [README](ex02/README.md) | — |
| [`ex03/`](ex03/README.md) | Automatic table | `automatic_table.*` | [README](ex03/README.md) | [`start.sh`](ex03/start.sh) → EX01 |
| [`ex04/`](ex04/README.md) | Items table | `items_table.*` | [README](ex04/README.md) | [`start.sh`](ex04/start.sh) → EX03 |

### Datos descargables (debido a su tamaño los ficheros no están disponibles en este repo)

```text
subject/
├── customer/          # CSV de eventos (EX02 / EX03)
│   ├── data_2022_oct.csv
│   ├── data_2022_nov.csv
│   ├── data_2022_dec.csv
│   └── data_2023_jan.csv
└── item/
    └── item.csv       # Catálogo de productos (EX04)
```

[↑ Volver al índice](#indice)

---

<a id="requisitos"></a>
## ⚙️ Requisitos generales

- Cluster 42 (o VM configurada).  
- Espacio en disco (`goinfre` / `sgoinfre` si aplica).  
- Docker + PostgreSQL según EX00.  
- Solo se evalúa lo que esté en el repositorio Git.  
- Demostrar en la máquina del evaluado.

[↑ Volver al índice](#indice)

---

<a id="orden"></a>
## 🚀 Orden recomendado de trabajo

1. **[ex00](ex00/README.md)** — PostgreSQL en Docker (`.env`, volumen, puerto 5432)  
2. **[ex01](ex01/README.md)** — Visualización (pgAdmin)  
3. **[ex02](ex02/README.md)** — Primera tabla a mano (≥ 6 tipos, 1ª columna fecha/hora)  
4. **[ex03](ex03/README.md)** — Todas las tablas de `customer/` sin hardcodear nombres  
5. **[ex04](ex04/README.md)** — Tabla `items` (≥ 3 tipos)

Cadena de asistentes (opcional):

```text
ex04/start.sh → ex03/start.sh → ex01/start.sh → ex00/start.sh
```

[↑ Volver al índice](#indice)

---

<a id="asistentes"></a>
## 🎛️ Asistentes `start.sh`

No sustituyen a los archivos del subject; facilitan entorno, carga y comprobación.

| Script | Llamable desde cualquier ruta | Encadena a |
|--------|-------------------------------|------------|
| `ex00/start.sh` | Sí | — (Docker + `.env` + contenedor) |
| `ex01/start.sh` | Sí | EX00 |
| `ex03/start.sh` | Sí | EX01 → EX00 + `automatic_table.py` |
| `ex04/start.sh` | Sí | EX03 / EX01 + carga `items` (SQL o Python) |

[↑ Volver al índice](#indice)

---

<a id="checklist"></a>
## ✅ Checklist final antes de entregar

| Ítem | ☐ |
|------|---|
| EX00: BD accesible con usuario / `mysecretpassword` / `piscineds` | ☐ |
| EX01: se puede visualizar la BD | ☐ |
| EX02: tabla con ≥ 6 tipos y DATETIME/TIMESTAMPTZ primero | ☐ |
| EX03: todas las tablas de `customer/` sin nombres hardcodeados | ☐ |
| EX04: tabla `items` con ≥ 3 tipos y datos cargados | ☐ |
| Nombres de carpetas y archivos **exactos** | ☐ |
| Todo en el repositorio Git | ☐ |
| Puedes demostrar el flujo en evaluación | ☐ |

[↑ Volver al índice](#indice)

---

<a id="consejos"></a>
## 💡 Consejos

1. Usa **`COPY` / `copy_expert`**, no miles de `INSERT`.  
2. Mira la cabecera real del CSV antes de elegir tipos (`category_id` → `BIGINT`).  
3. Rutas relativas o argumentos CLI; evita `/sgoinfre/students/tu_login/...` fijo en el código.  
4. Documenta scripts (comentarios claros).  
5. Prueba desde cero antes de la evaluación (`docker-compose down -v` ⚠️ solo si aceptas perder datos).

[↑ Volver al índice](#indice)

---

<a id="recursos"></a>
## 📚 Recursos útiles

- [PostgreSQL – tipos de datos](https://www.postgresql.org/docs/current/datatype.html)  
- [COPY](https://www.postgresql.org/docs/current/sql-copy.html)  
- [Imagen Docker postgres](https://hub.docker.com/_/postgres)  
- Guías del repo: `ex00/docker.md`, `ex00/postgresql.md`, `ex02/SQL.md`, `ex03/python.md`

---

<p align="center">
  <strong>¡Ánimo con el Module 0!</strong><br>
  Es el cimiento de la piscine de Data Science.
</p>

---

*Piscine Data Science – Module 0 – Creation of a DB*  
*sternero – 42 Málaga – Septiembre de 2026*
