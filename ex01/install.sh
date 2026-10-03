#!/usr/bin/env bash

# ============================================================================
#  PISCINE PEDAGO - DATA SCIENCE
#  Data Science 0 - Creation DB - EX01
#  install.sh  ·  Instalador de pgAdmin 4 para el campus 42
#  sternero · 42 Málaga · Septiembre 2026
# ============================================================================
#
#  FILOSOFÍA DE SEGURIDAD (NO negociable)
#  -------------------------------------
#  ✓ NO usa sudo
#  ✓ NO modifica PostgreSQL, Docker ni EX00/.env
#  ✓ NO detiene ni reinicia pgAdmin
#  ✓ NO elimina archivos ni instalaciones
#  ✓ Si pgAdmin está ejecutándose → ABORTA antes de tocar nada
#  ✓ Instalación parcial / versión distinta / contenido desconocido → ABORTA
#  ✓ Solo instala cuando no hay instalación usable
#  ✓ Solo lectura sobre el código de pgAdmin (verificación, no parcheo ciego)
#  ✓ Idempotente: una instalación correcta de 9.17 se respeta
#
# ============================================================================

set -u
set -o pipefail

# ------------------------------------------------------------------
# Colores
# ------------------------------------------------------------------
RESET='\033[0m'
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'

# ------------------------------------------------------------------
# Configuración central
# ------------------------------------------------------------------
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

# ------------------------------------------------------------------
# Helpers visuales
# ------------------------------------------------------------------
info()    { echo -e "${CYAN}→ $*${RESET}"; }
ok()      { echo -e "${GREEN}✓ $*${RESET}"; }
warn()    { echo -e "${YELLOW}⚠ $*${RESET}"; }
error()   { echo -e "${RED}✗ $*${RESET}" >&2; }
title()   { echo -e "${WHITE}${BOLD}$*${RESET}"; }
die()     { error "$*"; exit 1; }

section()
{
    echo
    echo -e "${MAGENTA}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${MAGENTA}${BOLD}$*${RESET}"
    echo -e "${MAGENTA}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo
}

phase()
{
    echo
    echo -e "${BLUE}${BOLD}┌──────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${BLUE}${BOLD}│  $*${RESET}"
    echo -e "${BLUE}${BOLD}└──────────────────────────────────────────────────────────┘${RESET}"
    echo
}

print_header()
{
    clear 2>/dev/null || true
    echo
    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║                                                            ║${RESET}"
    echo -e "${CYAN}${BOLD}║              PISCINE PEDAGO - DATA SCIENCE                 ║${RESET}"
    echo -e "${CYAN}${BOLD}║                                                            ║${RESET}"
    echo -e "${CYAN}${BOLD}║              Data Science 0 - Creation DB                  ║${RESET}"
    echo -e "${CYAN}${BOLD}║                          EX01                              ║${RESET}"
    echo -e "${CYAN}${BOLD}║                                                            ║${RESET}"
    echo -e "${CYAN}${BOLD}║                   INSTALADOR pgAdmin 4                     ║${RESET}"
    echo -e "${CYAN}${BOLD}║                                                            ║${RESET}"
    echo -e "${CYAN}${BOLD}║                   sternero · 42 Málaga                     ║${RESET}"
    echo -e "${CYAN}${BOLD}║                                                            ║${RESET}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════╝${RESET}"
    echo
    echo -e "${WHITE}  Objetivo : instalar pgAdmin ${PGADMIN_VERSION} de forma segura y reproducible${RESET}"
    echo -e "${WHITE}  Destino  : ${PGADMIN_DIR}${RESET}"
    echo
    echo -e "${YELLOW}  Este script NUNCA:${RESET}"
    echo -e "    • usa sudo"
    echo -e "    • toca Docker / PostgreSQL / EX00/.env"
    echo -e "    • detiene o reinicia pgAdmin"
    echo -e "    • elimina instalaciones existentes"
    echo -e "    • parchea código de pgAdmin a ciegas"
    echo
}

