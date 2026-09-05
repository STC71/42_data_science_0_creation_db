#!/usr/bin/env bash

# ==================================================================
# PISCINE PEDAGO - DATA SCIENCE - sternero - 42 Málaga - sep. 2026
#               Data Science 0 - Creation DB - EX01

# install.sh - Instalador de pgAdmin 4 para EX01.
#
# IMPORTANTE:
#   - NO modifica PostgreSQL, Docker ni EX00/.env.
#   - NO detiene ni reinicia pgAdmin.
#   - NO elimina archivos ni instalaciones.
#   - Si pgAdmin está ejecutándose, aborta antes de modificar nada.
#   - NO parchea ni reescribe archivos del código de pgAdmin.
#   - Una instalación existente e incompleta NO se reutiliza.
# ==================================================================

set -u
set -o pipefail

RESET='\033[0m'
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

PGADMIN_VERSION="${PGADMIN_VERSION:-9.17}"
PGADMIN_DIR="${PGADMIN_DIR:-$HOME/sgoinfre/pgadmin4}"
PGADMIN_VENV="$PGADMIN_DIR/venv"
PGADMIN_EXEC="$PGADMIN_VENV/bin/pgadmin4"
PYTHON_BIN="$PGADMIN_VENV/bin/python"
CONFIG_DIR="$PGADMIN_DIR/config"
CONFIG_FILE="$CONFIG_DIR/config_local.py"
DATA_DIR="$PGADMIN_DIR/data"
SQLITE_PATH="$DATA_DIR/pgadmin4.db"
SESSION_DB_PATH="$DATA_DIR/sessions"
STORAGE_DIR="$DATA_DIR/storage"
LOG_FILE="$DATA_DIR/pgadmin4.log"
PGADMIN_URL="http://127.0.0.1:5050"

info() { echo -e "${CYAN}→ $*${RESET}"; }
ok() { echo -e "${GREEN}✓ $*${RESET}"; }
warn() { echo -e "${YELLOW}⚠ $*${RESET}"; }
error() { echo -e "${RED}✗ $*${RESET}" >&2; }
section()
{
    echo
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BLUE}${BOLD}$*${RESET}"
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo
}
die() { error "$*"; exit 1; }

check_user()
{
    section "1. Comprobación del entorno local"
    [[ "$(id -u)" -ne 0 ]] || die "No ejecutes este instalador como root."
    ok "Usuario actual: $(id -un)"
    ok "Directorio del script: $SCRIPT_DIR"
    ok "Directorio de pgAdmin: $PGADMIN_DIR"
}

check_python()
{
    local version major minor
    section "2. Comprobación de Python"
    command -v python3 >/dev/null 2>&1 || die "No se encontró python3 en PATH."
    version="$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:3])))')"
    major="$(python3 -c 'import sys; print(sys.version_info[0])')"
    minor="$(python3 -c 'import sys; print(sys.version_info[1])')"
    ok "Python detectado: $version"
    if [[ "$major" -ne 3 || "$minor" -lt 10 ]]; then
        die "pgAdmin $PGADMIN_VERSION requiere Python 3.10 o superior en este entorno."
    fi
    python3 -m venv --help >/dev/null 2>&1 || die "El módulo python3-venv no está disponible."
    ok "python3 -m venv está disponible."
}

get_pgadmin_pids()
{
    local uid pid pids=""
    uid="$(id -u)"
    while read -r pid; do
        [[ -z "$pid" ]] && continue
        if ps -p "$pid" -o user=,args= 2>/dev/null | grep -Fq "$(id -un)"; then
            pids="$pids $pid"
        fi
    done < <(pgrep -u "$uid" -f 'pgadmin4|pgAdmin4' 2>/dev/null || true)
    echo "$pids" | xargs
}

check_pgadmin_stopped()
{
    local pids
    section "3. Comprobación de seguridad antes de modificar"
    pids="$(get_pgadmin_pids)"
    if [[ -n "$pids" ]]; then
        error "pgAdmin está actualmente ejecutándose."
        echo
        echo "Procesos detectados:"
        for pid in $pids; do
            ps -p "$pid" -o pid=,user=,args= 2>/dev/null || true
        done
        echo
        warn "Este instalador NO va a detener ni reiniciar pgAdmin."
        warn "Detén pgAdmin manualmente con start.sh y vuelve a ejecutar install.sh."
        exit 2
    fi
    ok "No se detectan procesos de pgAdmin del usuario actual."
}

