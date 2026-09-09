#!/usr/bin/env python3

# Con la línea de arriba, podemos ejecutar el script directamente en Linux/Mac:
# 	chmod +x automatic_table.py
#	./automatic_table.py	sin tener que escribir "python3" delante.

# -*- coding: utf-8 -*-

# El comentario de arriba indica a Python que el archivo está en UTF-8.
# UTF-8 es un estándar de codificación de caracteres que permite usar acentos, eñes, etc.
# Sin esto, Python 3 asume UTF-8 por defecto, pero es buena práctica indicarlo explícitamente.

"""
EX03 – Automatic table (Piscine Data Science – Module 0)

Objetivo (subject):
  - Mirar la carpeta customer/
  - Encontrar TODOS los archivos que terminan en .csv (sin escribir sus nombres a mano)
  - Por cada CSV: crear una tabla en PostgreSQL con el mismo nombre (sin .csv)
  - Cargar los datos del CSV en esa tabla

Analogía:
  Tienes varias cajas (CSV). Este programa es un robot que:
  1) abre el almacén de cajas (carpeta customer/),
  2) lee la etiqueta de cada caja (nombre del archivo),
  3) monta una estantería con ese nombre (CREATE TABLE),
  4) vacía la caja en la estantería (COPY).
"""

# ---------------------------------------------------------------------------
# from __future__ import annotations
# Pide a Python un comportamiento moderno al anotar tipos (ej. str | None).
# No cambia la lógica del programa; solo ayuda a leer y a las herramientas.
# ---------------------------------------------------------------------------
from __future__ import annotations

# ---------------------------------------------------------------------------
# import ...
# "import" = "trae una caja de herramientas ya hecha".
# En lugar de reinventar la rueda, usamos módulos de Python o instalados.
# ---------------------------------------------------------------------------
import os          # hablar con el sistema: variables de entorno, usuario, etc.
import sys         # argumentos de la línea de comandos y salir del programa
from pathlib import Path  # rutas de archivos de forma cómoda y multiplataforma

# ===========================================================================
# DEPENDENCIAS: librerías que a veces no vienen instaladas en el campus
# ===========================================================================

def ensure_dependencies() -> None:
    """
    Comprueba si faltan librerías y, si faltan, intenta instalarlas.

    - psycopg2: permite a Python hablar con PostgreSQL
    - dotenv:   permite leer el archivo .env (usuario, contraseña, nombre de BD)

    "def" = definir una función (un bloque de pasos con nombre, reutilizable).
    "-> None" = esta función no devuelve un valor; solo hace trabajo.
    """
    import importlib.util  # para preguntar: "¿existe ya este módulo?"
    # importlib.util sirve para buscar módulos y ver si están instalados.
    # find_spec() devuelve información del módulo si existe, o None si no.
    import subprocess      # para ejecutar otro programa (aquí: pip)

    # Diccionario: clave = nombre del módulo al importar
    #              valor = nombre del paquete a instalar con pip
    # Ejemplo: para "import psycopg2" hay que instalar "psycopg2-binary".
    # Un diccionario es como una agenda: nombre → teléfono.
    needed = {
        "psycopg2": "psycopg2-binary",
        "dotenv": "python-dotenv",
    }

    # Lista de paquetes que faltan. A la lista la llamamos "missing".
    # En "missing" pondremos los nombres de paquetes a instalar
    # (los valores del diccionario "needed").
    missing = [
        pkg
        # pkg = nombre del paquete para pip; ejemplo: "psycopg2-binary"
        # mod = nombre del módulo al hacer import; ejemplo: "psycopg2"
        for mod, pkg in needed.items()
        # .items() recorre el diccionario como pares (clave, valor).
        # Por cada par (mod, pkg): si el módulo no existe, añadimos pkg.
        if importlib.util.find_spec(mod) is None
        # find_spec(mod) is None  ⇒  el módulo NO está instalado.
    ]

    # Si la lista no está vacía, instalamos lo que falte.
    if missing:
        # f"..." permite meter variables dentro de { }.
        # ', '.join(missing) = une los elementos de la lista con comas.
        # Ejemplo: ["a", "b"] → "a, b"
        print(f"🥁 Instalando dependencias: {', '.join(missing)} ...")
        subprocess.check_call(
            # check_call ejecuta un comando y espera a que termine.
            # Si el comando falla, lanza un error (no sigue como si nada).
            [sys.executable, "-m", "pip", "install", "--user", *missing]
            # sys.executable = ruta del Python que está ejecutando este script
            # -m pip install --user = instala para tu usuario (sin sudo)
            # *missing = desempaqueta la lista en argumentos sueltos
            #   Ejemplo: ["psycopg2-binary", "python-dotenv"]
            #   se convierte en: ... install --user psycopg2-binary python-dotenv
        )