# ------------------------------------------------------------------
# 1. CHECK — entorno local
# ------------------------------------------------------------------
check_user()
{
    section "🔎  1. CHECK · Entorno local"
    echo -e "${WHITE}Comprobamos que no se está ejecutando como root y que${RESET}"
    echo -e "${WHITE}disponemos de un usuario normal con permisos de escritura.${RESET}"
    echo

    if [[ "$(id -u)" -eq 0 ]]; then
        die "No ejecutes este instalador como root. Usa tu usuario de estudiante."
    fi
    ok "Usuario actual : $(id -un) (uid=$(id -u))"
    ok "Directorio del script : $SCRIPT_DIR"
    ok "Directorio objetivo de pgAdmin : $PGADMIN_DIR"
}

check_python()
{
    section "🐍  2. CHECK · Python"
    echo -e "${WHITE}pgAdmin 4 ${PGADMIN_VERSION} necesita Python 3.10 o superior${RESET}"
    echo -e "${WHITE}y el módulo venv disponible.${RESET}"
    echo

    command -v python3 >/dev/null 2>&1 || die "No se encontró python3 en el PATH."

    local version major minor
    version="$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:3])))')"
    major="$(python3 -c 'import sys; print(sys.version_info[0])')"
    minor="$(python3 -c 'import sys; print(sys.version_info[1])')"

    ok "Python detectado : $version"

    if [[ "$major" -ne 3 || "$minor" -lt 10 ]]; then
        die "Se requiere Python 3.10 o superior (detectado $version)."
    fi

    if ! python3 -m venv --help >/dev/null 2>&1; then
        die "El módulo python3-venv no está disponible."
    fi
    ok "python3 -m venv está disponible."
}

# ------------------------------------------------------------------
# Detección de procesos pgAdmin
# ------------------------------------------------------------------
get_pgadmin_pids()
{
    local uid pid
    uid="$(id -u)"
    while read -r pid; do
        [[ -z "$pid" ]] && continue
        if ps -p "$pid" -o user=,args= 2>/dev/null | grep -Fq "$(id -un)"; then
            echo "$pid"
        fi
    done < <(pgrep -u "$uid" -f 'pgadmin4|pgAdmin4' 2>/dev/null || true)
}

check_pgadmin_stopped()
{
    section "🛡️  3. CHECK · pgAdmin no debe estar en ejecución"
    echo -e "${WHITE}Por seguridad, este instalador se niega a modificar nada${RESET}"
    echo -e "${WHITE}mientras exista un proceso de pgAdmin del usuario actual.${RESET}"
    echo

    local pids
    pids="$(get_pgadmin_pids | tr '\n' ' ')"

    if [[ -n "${pids// }" ]]; then
        error "pgAdmin está actualmente ejecutándose."
        echo
        echo -e "${YELLOW}Procesos detectados:${RESET}"
        for pid in $pids; do
            ps -p "$pid" -o pid=,user=,args= 2>/dev/null || true
        done
        echo
        warn "Este instalador NO va a detener ni reiniciar pgAdmin."
        warn "Detén pgAdmin manualmente (desde start.sh o matando el proceso)"
        warn "y vuelve a ejecutar install.sh."
        exit 2
    fi
    ok "No se detectan procesos de pgAdmin del usuario actual."
}

