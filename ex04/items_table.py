#!/usr/bin/env python3

# Con la línea de arriba, podemos ejecutar el script directamente en Linux/Mac:
# 	chmod +x items_table.py
#	./items_table.py	sin tener que escribir "python3" delante.

# -*- coding: utf-8 -*-

# El comentario de arriba indica a Python que el archivo está en UTF-8.
# UTF-8 permite acentos, eñes, etc. En Python 3 es el valor por defecto,
# pero es buena práctica indicarlo explícitamente.

"""
EX04 – Items table (Piscine Data Science – Module 0)

Objetivo (subject):
  - Crear una tabla llamada exactamente «items»
  - A partir del CSV de productos (item.csv / items.csv)
  - Columnas = cabecera del CSV
  - Al menos 3 tipos de datos distintos y apropiados
  - Cargar los datos en PostgreSQL

Analogía:
  EX03 montaba muchas estanterías de eventos de clientes.
  EX04 monta UNA estantería de catálogo de productos:
  cada fila es la ficha de un artículo (id, categoría, marca).

Este script sigue el mismo estilo que automatic_table.py (EX03),
pero con un solo fichero y un nombre de tabla fijo: items.
"""

# ---------------------------------------------------------------------------
# from __future__ import annotations
# Comportamiento moderno al anotar tipos (ej. str | None).
# No cambia la lógica del programa.
# ---------------------------------------------------------------------------
from __future__ import annotations

# ---------------------------------------------------------------------------
# import = "trae una caja de herramientas ya hecha".
# ---------------------------------------------------------------------------
import os          # variables de entorno, usuario del sistema, etc.
import sys         # argumentos de la línea de comandos y salir del programa
from pathlib import Path  # rutas de archivos multiplataforma

# ===========================================================================
# DEPENDENCIAS (mismas que EX03: a veces no vienen en el campus)
# ===========================================================================

def ensure_dependencies() -> None:
    """
    Comprueba si faltan librerías y, si faltan, intenta instalarlas.

    - psycopg2: permite a Python hablar con PostgreSQL
    - dotenv:   permite leer el archivo .env (usuario, contraseña, nombre de BD)

    "def" = definir una función (bloque de pasos con nombre).
    "-> None" = esta función no devuelve un valor; solo hace trabajo.
    """
    import importlib.util  # ¿existe ya este módulo?
    import subprocess      # ejecutar otro programa (pip)

    # Diccionario: módulo al importar → paquete a instalar con pip
    needed = {
        "psycopg2": "psycopg2-binary",
        "dotenv": "python-dotenv",
    }

    # Lista de paquetes que faltan
    missing = [
        pkg
        for mod, pkg in needed.items()
        if importlib.util.find_spec(mod) is None
    ]

    if missing:
        print(f"Instalando dependencias: {', '.join(missing)} ...")
        subprocess.check_call(
            [sys.executable, "-m", "pip", "install", "--user", *missing]
            # sys.executable = Python que está ejecutando este script
            # --user = instala sin sudo (solo para tu usuario)
            # *missing = desempaqueta la lista en argumentos sueltos
        )


# Llamamos NADA MÁS empezar, antes de importar psycopg2/dotenv.
ensure_dependencies()

import psycopg2
from dotenv import load_dotenv


# ===========================================================================
# RUTAS
# ===========================================================================

# __file__ = ruta de ESTE archivo (items_table.py)
# .resolve().parent = carpeta que lo contiene (ex04/)
# .parent otra vez = carpeta del módulo (data_science_0_creation_db/)
SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_DIR = SCRIPT_DIR.parent

# Credenciales: las leemos del .env de EX00 (no hardcodear la contraseña).
ENV_FILE = PROJECT_DIR / "ex00" / ".env"
load_dotenv(ENV_FILE)

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": os.environ.get("POSTGRES_DB", "piscineds"),
    "user": os.environ.get("POSTGRES_USER", os.environ.get("USER", "")),
    "password": os.environ.get("POSTGRES_PASSWORD", "mysecretpassword"),
}

# Nombre fijo exigido por el subject
TABLE_NAME = "items"


# ===========================================================================
# LOCALIZAR item.csv (sin rutas de un solo usuario)
# ===========================================================================