prepare_directories()
{
    section "4. Preparación de directorios"
    mkdir -p "$PGADMIN_DIR" "$CONFIG_DIR" "$DATA_DIR" "$SESSION_DB_PATH" "$STORAGE_DIR" ||
        die "No se pudieron crear los directorios de pgAdmin."
    ok "Directorios preparados."
    echo "  Instalación : $PGADMIN_DIR"
    echo "  Configuración: $CONFIG_DIR"
    echo "  Datos        : $DATA_DIR"
    echo "  Sesiones     : $SESSION_DB_PATH"
    echo "  Storage      : $STORAGE_DIR"
}

configure_pgadmin()
{
    section "5. Configuración local de pgAdmin"
    if [[ -f "$CONFIG_FILE" ]]; then
        ok "config_local.py ya existe."
        echo "  $CONFIG_FILE"
        return 0
    fi

    info "Creando configuración local escribible para usuario normal..."
    cat > "$CONFIG_FILE" <<EOF_CONFIG
# ============================================================
# pgAdmin 4 - configuración local para 42 Málaga / EX01
# ============================================================

DATA_DIR = '$DATA_DIR'
SQLITE_PATH = '$SQLITE_PATH'
SESSION_DB_PATH = '$SESSION_DB_PATH'
STORAGE_DIR = '$STORAGE_DIR'
LOG_FILE = '$LOG_FILE'

# Logging moderado para uso local.
CONSOLE_LOG_LEVEL = 20
FILE_LOG_LEVEL = 20
EOF_CONFIG
    ok "config_local.py creado."
}

get_site_packages_pgadmin()
{
    "$PYTHON_BIN" -c 'import pathlib, pgadmin4; print(pathlib.Path(pgadmin4.__file__).resolve().parent)' 2>/dev/null
}

install_pgadmin()
{
    local installed_version=""
    section "6. Instalación de pgAdmin $PGADMIN_VERSION"

    if [[ -x "$PGADMIN_EXEC" && -x "$PYTHON_BIN" ]]; then
        installed_version="$($PYTHON_BIN -c 'import importlib.metadata as m; print(m.version("pgadmin4"))' 2>/dev/null || true)"
        if [[ "$installed_version" == "$PGADMIN_VERSION" ]]; then
            ok "pgAdmin $PGADMIN_VERSION ya está instalado."
            return 0
        fi
        if [[ -n "$installed_version" ]]; then
            warn "Se detectó pgAdmin $installed_version; se necesita $PGADMIN_VERSION."
        else
            warn "Existe un entorno pgAdmin, pero no se pudo determinar su versión."
        fi
        die "No se reemplaza automáticamente una instalación existente. Usa off_del.sh si necesitas eliminarla y reinstalarla."
    fi

    if [[ -d "$PGADMIN_VENV" ]]; then
        die "Existe un entorno virtual de pgAdmin incompleto. No se modifica ni se reutiliza. Usa off_del.sh si necesitas eliminarlo y reinstalar."
    fi

    info "Creando entorno virtual nuevo..."
    python3 -m venv "$PGADMIN_VENV" || die "No se pudo crear el entorno virtual."
    [[ -x "$PYTHON_BIN" ]] || die "El intérprete del venv no existe después de crear el entorno."

    info "Instalando pgAdmin $PGADMIN_VERSION..."
    "$PYTHON_BIN" -m pip install "pgadmin4==$PGADMIN_VERSION" || die "La instalación de pgAdmin $PGADMIN_VERSION ha fallado."

    installed_version="$($PYTHON_BIN -c 'import importlib.metadata as m; print(m.version("pgadmin4"))' 2>/dev/null || true)"
    [[ "$installed_version" == "$PGADMIN_VERSION" ]] || die "La versión instalada no coincide con $PGADMIN_VERSION."
    ok "pgAdmin $installed_version instalado correctamente."
}

check_executable()
{
    section "7. Verificación del ejecutable"
    [[ -x "$PGADMIN_EXEC" ]] || die "No existe el ejecutable esperado: $PGADMIN_EXEC"
    ok "Ejecutable encontrado."
    echo "  $PGADMIN_EXEC"
}