# ------------------------------------------------------------------
# 2. DECIDE — inspección de la instalación existente
# ------------------------------------------------------------------
inspect_existing_installation()
{
    section "🧠  4. DECIDE · Inspección de la instalación existente"
    echo -e "${WHITE}Antes de tocar nada inspeccionamos el estado actual.${RESET}"
    echo -e "${WHITE}Posibles resultados:${RESET}"
    echo -e "  • Instalación completa y versión correcta  → se respeta (idempotente)"
    echo -e "  • Instalación completa pero versión distinta → ABORTA"
    echo -e "  • Instalación parcial / venv incompleto     → ABORTA"
    echo -e "  • Directorio con contenido desconocido      → ABORTA"
    echo -e "  • No existe instalación                     → se procederá a instalar"
    echo

    local has_dir=0 has_venv=0 has_exec=0 has_python=0 installed_version=""

    [[ -d "$PGADMIN_DIR" ]]   && has_dir=1
    [[ -d "$PGADMIN_VENV" ]]  && has_venv=1
    [[ -x "$PGADMIN_EXEC" ]]  && has_exec=1
    [[ -x "$PYTHON_BIN" ]]    && has_python=1

    if [[ $has_python -eq 1 ]]; then
        installed_version="$($PYTHON_BIN -c 'import importlib.metadata as m; print(m.version("pgadmin4"))' 2>/dev/null || true)"
    fi

    echo -e "${CYAN}Estado detectado:${RESET}"
    echo "  Directorio base     : $([[ $has_dir -eq 1 ]] && echo 'existe' || echo 'no existe')"
    echo "  Entorno virtual     : $([[ $has_venv -eq 1 ]] && echo 'existe' || echo 'no existe')"
    echo "  Ejecutable pgadmin4 : $([[ $has_exec -eq 1 ]] && echo 'existe' || echo 'no existe')"
    echo "  Python del venv     : $([[ $has_python -eq 1 ]] && echo 'existe' || echo 'no existe')"
    echo "  Versión instalada   : ${installed_version:-desconocida}"
    echo

    # Caso 1: instalación completa y versión correcta
    if [[ $has_exec -eq 1 && $has_python -eq 1 && "$installed_version" == "$PGADMIN_VERSION" ]]; then
        ok "Instalación completa de pgAdmin $PGADMIN_VERSION detectada."
        echo
        echo -e "${GREEN}${BOLD}→ Modo IDEMPOTENTE: no se reinstala ni se modifica el núcleo.${RESET}"
        echo -e "${GREEN}  Solo se asegurarán config, directorios de datos y verificaciones.${RESET}"
        INSTALL_NEEDED=0
        return 0
    fi

    # Caso 2: versión distinta
    if [[ $has_exec -eq 1 && $has_python -eq 1 && -n "$installed_version" && "$installed_version" != "$PGADMIN_VERSION" ]]; then
        error "Se detectó pgAdmin $installed_version, pero se necesita $PGADMIN_VERSION."
        echo
        warn "Este instalador NO reemplaza automáticamente una versión distinta."
        warn "Si quieres reinstalar, elimina la instalación de forma deliberada"
        warn "y vuelve a ejecutar install.sh."
        exit 3
    fi

    # Caso 3: venv incompleto o directorio con restos
    if [[ $has_venv -eq 1 || $has_exec -eq 1 || $has_python -eq 1 ]]; then
        error "Existe una instalación parcial o inconsistente de pgAdmin."
        echo
        warn "Por seguridad este script NO reutiliza ni repara instalaciones parciales."
        warn "Elimina de forma deliberada el directorio (o usa una herramienta de limpieza)"
        warn "y vuelve a ejecutar install.sh."
        echo
        echo "  Ruta afectada: $PGADMIN_DIR"
        exit 3
    fi

    # Caso 4: directorio existe pero está vacío o solo tiene cosas ajenas
    if [[ $has_dir -eq 1 ]]; then
        # Si el directorio tiene contenido que no reconocemos, somos conservadores
        local count
        count="$(find "$PGADMIN_DIR" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l | tr -d ' ')"
        if [[ "$count" -gt 0 ]]; then
            error "El directorio $PGADMIN_DIR existe y contiene elementos no reconocidos."
            echo
            warn "No se va a sobrescribir contenido desconocido."
            warn "Revisa o vacía el directorio de forma deliberada y vuelve a ejecutar."
            exit 3
        fi
    fi

    # Caso 5: instalación limpia → se puede instalar
    ok "No existe una instalación usable de pgAdmin."
    echo -e "${GREEN}→ Se procederá a una instalación limpia.${RESET}"
    INSTALL_NEEDED=1
}