def find_item_csv(cli_arg: str | None = None) -> Path:
    """
    Averigua dónde está el CSV de productos.

    Orden de búsqueda:
      1) Ruta pasada como argumento al script
      2) subject/item/item.csv   (layout real de este repo)
      3) subject/items/item.csv
      4) subject/items/items.csv
      5) item/item.csv o items/*.csv junto al proyecto
      6) Dentro de ex04/

    "cli_arg: str | None" = texto (ruta) o None.
    "-> Path" = devuelve un objeto Path.
    """
    candidates: list[Path] = []

    if cli_arg:
        # expanduser() convierte ~ en /home/tu_usuario
        candidates.append(Path(cli_arg).expanduser().resolve())

    candidates.extend(
        [
            PROJECT_DIR / "subject" / "item" / "item.csv",
            PROJECT_DIR / "subject" / "items" / "item.csv",
            PROJECT_DIR / "subject" / "items" / "items.csv",
            PROJECT_DIR / "item" / "item.csv",
            PROJECT_DIR / "items" / "item.csv",
            PROJECT_DIR / "items" / "items.csv",
            SCRIPT_DIR / "item.csv",
            SCRIPT_DIR / "items.csv",
        ]
    )

    for path in candidates:
        if path.is_file():
            return path

    print("ERROR: no se encontró item.csv / items.csv.")
    print("Prueba:")
    print("  python3 items_table.py /ruta/a/item.csv")
    print("Candidatos mirados:")
    for path in candidates:
        print(f"  - {path}")
    sys.exit(1)


def get_connection():
    """
    Abre una conexión con PostgreSQL usando DB_CONFIG.
    **DB_CONFIG = descompone el diccionario en argumentos con nombre.
    """
    return psycopg2.connect(**DB_CONFIG)


# ===========================================================================
# CREAR TABLA items Y CARGAR EL CSV
# ===========================================================================

def create_and_load_items(csv_path: Path) -> None:
    """
    1) DROP TABLE IF EXISTS items
    2) CREATE TABLE items (tipos del subject / CSV real)
    3) COPY de todos los datos (copy_expert = rápido)

    Cabecera real del CSV de este repo:
      product_id,category_id,category_code,brand

    Tipos (≥ 3 distintos):
      INTEGER   → product_id (valores caben en entero estándar)
      BIGINT    → category_id (números muy grandes, p. ej. 1487580…)
      VARCHAR   → category_code y brand (texto; pueden ir vacíos)
    """
    print(f"→ {csv_path}  ⇒  tabla «{TABLE_NAME}»")

    # f"""...""" = cadena multilínea; {TABLE_NAME} se sustituye por "items"
    create_sql = f"""
    DROP TABLE IF EXISTS {TABLE_NAME};
    CREATE TABLE {TABLE_NAME} (
        product_id      INTEGER,
        category_id     BIGINT,
        category_code   VARCHAR(255),
        brand           VARCHAR(100)
    );
    """

    # "with ... as ..." abre y cierra el recurso solo (aunque haya error).
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(create_sql)

            # Abrir el CSV en modo lectura
            with open(csv_path, "r", encoding="utf-8") as f:
                next(f)  # saltar la cabecera (product_id,category_id,...)
                # copy_expert ≈ COPY de SQL: carga masiva, no fila a fila
                cur.copy_expert(
                    f"COPY {TABLE_NAME} FROM STDIN WITH (FORMAT csv)",
                    f,
                )
        # commit = guardar los cambios de forma definitiva
        conn.commit()

    print(f"✓ Tabla {TABLE_NAME} creada e importada")


# ===========================================================================
# PROGRAMA PRINCIPAL
# ===========================================================================

def main() -> None:
    """
    1) Resolver ruta del CSV (argumento o búsqueda automática)
    2) Crear tabla items + cargar datos
    """
    # sys.argv[1] = primer argumento extra, si existe
    # Ejemplo: python3 items_table.py ../subject/item/item.csv
    cli_path = sys.argv[1] if len(sys.argv) > 1 else None

    csv_path = find_item_csv(cli_path)
    print(f"CSV de productos: {csv_path}")
    print()

    create_and_load_items(csv_path)

    print("\nProceso terminado.")


# ---------------------------------------------------------------------------
# Interruptor de arranque:
#   - Si ejecutas este archivo → se llama a main()
#   - Si otro archivo hace "import items_table" → no se lanza solo
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    main()
