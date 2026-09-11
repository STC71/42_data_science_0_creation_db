# 📊 Piscine Data Science – Module 0 – Creación de una base de datos

<p align="center">
  <a href="https://www.42malaga.com/" target="_blank" rel="noopener noreferrer"><img src="https://img.shields.io/badge/42-School-000000?style=for-the-badge&logo=42&logoColor=white" alt="42 School"></a>
  <a href="https://www.python.org/" target="_blank" rel="noopener noreferrer"><img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python"></a>
  <a href="https://www.postgresql.org/docs/current/sql.html" target="_blank" rel="noopener noreferrer"><img src="https://img.shields.io/badge/SQL-336791?style=for-the-badge&logo=postgresql&logoColor=white" alt="SQL"></a>
  <a href="https://www.postgresql.org/" target="_blank" rel="noopener noreferrer"><img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL"></a>
  <a href="https://www.docker.com/" target="_blank" rel="noopener noreferrer"><img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker"></a>
  <a href="https://www.gnu.org/software/bash/" target="_blank" rel="noopener noreferrer"><img src="https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white" alt="Bash"></a>
  <a href="https://www.pgadmin.org/" target="_blank" rel="noopener noreferrer"><img src="https://img.shields.io/badge/pgAdmin-336791?style=for-the-badge&logo=postgresql&logoColor=white" alt="pgAdmin"></a>
  <a href="https://www.ibm.com/think/topics/data-engineering" target="_blank" rel="noopener noreferrer"><img src="https://img.shields.io/badge/Data%20Engineer-FF6B6B?style=for-the-badge" alt="Data Engineer"></a>
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
6. [Asistente global (`./start.sh`)](#asistente-global)
7. [Asistentes por ejercicio (opcionales)](#asistentes-ex)
8. [Checklist final](#checklist)
9. [Consejos](#consejos)
10. [Recursos útiles](#recursos)

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

| Carpeta | Ejercicio | Qué entrega (mínimo) | README | Asistente local |
|---------|-----------|----------------------|--------|-----------------|
| [`ex00/`](ex00/README.md) | Create Postgres DB | Docker Compose + BD | [README](ex00/README.md) | [`start.sh`](ex00/start.sh) (opcional) |
| [`ex01/`](ex01/README.md) | Show me your DB | pgAdmin / GUI | [README](ex01/README.md) | [`start.sh`](ex01/start.sh) (opcional) |
| [`ex02/`](ex02/README.md) | First table | Tabla manual (CSV customer) | [README](ex02/README.md) | — |
| [`ex03/`](ex03/README.md) | Automatic table | `automatic_table.*` | [README](ex03/README.md) | [`start.sh`](ex03/start.sh) (opcional) |
| [`ex04/`](ex04/README.md) | Items table | `items_table.*` | [README](ex04/README.md) | [`start.sh`](ex04/start.sh) (opcional) |
| **Raíz** | Module 0 completo | — | este archivo | **[`./start.sh`](./start.sh)** (recomendado) |

### Datos descargables

Debido a su tamaño, los CSV **no** suelen ir en el repo de entrega. En el layout de trabajo:

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

Puedes seguir ese orden **a mano** o con el asistente global de la raíz (siguiente sección).

[↑ Volver al índice](#indice)

---

<a id="asistente-global"></a>
## 🎛️ Asistente global (`./start.sh`)

En la **raíz** del proyecto hay un único orquestador:

```bash
chmod +x start.sh
./start.sh
# o desde cualquier directorio (recomendable para GIT):
/ruta/a/data_science_0_creation_db/start.sh
```

### Independiente de los `start.sh` de cada `ex/`

- **No exige** `ex00/start.sh`, `ex01/start.sh`, `ex03/start.sh` ni `ex04/start.sh`.
- Incluye el flujo de Module 0: estado del entorno, `.env`, levantar PostgreSQL, cargas EX02/EX03/EX04, `psql`, checklist de entregables.
- Si existen los asistentes por ejercicio, el menú ofrece **atajos opcionales** (no obligatorios).
- Podemos trabajar solo con **entregables del subject + este `start.sh`**.

### Permisos de ejecución (`+x`)

Tras un `git clone`, a veces faltan permisos y aparece `Permission denied`.

El asistente global:

1. Puede aplicar **`chmod +x`** a scripts conocidos al arrancar (con confirmación).  
2. Opción de menú dedicada a permisos.  
3. Al preparar la carpeta de evaluación, vuelve a aplicar `+x` allí.

Para que el **remoto y los clones futuros** conserven el bit ejecutable:

```bash
git update-index --chmod=+x start.sh                # no necesario para evaluación
git update-index --chmod=+x ex03/automatic_table.py
git update-index --chmod=+x ex04/items_table.py     # si procede en lugar del .sql
# (y el resto de scripts que deban ser ejecutables)
git commit -m "Mark delivery scripts as executable"
```

Eso también está guiado en el menú de **Git asistido** del `./start.sh`.

### Modo evaluación: `repo_<login>`

Opción del menú para crear una carpeta limpia de entrega (nombre por defecto `repo_$(whoami)`, editable):

| Se copia (lista blanca) | No se copia |
|-------------------------|-------------|
| `ex00/docker-compose.yml` | `.env` (secretos) |
| `ex02/table.sql` | `subject/` (CSV pesados) |
| `ex03/automatic_table.*` | venv / logs / cachés |
| `ex04/items_table.*` | capturas opcionales salvo que las añadas tú |
| README útiles + este `start.sh` | — |

Todo con confirmación paso a paso. **Git push solo si lo autorizas** (por defecto no).

[↑ Volver al índice](#indice)

---

<a id="asistentes-ex"></a>
## 🧩 Asistentes por ejercicio (opcionales)

No sustituyen a los archivos del subject. Son comodidad extra si los tienes en el repo de trabajo.

| Script | Rol |
|--------|-----|
| [`ex00/start.sh`](ex00/start.sh) | Docker, `.env`, contenedor |
| [`ex01/start.sh`](ex01/start.sh) | pgAdmin + cadena hacia EX00 |
| [`ex03/start.sh`](ex03/start.sh) | `automatic_table.py` + comprobaciones |
| [`ex04/start.sh`](ex04/start.sh) | Carga `items` (SQL o Python) |

Cadena opcional entre ellos:

```text
ex04/start.sh → ex03/start.sh → ex01/start.sh → ex00/start.sh
```

Si no los usas, el **[`./start.sh`](./start.sh) de la raíz** cubre el recorrido.

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
| Scripts ejecutables marcados en Git (`update-index --chmod=+x`) si aplica | ☐ |
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
6. Tras clonar, si falla `./«script»`: `chmod +x «script»` o ejecuta el menú de permisos del `start.sh` raíz.

[↑ Volver al índice](#indice)

---

<a id="recursos"></a>
## 📚 Recursos útiles

### Documentación externa

- [PostgreSQL – tipos de datos](https://www.postgresql.org/docs/current/datatype.html)  
- [COPY](https://www.postgresql.org/docs/current/sql-copy.html)  
- [Imagen Docker postgres](https://hub.docker.com/_/postgres)  

### Guías educativas de este repositorio

| Guía | Carpeta | Contenido |
|------|---------|-----------|
| [`docker.md`](ex00/docker.md) | EX00 | Docker / Compose “bajo el capó”, volúmenes, puertos |
| [`postgresql.md`](ex00/postgresql.md) | EX00 | PostgreSQL y `psql` orientados a la piscine |
| [`pgAdmin.md`](ex01/pgAdmin.md) | EX01 | Instalar y conectar pgAdmin sin sudo (cluster 42) |
| [`SQL.md`](ex02/SQL.md) | EX02 | SQL desde cero: tablas, tipos, `COPY` |
| [`python.md`](ex03/python.md) | EX03 | Python del `automatic_table.py` paso a paso |

Los **README** de cada `ex00`…`ex04` detallan el subject y la ejecución de ese ejercicio.

[↑ Volver al índice](#indice)

---

<p align="center">
  <strong>¡Ánimo con el Module 0!</strong><br>
  Es el cimiento de la piscine de Data Science.
</p>

---

*Piscine Data Science – Module 0 – Creation of a DB*  
*sternero – 42 Málaga – Septiembre de 2026*