# ------------------------------------------------------------------
# 3. INSTALL
# ------------------------------------------------------------------
prepare_directories()
{
    section "📦  5. INSTALL · Preparación de directorios"
    echo -e "${WHITE}Creamos únicamente rutas escribibles por el usuario.${RESET}"
    echo -e "${WHITE}Nunca se usan /var/lib/pgadmin ni /var/log/pgadmin.${RESET}"
    echo

    mkdir -p "$PGADMIN_DIR" "$CONFIG_DIR" "$DATA_DIR" "$SESSION_DB_PATH" "$STORAGE_DIR" ||
        die "No se pudieron crear los directorios de pgAdmin."

    ok "Directorios preparados."
    echo "  Instalación   : $PGADMIN_DIR"
    echo "  Configuración : $CONFIG_DIR"
    echo "  Datos         : $DATA_DIR"
    echo "  Sesiones      : $SESSION_DB_PATH"
    echo "  Storage       : $STORAGE_DIR"
}

configure_pgadmin()
{
    section "⚙️  6. INSTALL · config_local.py"
    echo -e "${WHITE}pgAdmin permite sobrescribir rutas mediante config_local.py.${RESET}"
    echo -e "${WHITE}Así evitamos completamente los directorios del sistema.${RESET}"
    echo

    if [[ -f "$CONFIG_FILE" ]]; then
        ok "config_local.py ya existe (se respeta)."
        echo "  $CONFIG_FILE"
        return 0
    fi

    info "Creando configuración local escribible..."
    cat > "$CONFIG_FILE" <<EOF_CONFIG
# ============================================================
# pgAdmin 4 - configuración local para 42 Málaga / EX01
# Generado por install.sh · no requiere sudo
# ============================================================

DATA_DIR = '$DATA_DIR'
SQLITE_PATH = '$SQLITE_PATH'
SESSION_DB_PATH = '$SESSION_DB_PATH'
STORAGE_DIR = '$STORAGE_DIR'
LOG_FILE = '$LOG_FILE'

# Logging moderado para uso local en el campus
CONSOLE_LOG_LEVEL = 20
FILE_LOG_LEVEL = 20
EOF_CONFIG

    ok "config_local.py creado."
    echo "  $CONFIG_FILE"
}

install_pgadmin_package()
{
    section "📥  7. INSTALL · paquete pgAdmin $PGADMIN_VERSION"

    if [[ "${INSTALL_NEEDED:-1}" -eq 0 ]]; then
        ok "Instalación ya presente y correcta. Se omite pip install."
        return 0
    fi

    echo -e "${WHITE}Se crea un entorno virtual nuevo y se instala exactamente${RESET}"
    echo -e "${WHITE}la versión auditada: pgadmin4==${PGADMIN_VERSION}${RESET}"
    echo
    echo -e "${YELLOW}No se actualiza pip/setuptools/wheel globalmente para${RESET}"
    echo -e "${YELLOW}mantener la instalación lo más reproducible posible.${RESET}"
    echo

    info "Creando entorno virtual en $PGADMIN_VENV ..."
    python3 -m venv "$PGADMIN_VENV" || die "No se pudo crear el entorno virtual."
    [[ -x "$PYTHON_BIN" ]] || die "El intérprete del venv no existe después de crearlo."
    ok "Entorno virtual creado."

    info "Instalando pgadmin4==$PGADMIN_VERSION (puede tardar un poco)..."
    if ! "$PYTHON_BIN" -m pip install --disable-pip-version-check "pgadmin4==$PGADMIN_VERSION"; then
        die "La instalación de pgAdmin $PGADMIN_VERSION ha fallado."
    fi

    local installed_version
    installed_version="$($PYTHON_BIN -c 'import importlib.metadata as m; print(m.version("pgadmin4"))' 2>/dev/null || true)"
    [[ "$installed_version" == "$PGADMIN_VERSION" ]] || \
        die "La versión instalada ($installed_version) no coincide con $PGADMIN_VERSION."

    ok "pgAdmin $installed_version instalado correctamente."
}

