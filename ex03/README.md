# 🤖 Ejercicio 03 – Automatic table

<p align="center">
  <img src="../imgs/banner_03.jpg" alt="Piscine Data Science – Module 0 – ex03" width="100%">
</p>

[← Volver al README principal](../README.md)

---

## 🎯 ¿Qué se pide exactamente?

Crear **automáticamente** una tabla por **cada archivo CSV** que haya dentro de la carpeta `customer/`.

### Condiciones

- El script debe **descubrir solo** todos los archivos `.csv` de la carpeta `customer/`.
- Por cada CSV debe crear una tabla con el mismo nombre (sin la extensión).
- Las reglas de tipos de datos son las mismas que en el ejercicio 02:
  - Primera columna = `TIMESTAMP`
  - Al menos 6 tipos de datos diferentes
  - Nombres de columnas exactos
  - Tipos apropiados

**No está permitido hardcodear** los nombres de los archivos. Tiene que ser automático.

---

## 📁 Archivos a entregar

Dentro de `ex03/` debes entregar un archivo llamado `automatic_table.*`  
(puede ser `.py`, `.sh`, `.sql`… el que uses).

---

## 🧠 Explicación sencilla

En el ejercicio anterior creaste **una sola tabla a mano**.  

Ahora imagina que tienes 4, 10 o 50 archivos CSV.  
Hacerlo a mano sería aburrido y propenso a errores.  

Este ejercicio consiste en escribir un programa que:

1. Entre en la carpeta `customer/`
2. Liste todos los archivos que terminan en `.csv`
3. Por cada uno cree la tabla correspondiente e importe los datos

Es como tener un robot que monta todas las estanterías del almacén solo.

---

## 📂 Estructura de carpetas esperada (según el subject)

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

---

## 🚀 Cómo implementarlo paso a paso

### ¿Es Python la mejor elección?

En las instrucciones se nos pide/acepta: **automatic_table**.*<br> Por lo que podemos usar: <i>Python, Bash, SQL embebido, etc.</i>

| Opción | Ventajas | Inconvenientes
|---|---|---|
|Python (.py) | **Muy claro**, pathlib + bucle, copy_expert rápido, fácil de leer en evaluación | Hace falta psycopg2 (o instalarlo) |
| Bash + psql | Pocas dependencias si ya tienes psql/docker exec | **Más frágil** con rutas, comillas y errores |
| Solo SQL | **No aplica bien**: SQL solo no “lista” ficheros del disco de forma portable |

**Python** suele ser la **mejor opción** porque:

- El “robot” (listar CSV + crear tabla + cargar) se expresa de forma natural.
- Evitas hardcodear nombres con Path.glob("*.csv").
- La carga masiva con copy_expert es la adecuada (como COPY).
- Es lo que la mayoría de evaluadores espera ver en un automatic_table.py.

Bash es válido si lo controlas bien; no es incorrecto respecto al subject.
Pero **Python es más didáctico, mantenible y alineado con el resto del módulo**.

En **resumen**:

| Pregunta | Respuesta |
|---|---|
| ¿Contemplar otra ubicación de customer/? | Sí — rutas relativas + opcionalmente argumento
| ¿Hardcodear /sgoinfre/students/sternero/...? | No | 
| ¿Mejor extensión? | .py recomendada; Bash también cumple si está bien hecho | 
| ¿Esquema de columnas? | El de 6 campos que ya validasteis en EX02 | 

### Opción recomendada: Script en Python

Crea el archivo `ex03/automatic_table.py`:

Al ejecutarse, el script comprueba si faltan `psycopg2-binary` o
`python-dotenv` y los instala automáticamente. Para ello necesita conexión a
Internet y permisos para ejecutar `pip`.

El script reutiliza las variables `POSTGRES_USER`, `POSTGRES_PASSWORD` y
`POSTGRES_DB` definidas en `ex00/.env`. No subas ese archivo a Git ni copies
sus credenciales directamente en el código.

### 📘 Guía Python paso a paso: [python.md](./python.md) <- Recomendable

### Opción alternativa: Script Bash + psql

También es válida. Puedes hacer un bucle `for` que recorra los CSV y ejecute `psql -c "..."`.

---

## 📝 Puntos clave para que sea “automático”

1. Usa `os.listdir()`, `Path.glob("*.csv")` o equivalente.
2. Extrae el nombre de la tabla con `os.path.splitext()` o `.stem`.
3. No pongas nunca en el código los nombres `data_2022_oct`, `data_2022_nov`, etc.

---

<p align="center">
  <img src="./imgs/diagrama_py.png" alt="Piscine Data Science – Module 0 – ex03 – diagrama de flujo del script" width="100%">
</p>

---

## ✅ Checklist de este ejercicio

- [ ] El script encuentra solo todos los CSV de `customer/`
- [ ] Crea una tabla por cada CSV
- [ ] El nombre de cada tabla es el del archivo sin `.csv`
- [ ] Se respetan las reglas de tipos de datos del ejercicio ex02
- [ ] No hay nombres de archivos hardcodeados
- [ ] El archivo se llama `automatic_table.*`

---

## 🔗 Navegación

- [← README principal](../README.md)
- [← Ejercicio anterior: ex02](../ex02/README.md)
- [Siguiente ejercicio: ex04 →](../ex04/README.md)

---

*Piscine Data Science – sternero – 42 Málaga – Septiembre de 2026*