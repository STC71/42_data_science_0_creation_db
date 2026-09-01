# 📊 Piscine Data Science – Module 0 – Creación de una Base de datos.

<p align="center">
  <img src="https://img.shields.io/badge/42-School-000000?style=for-the-badge&logo=42&logoColor=white" alt="42 School">
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker">
  <img src="https://img.shields.io/badge/Data%20Engineer-FF6B6B?style=for-the-badge" alt="Data Engineer">
</p>

---

## 🎯 ¿De qué trata este proyecto?

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

## 🧠 Rol del Data Engineer

En los dos primeros módulos de la piscine verás el trabajo de un **Data Engineer**:

- Recibe datos “crudos” (CSV, logs, APIs…).
- Los limpia, organiza y transforma.
- Los almacena de forma eficiente y segura.
- Los deja listos para que los Data Scientists / Analysts puedan analizarlos sin perder tiempo.

Este módulo se centra en la **creación y carga inicial** de la base de datos.

---

## 📋 Estructura del proyecto y enlaces a cada ejercicio

| Carpeta | Ejercicio | Descripción corta | Enlace al README detallado |
|---------|-----------|-------------------|---------------------------|
| `ex00/` | Create Postgres DB | Crear la base de datos PostgreSQL | [📖 README ex00](ex00/README.md) |
| `ex01/` | Show me your DB | Visualizar la BD con una herramienta gráfica | [📖 README ex01](ex01/README.md) |
| `ex02/` | First table | Crear la primera tabla manualmente desde un CSV | [📖 README ex02](ex02/README.md) |
| `ex03/` | Automatic table | Crear automáticamente todas las tablas de `customer/` | [📖 README ex03](ex03/README.md) |
| `ex04/` | Items table | Crear la tabla `items` | [📖 README ex04](ex04/README.md) |

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

## 🚀 Orden recomendado de trabajo

1. **[ex00](ex00/README.md)** → Arranca PostgreSQL  
2. **[ex01](ex01/README.md)** → Conecta una herramienta gráfica  
3. **[ex02](ex02/README.md)** → Crea y carga la primera tabla  
4. **[ex03](ex03/README.md)** → Automatiza la creación de todas las tablas de clientes 
5. **[ex04](ex04/README.md)** → Crea la tabla items  

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
  <strong>¡Ánimo y suerte con el Day 0!</strong><br>
  Este es el cimiento de toda la piscine de Data Science.<br>
  Hazlo bien y el resto será mucho más fácil.
</p>

---

*Piscine Data Science – Module 0 – Creation of a DB – Version 1.2*  
*sternero – 42 Málaga – Septiembre de 2026*