check_executable()
{
    section "🧪  8. VERIFY · Ejecutable"
    [[ -x "$PGADMIN_EXEC" ]] || die "No existe el ejecutable esperado: $PGADMIN_EXEC"
    ok "Ejecutable encontrado y con permisos de ejecución."
    echo "  $PGADMIN_EXEC"
}

# ------------------------------------------------------------------
# Verificación de autenticación (solo lectura)
# ------------------------------------------------------------------
get_site_packages_pgadmin()
{
    "$PYTHON_BIN" -c 'import pathlib, pgadmin4; print(pathlib.Path(pgadmin4.__file__).resolve().parent)' 2>/dev/null
}

verify_authentication_model()
{
    section "🔐  9. VERIFY · Modelo de autenticación (solo lectura)"
    echo -e "${WHITE}Comprobamos que User.is_active / User.is_locked presentan${RESET}"
    echo -e "${WHITE}la lógica esperada. NO se modifica ningún archivo de pgAdmin.${RESET}"
    echo

    local site model_file
    site="$(get_site_packages_pgadmin)"
    [[ -n "$site" && -d "$site" ]] || die "No se pudo localizar el paquete pgAdmin instalado."
    model_file="$site/pgadmin/model/__init__.py"
    [[ -f "$model_file" ]] || die "No se encontró el modelo de usuario: $model_file"

    echo "Modelo detectado:"
    echo "  $model_file"
    echo

    if ! "$PYTHON_BIN" - "$model_file" <<'PY_VERIFY'
from pathlib import Path
import sys

text = Path(sys.argv[1]).read_text(encoding="utf-8", errors="replace")

active = text.find("def is_active(self):")
if active < 0:
    raise SystemExit("No se encontró User.is_active().")
active_block = text[active:active + 600]
if "not self.locked" not in active_block:
    raise SystemExit("User.is_active() no refleja el estado locked esperado.")

locked = text.find("def is_locked(self")
if locked < 0:
    raise SystemExit("No se encontró User.is_locked().")
locked_block = text[locked:locked + 900]
if "if self.locked:" not in locked_block:
    raise SystemExit("No se encontró el bloque de estado locked.")
if "return True" not in locked_block or "return False" not in locked_block:
    raise SystemExit("User.is_locked() no contiene los retornos esperados.")
print("OK")
PY_VERIFY
    then
        die "La verificación del modelo de autenticación ha fallado."
    fi

    ok "El modelo de autenticación presenta la lógica esperada."
}

initialize_database()
{
    section "🗄️  10. VERIFY · Base de datos interna de pgAdmin"
    echo -e "${WHITE}pgAdmin guarda su propia configuración (usuarios, servidores,${RESET}"
    echo -e "${WHITE}preferencias) en una base SQLite. La inicializamos con setup-db${RESET}"
    echo -e "${WHITE}si todavía no existe.${RESET}"
    echo

    if [[ -f "$SQLITE_PATH" ]]; then
        ok "Base de datos de pgAdmin ya existe."
        echo "  $SQLITE_PATH"
        return 0
    fi

    info "Creando la base de configuración mediante setup.py setup-db ..."
    local setup_py
    setup_py="$($PYTHON_BIN -c 'import pathlib, pgadmin4; print(pathlib.Path(pgadmin4.__file__).resolve().parent / "setup.py")' 2>/dev/null)"
    [[ -f "$setup_py" ]] || die "No se encontró setup.py en el paquete pgAdmin."

    if ! PYTHONPATH="$CONFIG_DIR${PYTHONPATH:+:$PYTHONPATH}" \
        "$PYTHON_BIN" "$setup_py" setup-db; then
        die "No se pudo inicializar la base de datos de pgAdmin."
    fi

    [[ -f "$SQLITE_PATH" ]] || die "setup-db terminó, pero no apareció $SQLITE_PATH"
    ok "Base de configuración creada."
    echo "  $SQLITE_PATH"
}

