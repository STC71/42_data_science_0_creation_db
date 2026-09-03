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

### Opción recomendada: Script en Python

Crea el archivo `ex03/automatic_table.py`:

```python
import os
import psycopg2
from pathlib import Path

# ========== CONFIGURACIÓN ==========
DB_CONFIG = {
    "host": "localhost",
    "database": "piscineds",
    "user": "tu_login",          # ← cambia por tu login
    "password": "mysecretpassword"
}

CUSTOMER_FOLDER = Path("../customer")   # ajusta la ruta según donde esté
# ===================================

def get_connection():
    return psycopg2.connect(**DB_CONFIG)

def create_table_from_csv(csv_path: Path):
    table_name = csv_path.stem          # nombre sin extensión
    print(f"Procesando: {csv_path.name} → tabla {table_name}")

    # Aquí defines la estructura (puedes hacerla más inteligente leyendo la cabecera)
    create_sql = f"""
    DROP TABLE IF EXISTS {table_name};
    CREATE TABLE {table_name} (
        event_time      TIMESTAMP,
        event_type      VARCHAR(50),
        product_id      BIGINT,
        category_id     BIGINT,
        category_code   VARCHAR(255),
        brand           VARCHAR(100),
        price           NUMERIC(10,2),
        user_id         BIGINT,
        user_session    VARCHAR(100)
    );
    """

    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(create_sql)
            # Importación eficiente
            with open(csv_path, "r") as f:
                next(f)  # saltar cabecera
                cur.copy_expert(
                    f"COPY {table_name} FROM STDIN WITH CSV",
                    f
                )
        conn.commit()
    print(f"  ✓ Tabla {table_name} creada e importada")

def main():
    csv_files = list(CUSTOMER_FOLDER.glob("*.csv"))
    if not csv_files:
        print("No se encontraron archivos CSV en customer/")
        return

    print(f"Se encontraron {len(csv_files)} archivos CSV")
    for csv_file in sorted(csv_files):
        create_table_from_csv(csv_file)

    print("\n¡Proceso terminado!")

if __name__ == "__main__":
    main()
```

### Opción alternativa: Script Bash + psql

También es válida. Puedes hacer un bucle `for` que recorra los CSV y ejecute `psql -c "..."`.

---

## 📝 Puntos clave para que sea “automático”

1. Usa `os.listdir()`, `Path.glob("*.csv")` o equivalente.
2. Extrae el nombre de la tabla con `os.path.splitext()` o `.stem`.
3. No pongas nunca en el código los nombres `data_2022_oct`, `data_2022_nov`, etc.

---

## ✅ Checklist de este ejercicio

- [ ] El script encuentra solo todos los CSV de `customer/`
- [ ] Crea una tabla por cada CSV
- [ ] El nombre de cada tabla es el del archivo sin `.csv`
- [ ] Se respetan las reglas de tipos de datos del ejercicio 02
- [ ] No hay nombres de archivos hardcodeados
- [ ] El archivo se llama `automatic_table.*`

---

## 🔗 Navegación

- [← README principal](../README.md)
- [← Ejercicio anterior: ex02](../ex02/README.md)
- [Siguiente ejercicio: ex04 →](../ex04/README.md)

---

*Piscine Data Science – sternero – 42 Málaga – Septiembre de 2026*