verify_authentication_model()
{
    local site model_file
    section "8. Verificación de compatibilidad de autenticación"
    site="$(get_site_packages_pgadmin)"
    [[ -n "$site" && -d "$site" ]] || die "No se pudo localizar el paquete pgAdmin instalado."
    model_file="$site/pgadmin/model/__init__.py"
    [[ -f "$model_file" ]] || die "No se encontró el modelo de usuario: $model_file"

    echo "Modelo detectado:"
    echo "  $model_file"
    echo

    # Esta comprobación es deliberadamente de solo lectura.
    # No se modifica el código instalado de pgAdmin.
    "$PYTHON_BIN" - "$model_file" <<'PY_VERIFY'
from pathlib import Path
import sys

text = Path(sys.argv[1]).read_text()

active = text.find("def is_active(self):")
if active < 0:
    raise SystemExit("No se encontró User.is_active().")
active_block = text[active:active + 500]
if "not self.locked" not in active_block:
    raise SystemExit("User.is_active() no refleja el estado locked esperado.")

locked = text.find("def is_locked(self, form_error=None):")
if locked < 0:
    raise SystemExit("No se encontró User.is_locked().")
locked_block = text[locked:locked + 700]
if "if self.locked:" not in locked_block:
    raise SystemExit("No se encontró el bloque de estado locked.")
if "return True" not in locked_block:
    raise SystemExit("User.is_locked() no contiene el retorno esperado para una cuenta bloqueada.")
if "return False" not in locked_block:
    raise SystemExit("User.is_locked() no contiene el retorno esperado para una cuenta no bloqueada.")
PY_VERIFY
    ok "El modelo de autenticación presenta la lógica esperada."
}

initialize_database()
{
    section "9. Base de datos interna de pgAdmin"
    if [[ -f "$SQLITE_PATH" ]]; then
        ok "Base de datos de pgAdmin ya existe."
        echo "  $SQLITE_PATH"
        return 0
    fi

    info "Creando la base de configuración mediante setup.py..."
    local setup_py
    setup_py="$($PYTHON_BIN -c 'import pathlib, pgadmin4; print(pathlib.Path(pgadmin4.__file__).resolve().parent / "setup.py")' 2>/dev/null)"
    [[ -f "$setup_py" ]] || die "No se encontró setup.py en el paquete pgAdmin."
    PYTHONPATH="$CONFIG_DIR${PYTHONPATH:+:$PYTHONPATH}" "$PYTHON_BIN" "$setup_py" setup-db ||
        die "No se pudo inicializar la base de datos de pgAdmin."

    [[ -f "$SQLITE_PATH" ]] || die "setup-db terminó, pero no apareció $SQLITE_PATH"
    ok "Base de configuración creada."
}

verify_import()
{
    section "10. Prueba de importación"
    PYTHONPATH="$CONFIG_DIR${PYTHONPATH:+:$PYTHONPATH}" "$PYTHON_BIN" - <<'PY_IMPORT'
import importlib.metadata as metadata
import pgadmin
import flask
import flask_security
import sqlalchemy
import psycopg

print("pgAdmin       :", metadata.version("pgadmin4"))
print("Flask         :", metadata.version("Flask"))
print("Flask-Security:", metadata.version("Flask-Security-Too"))
print("SQLAlchemy    :", sqlalchemy.__version__)
print("psycopg       :", psycopg.__version__)
PY_IMPORT
    ok "Las dependencias principales se pueden importar correctamente."
}

print_summary()
{
    section "11. Instalación finalizada"
    echo -e "${GREEN}${BOLD}✓ pgAdmin $PGADMIN_VERSION está preparado para EX01.${RESET}"
    echo
    echo "  Instalación : $PGADMIN_DIR"
    echo "  Ejecutable  : $PGADMIN_EXEC"
    echo "  Config      : $CONFIG_FILE"
    echo "  SQLite      : $SQLITE_PATH"
    echo "  URL         : $PGADMIN_URL"
    echo
    echo -e "${CYAN}Importante:${RESET}"
    echo "  • install.sh no ha iniciado pgAdmin."
    echo "  • install.sh no ha detenido ningún proceso."
    echo "  • PostgreSQL/Docker/.env no han sido modificados."
    echo
    echo -e "${CYAN}Siguiente paso:${RESET}"
    echo "  Ejecuta el start.sh de EX01 para arrancar y comprobar pgAdmin."
    echo
}

main()
{
    clear 2>/dev/null || true
    echo
    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║                                                            ║${RESET}"
    echo -e "${CYAN}${BOLD}║              PISCINE PEDAGO - DATA SCIENCE                 ║${RESET}"
    echo -e "${CYAN}${BOLD}║                       EX01 - pgAdmin                       ║${RESET}"
    echo -e "${CYAN}${BOLD}║                                                            ║${RESET}"
    echo -e "${CYAN}${BOLD}║                         INSTALADOR                         ║${RESET}"
    echo -e "${CYAN}${BOLD}║                                                            ║${RESET}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════╝${RESET}"
    echo

    check_user
    check_python
    check_pgadmin_stopped
    prepare_directories
    configure_pgadmin
    install_pgadmin
    check_executable
    verify_authentication_model
    initialize_database
    verify_import
    print_summary
}

main "$@"