verify_import()
{
    section "🧪  11. VERIFY · Importación de dependencias clave"
    echo -e "${WHITE}Comprobamos que las librerías principales se pueden importar${RESET}"
    echo -e "${WHITE}desde el entorno virtual recién instalado.${RESET}"
    echo

    if ! PYTHONPATH="$CONFIG_DIR${PYTHONPATH:+:$PYTHONPATH}" "$PYTHON_BIN" - <<'PY_IMPORT'
import importlib.metadata as metadata
import pgadmin
import flask
import flask_security
import sqlalchemy
import psycopg

print("  pgAdmin        :", metadata.version("pgadmin4"))
print("  Flask          :", metadata.version("Flask"))
print("  Flask-Security :", metadata.version("Flask-Security-Too"))
print("  SQLAlchemy     :", sqlalchemy.__version__)
print("  psycopg        :", psycopg.__version__)
PY_IMPORT
    then
        die "Falló la importación de alguna dependencia principal."
    fi
    echo
    ok "Las dependencias principales se pueden importar correctamente."
}

# ------------------------------------------------------------------
# Resumen final
# ------------------------------------------------------------------
print_summary()
{
    section "✅  12. RESUMEN FINAL"
    echo -e "${GREEN}${BOLD}✓ pgAdmin $PGADMIN_VERSION está preparado para EX01.${RESET}"
    echo
    echo -e "${WHITE}  Instalación   :${RESET} $PGADMIN_DIR"
    echo -e "${WHITE}  Ejecutable    :${RESET} $PGADMIN_EXEC"
    echo -e "${WHITE}  Configuración :${RESET} $CONFIG_FILE"
    echo -e "${WHITE}  SQLite        :${RESET} $SQLITE_PATH"
    echo -e "${WHITE}  URL           :${RESET} $PGADMIN_URL"
    echo
    echo -e "${CYAN}${BOLD}Lo que este script HA hecho:${RESET}"
    echo "  • Comprobado el entorno (usuario, Python, venv)"
    echo "  • Abortado si pgAdmin estaba en ejecución"
    echo "  • Inspeccionado cualquier instalación previa"
    echo "  • Creado directorios escribibles por el usuario"
    echo "  • Generado config_local.py (rutas locales)"
    echo "  • Instalado pgadmin4==$PGADMIN_VERSION en un venv propio"
    echo "  • Inicializado la base SQLite de configuración"
    echo "  • Verificado el modelo de autenticación (solo lectura)"
    echo "  • Verificado las importaciones principales"
    echo
    echo -e "${YELLOW}${BOLD}Lo que este script NO ha hecho:${RESET}"
    echo "  • No ha usado sudo"
    echo "  • No ha tocado Docker / PostgreSQL / EX00/.env"
    echo "  • No ha detenido ni reiniciado pgAdmin"
    echo "  • No ha eliminado ninguna instalación"
    echo "  • No ha parcheado código de pgAdmin"
    echo
    echo -e "${CYAN}${BOLD}Siguiente paso:${RESET}"
    echo "  Ejecuta el start.sh de EX01 para arrancar y comprobar pgAdmin."
    echo
    echo -e "${GREEN}¡Instalación finalizada con éxito!${RESET}"
    echo
}

# ------------------------------------------------------------------
# main
# ------------------------------------------------------------------
main()
{
    INSTALL_NEEDED=1

    print_header

    phase "FASE CHECK  ·  comprobaciones previas"
    check_user
    check_python
    check_pgadmin_stopped

    phase "FASE DECIDE ·  inspección de la instalación"
    inspect_existing_installation

    phase "FASE INSTALL ·  instalación / configuración"
    prepare_directories
    configure_pgadmin
    install_pgadmin_package

    phase "FASE VERIFY ·  verificaciones finales"
    check_executable
    verify_authentication_model
    initialize_database
    verify_import

    print_summary
}

main "$@"