# Llamamos a la función NADA MÁS empezar, antes de importar psycopg2/dotenv.
ensure_dependencies()  # Si faltan librerías, las instala aquí.

# Ahora sí: si faltaban, ya deberían estar instaladas.
import psycopg2                   # librería para hablar con PostgreSQL
from dotenv import load_dotenv    # función para leer el archivo .env


# ===========================================================================
# RUTAS: ¿dónde está este script y el proyecto?
# ===========================================================================

# __file__ = ruta de ESTE archivo (automatic_table.py)
# Path(...).resolve() = convierte a ruta absoluta "real" (sin .. ambiguos)
# .parent = la carpeta que contiene ese archivo
#
# Ejemplo práctico:
#   __file__     = /home/alguien/.../ex03/automatic_table.py
#   SCRIPT_DIR   = /home/alguien/.../ex03
#   PROJECT_DIR  = /home/alguien/.../data_science_0_creation_db
SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_DIR = SCRIPT_DIR.parent

# Credenciales de PostgreSQL: las leemos del .env de EX00 (buena práctica).
# Así NO escribimos la contraseña en el código fuente.
# El operador / entre Path une rutas de forma segura (mejor que concatenar textos).
ENV_FILE = PROJECT_DIR / "ex00" / ".env"
load_dotenv(ENV_FILE)  # carga en el entorno: POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB

# Diccionario de conexión a la base de datos.
# os.environ.get("CLAVE", "valor_por_defecto") significa:
#   - si existe la variable de entorno CLAVE → usa su valor
#   - si no existe → usa valor_por_defecto
DB_CONFIG = {
    "host": "localhost",  # el contenedor Docker publica PostgreSQL en esta máquina
    "port": 5432,         # puerto por defecto de PostgreSQL
    "dbname": os.environ.get("POSTGRES_DB", "piscineds"),
    "user": os.environ.get("POSTGRES_USER", os.environ.get("USER", "")),
    "password": os.environ.get("POSTGRES_PASSWORD", "mysecretpassword"),
}


# ===========================================================================
# ENCONTRAR LA CARPETA customer/ (sin rutas de un solo usuario)
# ===========================================================================

def find_customer_folder(cli_arg: str | None = None) -> Path:
    """
    Averigua dónde está la carpeta customer/.

    Orden de búsqueda:
      1) Si el usuario pasó una ruta al ejecutar el script, se usa esa.
      2) subject/customer  (layout frecuente en este repo)
      3) customer/ junto al proyecto
      4) customer/ dentro de ex03/

    "cli_arg: str | None" = puede ser un texto (ruta) o None (nadie pasó nada).
    "-> Path" = la función DEVUELVE un objeto Path (una ruta).
    """
    # Lista vacía donde iremos apuntando posibles ubicaciones.
    candidates: list[Path] = []

    # 1) Argumento de línea de comandos, si existe.
    # Ejemplo de uso en la terminal:
    #   python3 automatic_table.py /ruta/cualquiera/customer
    if cli_arg:
        # expanduser() convierte ~ en /home/tu_usuario
        # resolve() deja la ruta absoluta
        candidates.append(Path(cli_arg).expanduser().resolve())

    # 2) Rutas relativas al proyecto (valen para cualquier login del campus)
    candidates.extend(
        [
            PROJECT_DIR / "subject" / "customer",
            PROJECT_DIR / "customer",
            SCRIPT_DIR / "customer",
        ]
    )

    # Probar candidatos en orden: el primero que sea una carpeta real gana.
    for path in candidates:
        if path.is_dir():  # True si esa ruta existe y es un directorio
            return path    # devolvemos esa ruta y salimos de la función

    # Si llegamos aquí, no encontramos nada: mensaje claro y salida con error.
    print("🤬 ERROR: no se encontró la carpeta customer/.")
    print("Prueba:")
    print(" 🧑‍💻 python3 automatic_table.py /ruta/a/customer")
    print("Candidatos mirados:")
    for path in candidates:
        print(f" 🕵️ - {path}")
    sys.exit(1)  # terminar el programa con código de error (1 = algo falló)


def get_connection():
    """
    Abre una conexión con PostgreSQL usando DB_CONFIG.
    Es como 'llamar por teléfono' a la base de datos.
    """
    # **DB_CONFIG significa: descompón el diccionario en argumentos con nombre.
    # Equivale a escribir:
    #   psycopg2.connect(host="localhost", port=5432, dbname="piscineds", ...)
    return psycopg2.connect(**DB_CONFIG)


# ===========================================================================
# CREAR UNA TABLA Y CARGAR UN CSV
# ===========================================================================

