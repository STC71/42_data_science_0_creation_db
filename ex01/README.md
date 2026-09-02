# 🖥️ Ejercicio 01 – Show me your DB

<p align="center">
  <img src="../imgs/banner_01.jpg" alt="Piscine Data Science – Module 0 – ex01" width="100%">
</p>

[← Volver al README principal](../README.md)

---

## 🎯 ¿Qué se pide exactamente?

Encontrar y configurar una **herramienta gráfica** (con interfaz visual) que te permita:

- Ver tu base de datos de forma cómoda.
- Navegar por las tablas.
- Consultar y manipular los registros fácilmente (especialmente usando los IDs).

No se pide entregar código, solo demostrar que tienes la herramienta configurada y funcionando.

---

## 📁 Archivos a entregar

La carpeta `ex01/` puede estar vacía o contener capturas de pantalla / notas si quieres.  
Lo importante es que durante la evaluación puedas abrir la herramienta y mostrar la base de datos.

---

## 🧠 Explicación sencilla

Hasta ahora solo puedes hablar con la base de datos escribiendo comandos en la terminal (`psql`).  

Es como si solo pudieras hablar con el almacén por radio.  

Este ejercicio consiste en instalar un **panel de control visual** (como el de un banco online) para poder ver las tablas, los datos y navegar de forma mucho más amigable.

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

---

## 🚀 Cómo implementarlo paso a paso (con pgAdmin)

### Paso 1: Instalar pgAdmin

- Ve a la página oficial: [https://www.pgadmin.org/download/](https://www.pgadmin.org/download/)
- Descarga la versión para tu sistema operativo e instálala.

### Paso 2: Abrir pgAdmin

Al abrirlo te pedirá crear una contraseña maestra (puedes poner la que quieras, es solo para pgAdmin).

### Paso 3: Crear una nueva conexión al servidor

1. En el panel izquierdo haz clic derecho en **Servers** → **Register** → **Server…**
2. En la pestaña **General**:
   - Name: `Piscine DS` (o el nombre que quieras)
3. En la pestaña **Connection**:
   - Host name/address: `localhost`
   - Port: `5432`
   - Maintenance database: `piscineds`
   - Username: `tu_login` (el mismo del ejercicio 00)
   - Password: `mysecretpassword`
4. Guarda.

### Paso 4: Explorar la base de datos

- Expande el servidor → Databases → `piscineds` → Schemas → public → Tables
- Cuando crees tablas en los ejercicios siguientes, las verás aquí.
- Puedes hacer clic derecho en una tabla → **View/Edit Data** → **All Rows** para ver el contenido.

---

## ✅ Cómo saber que lo has hecho bien

Durante la evaluación debes poder:

1. Abrir la herramienta.
2. Conectarte a la base de datos `piscineds`.
3. Mostrar las tablas (cuando existan).
4. Navegar por los registros usando los IDs.

---

## 💡 Consejo

Guarda la conexión para no tener que configurarla cada vez.  
Si usas Docker y reinicias el contenedor, la conexión sigue siendo la misma.

---

## 🔗 Navegación

- [← README principal](../README.md)
- [← Ejercicio anterior: ex00](../ex00/README.md)
- [Siguiente ejercicio: ex02 →](../ex02/README.md)

---

*Piscine Data Science – sternero – 42 Málaga – Septiembre de 2026*