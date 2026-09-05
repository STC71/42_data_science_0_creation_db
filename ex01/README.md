# 🖥️ Ejercicio 01 – Show me your DB

<p align="center">
  <img src="../imgs/banner_01.jpg" alt="Piscine Data Science – Module 0 – ex01" width="100%">
</p>

[← Volver al README principal](../README.md)

---

## 📑 Índice

1. [¿Qué se pide exactamente?](#-qué-se-pide-exactamente)
2. [Archivos a entregar](#-archivos-a-entregar)
3. [Explicación sencilla](#-explicación-sencilla)
4. [Herramientas permitidas](#️-herramientas-permitidas)
5. [Scripts de este ejercicio](#-scripts-de-este-ejercicio)
6. [Flujo recomendado en el campus 42](#-flujo-recomendado-en-el-campus-42)
7. [Cómo implementarlo paso a paso (con pgAdmin)](#-cómo-implementarlo-paso-a-paso-con-pgadmin)
8. [Primer arranque de pgAdmin (importante)](#-primer-arranque-de-pgadmin-importante)
9. [Conectar pgAdmin a PostgreSQL](#-conectar-pgadmin-a-postgresql)
10. [Cómo saber que lo has hecho bien](#-cómo-saber-que-lo-has-hecho-bien)
11. [Consejos y problemas frecuentes](#-consejos-y-problemas-frecuentes)
12. [Navegación](#-navegación)

---

## 🎯 ¿Qué se pide exactamente?

Encontrar y configurar una **herramienta gráfica** (con interfaz visual) que te permita:

- Ver tu base de datos de forma cómoda.
- Navegar por las tablas.
- Consultar y manipular los registros fácilmente (especialmente usando los IDs).

No se pide entregar código, solo demostrar que tienes la herramienta configurada y funcionando.


[↑ Volver al índice](#-índice)

---

## 📁 Archivos a entregar

La carpeta `ex01/` puede estar vacía o contener capturas de pantalla / notas si quieres.  
Lo importante es que durante la evaluación puedas abrir la herramienta y mostrar la base de datos.

En este repositorio encontrarás además tres scripts de ayuda (opcionales, pero muy útiles en el campus 42):

| Script | Función |
|--------|---------|
| [`install.sh`](install.sh) | Instala pgAdmin 4 (versión 9.17) sin `sudo` |
| [`start.sh`](start.sh) | Comprueba PostgreSQL, arranca/detiene pgAdmin y diagnostica el entorno |
| [`off_del.sh`](off_del.sh) | ⚠️ Apaga servicios y, solo si lo confirmas, elimina instalaciones ⚠️ |


[↑ Volver al índice](#-índice)

---

## 🧠 Explicación sencilla

Hasta ahora solo puedes hablar con la base de datos escribiendo comandos en la terminal (`psql`).  

Es como si solo pudieras hablar con el almacén por radio.  

Este ejercicio consiste en instalar un **panel de control visual** (como el de un banco online) para poder ver las tablas, los datos y navegar de forma mucho más amigable.


[↑ Volver al índice](#-índice)

---

## 🛠️ Herramientas permitidas

Puedes usar cualquiera de estas (o cualquier otra similar):

| Herramienta     | Plataforma          | Recomendada |
|-----------------|---------------------|-------------|
| **pgAdmin**     | Windows / Mac / Linux | ✅ Sí      |
| **DBeaver**     | Todas               | Muy buena  |
| **Postico**     | Solo Mac            | Excelente  |
| Otra de tu elección | -                | Válida     |

**Recomendación para principiantes:** usa **pgAdmin**.


[↑ Volver al índice](#-índice)

---

## 🧰 Scripts de este ejercicio

Estos scripts están pensados para el entorno del campus 42 (sin `sudo`, con `sgoinfre`/`goinfre`).

### 1. `install.sh` — Instalador de pgAdmin

Instala **pgAdmin 4.9.17** de forma segura y reproducible.

**Qué hace:**
- Crea un entorno virtual en `~/sgoinfre/pgadmin4/venv`
- Instala exactamente `pgadmin4==9.17`
- Genera `config_local.py` para usar solo rutas escribibles por el usuario (evita `/var/lib/pgadmin`)
- Inicializa la base SQLite interna de pgAdmin
- Verifica el modelo de autenticación (solo lectura)
- Es **idempotente**: si ya tienes una instalación correcta de 9.17, no la reinstala

**Qué NO hace:**
- No usa `sudo`
- No toca Docker, PostgreSQL ni el `.env` de EX00
- No detiene ni reinicia pgAdmin
- No elimina instalaciones existentes
- No parchea código de pgAdmin a ciegas

**Protecciones importantes:**
- Si pgAdmin está en ejecución → **aborta**
- Si hay una instalación parcial o una versión distinta → **aborta**
- Si el directorio contiene contenido desconocido → **aborta**

```bash
chmod +x install.sh
./install.sh
```

---

### 2. `start.sh` — Arranque y diagnóstico

Script interactivo para:

- Ejecutar el `start.sh` de EX00 (preparar PostgreSQL)
- Comprobar Docker, `.env`, contenedor y puerto 5432
- Comprobar la instalación y el estado de pgAdmin
- Arrancar pgAdmin en segundo plano
- Detener pgAdmin y/o PostgreSQL de forma **no destructiva**

```bash
chmod +x start.sh
./start.sh
```

Menú principal típico:
1. Ejecutar START.SH de EX00  
2. Comprobar PostgreSQL  
3. Comprobar pgAdmin  
4. Arrancar pgAdmin  
5. Detener servicios (sin borrar datos)  
0. Salir  

---

### 3. `off_del.sh` — ⚠️ Apagado y borrado opcional ⚠️

Herramienta de mantenimiento. Por defecto **solo apaga** servicios.

Las acciones destructivas (borrar psql del host, borrar la instalación de pgAdmin, limpiar referencias del shell…) requieren confirmación explícita escribiendo `ELIMINAR`.

```bash
chmod +x off_del.sh
./off_del.sh
```

Úsalo cuando quieras:
- Detener pgAdmin o PostgreSQL
- Eliminar una instalación de pgAdmin de forma deliberada
- Limpiar un `psql` instalado en `~/goinfre` (si lo instalaste en EX00)

[↑ Volver al índice](#-índice)

---

## 🚀 Flujo recomendado en el campus 42

```text
1. Completa EX00 (PostgreSQL funcionando)
2. ./install.sh          ← instala pgAdmin (solo la primera vez)
3. ./start.sh            ← arranca y comprueba el entorno
4. Abre http://127.0.0.1:5050 en el navegador
5. Crea el usuario de pgAdmin (solo la primera vez)
6. Registra el servidor PostgreSQL (localhost:5432)
```

Orden recomendado de los scripts:

| Momento | Script |
|---------|--------|
| Primera instalación | `install.sh` |
| Día a día / evaluación | `start.sh` |
| Apagar o limpiar | `off_del.sh` |


[↑ Volver al índice](#-índice)

---

## 🚀 Cómo implementarlo paso a paso (con pgAdmin)

### Opción A — Con los scripts de este repositorio (recomendada en 42)

1. Asegúrate de que EX00 está funcionando (`postgres_piscineds` en marcha).
2. Ejecuta:
   ```bash
   ./install.sh
   ./start.sh
   ```
3. En el menú de `start.sh`, elige **Arrancar pgAdmin**.
4. Abre el navegador en [http://127.0.0.1:5050](http://127.0.0.1:5050).

### Opción B — Instalación manual clásica

1. Ve a la página oficial: [https://www.pgadmin.org/download/](https://www.pgadmin.org/download/)
2. Descarga la versión para tu sistema operativo e instálala.
3. Ábrela y sigue los pasos de conexión de más abajo.
4. Suerte 🤞


[↑ Volver al índice](#-índice)

---

## 🔑 Primer arranque de pgAdmin (importante)

La **primera vez** que arranques pgAdmin en modo servidor te pedirá crear el usuario administrador de la propia aplicación:

```text
Enter the email address and password to use for the initial pgAdmin user account:
Email address:
Password:
Retype password:
```

**Requisitos del email:**
- Debe tener un formato válido con un **punto después de la `@`**
- Ejemplos que funcionan:
  - `alumno@42.es`
  - `user@localhost.local`
- Ejemplos que **NO** funcionan:
  - `alumno@42`
  - `user@localhost`

**Requisitos de la contraseña:**
- Mínimo **6 caracteres** como única regla.

Esta cuenta es solo para entrar en la interfaz de pgAdmin.  
**No es** el usuario de PostgreSQL (`tu_login` / `mysecretpassword`).


[↑ Volver al índice](#-índice)

---

## 🔌 Conectar pgAdmin a PostgreSQL

Una vez dentro de pgAdmin:

1. En el panel izquierdo haz clic derecho en **Servers** → **Register** → **Server…**
2. Pestaña **General**:
   - Name: `Piscine DS` (o el nombre que quieras)
3. Pestaña **Connection**:
   - Host name/address: `localhost`
   - Port: `5432`
   - Maintenance database: `piscineds`
   - Username: `tu_login` (el mismo de EX00)
   - Password: `mysecretpassword`
4. Guarda.

📖 **Guía de conexión paso a paso (detallada): [pgAdmin.md](./pgAdmin.md)**

### Explorar la base de datos

- Expande el servidor → **Databases** → `piscineds` → **Schemas** → `public` → **Tables**
- Cuando crees tablas en los ejercicios siguientes, las verás aquí
- Clic derecho en una tabla → **View/Edit Data** → **All Rows**


[↑ Volver al índice](#-índice)

---

## ✅ Cómo saber que lo has hecho bien

Durante la evaluación debes poder:

1. Abrir la herramienta (pgAdmin u otra).
2. Conectarte a la base de datos `piscineds`.
3. Mostrar las tablas (cuando existan).
4. Navegar por los registros usando los IDs.

Con los scripts:

```bash
./start.sh
# Opción 2 → Comprobar PostgreSQL  → debe salir OK
# Opción 3 → Comprobar pgAdmin     → debe responder en el puerto 5050
# Opción 4 → Arrancar pgAdmin      → http://127.0.0.1:5050
```


[↑ Volver al índice](#-índice)

---

## 💡 Consejos y problemas frecuentes

### Consejos generales
- Guarda la conexión al servidor para no tener que configurarla cada vez.
- Si reinicias el contenedor de Docker, la conexión de pgAdmin sigue siendo válida.
- `install.sh` no arranca pgAdmin: usa siempre `start.sh` para eso.

### Problemas frecuentes

| Problema | Causa habitual | Solución |
|----------|----------------|----------|
| `install.sh` aborta diciendo que pgAdmin está en ejecución | Ya hay un proceso activo | Deténlo con `start.sh` o `off_del.sh` y vuelve a ejecutar |
| Email rechazado en el primer arranque | Falta el punto después de `@` | Usa un email tipo `user@42.es` o `user@localhost.local` |
| Contraseña rechazada | Menos de 6 caracteres | Usa al menos 6 caracteres |
| pgAdmin no responde en el puerto 5050 | No se ha arrancado o falló el arranque | Usa la opción 3 y 4 de `start.sh` |
| No encuentra `~/sgoinfre` | Enlace simbólico ausente en ese campus | Crea el enlace o ajusta la variable `PGADMIN_DIR` |
| `Connection refused` a PostgreSQL | Contenedor parado | Arranca EX00 (`./start.sh` de EX00 o opción 1 de EX01) |

### Filosofía de seguridad de los scripts
- Nunca usan `sudo`
- Nunca tocan Docker/PostgreSQL desde `install.sh`
- Las eliminaciones solo ocurren en `off_del.sh` y con confirmación explícita (`ELIMINAR`)
- Una instalación correcta de pgAdmin 9.17 se respeta (modo idempotente)


[↑ Volver al índice](#-índice)

---

## 🔗 Navegación

- [← README principal](../README.md)
- [← Ejercicio anterior: ex00](../ex00/README.md)
- [Siguiente ejercicio: ex02 →](../ex02/README.md)


[↑ Volver al índice](#-índice)

---

*Piscine Data Science – sternero – 42 Málaga – Septiembre de 2026*