def create_table_from_csv(csv_path: Path) -> None:
    """
    Por UN archivo CSV hace todo el trabajo de EX02, de forma automática:
      1) Nombre de tabla = nombre del archivo sin .csv
      2) Borrar la tabla si ya existía (reintentos limpios)
      3) Crear la tabla con tipos adecuados (reglas del subject / EX02)
      4) Copiar todos los datos del CSV (rápido; no fila a fila)
    """
    # .stem = nombre del fichero sin la extensión
    # Ejemplo: Path("data_2022_dec.csv").stem  →  "data_2022_dec"
    table_name = csv_path.stem
    print(f"📤 → {csv_path.name}  ⇒  tabla «{table_name}» 📥")

    # Texto SQL que enviaremos a PostgreSQL.
    # f"""...""" = cadena de varias líneas donde {table_name} se sustituye
    # por el valor de la variable table_name.
    #
    # Tipos (al menos 6 distintos; primera columna = fecha/hora):
    #   TIMESTAMPTZ   → fecha y hora con zona horaria
    #   VARCHAR(50)   → texto corto (hasta 50 caracteres)
    #   INTEGER       → número entero
    #   NUMERIC(10,2) → decimal con 2 cifras tras la coma (precios)
    #   BIGINT        → entero grande (IDs de usuario)
    #   UUID          → identificador de sesión con formato estándar
    create_sql = f"""
    DROP TABLE IF EXISTS {table_name};
    CREATE TABLE {table_name} (
        event_time    TIMESTAMPTZ,
        event_type    VARCHAR(50),
        product_id    INTEGER,
        price         NUMERIC(10,2),
        user_id       BIGINT,
        user_session  UUID
    );
    """

    # "with ... as ..." abre un recurso y lo cierra solo al terminar el bloque
    # (aunque haya un error a mitad). Así no dejamos conexiones colgadas.
    # Analogía: entras a una cabina telefónica; al salir, la puerta se cierra sola.
    with get_connection() as conn:
        with conn.cursor() as cur:
            # cursor = "bolígrafo" con el que escribimos órdenes SQL en la base
            cur.execute(create_sql)

            # Abrir el CSV en modo lectura ("r")
            # encoding="utf-8" = interpretar bien acentos y caracteres especiales
            with open(csv_path, "r", encoding="utf-8") as f:
                next(f)  # saltar la primera línea (cabecera: event_time,event_type,...)
                # copy_expert envía el resto del fichero a PostgreSQL como COPY.
                # Es la forma eficiente de meter millones de filas de golpe
                # (mucho mejor que un INSERT por cada fila).
                cur.copy_expert(
                    f"COPY {table_name} FROM STDIN WITH (FORMAT csv)",
                    f,
                )
        # commit = "guardar los cambios de forma definitiva"
        # Sin commit, en muchos casos los cambios no quedan persistidos.
        conn.commit()

    print(f"✅ Tabla {table_name} creada e importada")


# ===========================================================================
# PROGRAMA PRINCIPAL
# ===========================================================================

def main() -> None:
    """
    Punto de entrada de la lógica del ejercicio:
      1) Resolver carpeta customer/
      2) Listar todos los .csv (de forma automática)
      3) Procesar cada uno (crear tabla + cargar datos)
    """
    # sys.argv = lista de "palabras" que escribiste al lanzar el script.
    # sys.argv[0] = nombre del script
    # sys.argv[1] = primer argumento extra (si existe)
    #
    # Ejemplo:
    #   python3 automatic_table.py
    #       → len(sys.argv) == 1  →  cli_path = None
    #   python3 automatic_table.py ../subject/customer
    #       → sys.argv[1] == "../subject/customer"
    cli_path = sys.argv[1] if len(sys.argv) > 1 else None

    customer_dir = find_customer_folder(cli_path)
    print(f"🗂️ Carpeta customer: {customer_dir}")

    # glob("*.csv") = "dame todos los archivos cuyo nombre termina en .csv"
    # sorted(...)  = ordénalos alfabéticamente (dec, jan, nov, oct...)
    # El * de "*.csv" es un comodín: "cualquier nombre + .csv"
    csv_files = sorted(customer_dir.glob("*.csv"))

    # "if not csv_files" = si la lista está vacía
    if not csv_files:
        print("🚫 No hay archivos .csv en esa carpeta.")
        sys.exit(1)

    # len(csv_files) = cuántos elementos tiene la lista
    print(f"🗃️ Se encontraron {len(csv_files)} CSV:\n")

    # Bucle for: "para cada archivo de la lista, ejecuta este bloque"
    # Es el corazón de lo "automático": no escribimos los nombres a mano.
    for csv_file in csv_files:
        create_table_from_csv(csv_file)

    print("\n✅ Proceso terminado con éxito. 🎉")


# ---------------------------------------------------------------------------
# Este if es el "interruptor de arranque".
#
# __name__ es una variable especial de Python:
#   - Si ejecutas ESTE archivo directamente (python3 automatic_table.py),
#     __name__ vale "__main__" y se llama a main().
#   - Si otro archivo hace "import automatic_table", __name__ no es "__main__"
#     y no se lanza main() solo (útil para reutilizar funciones).
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    main()