#!/usr/bin/env bash

# ============================================================
# PISCINE PEDAGO - DATA SCIENCE
# Data Science 0 - Creation DB - EX01
# off_del.sh
#
# Herramienta de apagado y eliminacion opcional.
# IMPORTANTE: no ejecuta acciones destructivas sin confirmacion.
# ============================================================

RESET='\033[0m'
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'

ORIGINAL_DIR="$PWD"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
EX00_DIR="$SCRIPT_DIR/../ex00"
CONTAINER_NAME="postgres_piscineds"
PGADMIN_DIR="${PGADMIN_DIR:-$HOME/sgoinfre/pgadmin4}"
PGADMIN_VENV="$PGADMIN_DIR/venv"
PGADMIN_EXEC="$PGADMIN_VENV/bin/pgadmin4"
PGADMIN_PID_FILE="$PGADMIN_DIR/pgadmin.pid"
PSQL_BIN="$HOME/goinfre/bin/psql"
PSQL_ARCHIVE="/tmp/psql-x86-linux-static.tar.gz"
PSQL_EXTRACTED="/tmp/psql"
ZSHRC="$HOME/.zshrc"

restore_origin()
{
    cd "$ORIGINAL_DIR" 2>/dev/null || true
}
trap restore_origin EXIT

print_header()
{
    clear
    echo
    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║                                                            ║${RESET}"
    echo -e "${CYAN}${BOLD}║              PISCINE PEDAGO - DATA SCIENCE                 ║${RESET}"
    echo -e "${CYAN}${BOLD}║                                                            ║${RESET}"
    echo -e "${CYAN}${BOLD}║              Data Science 0 - Creation DB                  ║${RESET}"
    echo -e "${CYAN}${BOLD}║                          EX01                              ║${RESET}"
    echo -e "${CYAN}${BOLD}║                                                            ║${RESET}"
    echo -e "${CYAN}${BOLD}║                      OFF / DELETE                          ║${RESET}"
    echo -e "${CYAN}${BOLD}║                                                            ║${RESET}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════╝${RESET}"
    echo
    echo -e "${YELLOW}Directorio de origen: ${ORIGINAL_DIR}${RESET}"
    echo -e "${YELLOW}Este script no inicia ningun servicio.${RESET}"
    echo
}

ask_yes_no()
{
    local prompt="$1"
    local answer
    read -r -p "$(echo -e "${YELLOW}${prompt} [s/N] → ${RESET}")" answer
    [[ "$answer" =~ ^[SsYy]$ ]]
}

confirm_destructive()
{
    local target="$1"
    local answer

    echo -e "${RED}${BOLD}PELIGRO: esta accion es destructiva.${RESET}"
    echo -e "${RED}${target}${RESET}"
    echo -e "${RED}No se podra deshacer desde este script.${RESET}"
    echo
    read -r -p "$(echo -e "${YELLOW}Escribe ELIMINAR para continuar → ${RESET}")" answer
    [[ "$answer" == "ELIMINAR" ]]
}

show_status()
{
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BLUE}${BOLD}🔎 ESTADO DETECTADO (solo lectura)${RESET}"
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo

    if command -v docker >/dev/null 2>&1 && docker ps --format '{{.Names}}' 2>/dev/null | grep -qx "$CONTAINER_NAME"; then
        echo -e "${GREEN}✓ PostgreSQL: corriendo ($CONTAINER_NAME)${RESET}"
    elif command -v docker >/dev/null 2>&1 && docker ps -a --format '{{.Names}}' 2>/dev/null | grep -qx "$CONTAINER_NAME"; then
        echo -e "${YELLOW}ℹ PostgreSQL: contenedor detenido ($CONTAINER_NAME)${RESET}"
    else
        echo -e "${YELLOW}ℹ PostgreSQL: contenedor no detectado${RESET}"
    fi

    if pgrep -u "$(id -u)" -f "$PGADMIN_EXEC" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ pgAdmin: proceso activo${RESET}"
    else
        echo -e "${YELLOW}ℹ pgAdmin: proceso no detectado${RESET}"
    fi

    if [[ -x "$PSQL_BIN" ]]; then
        echo -e "${GREEN}✓ psql gestionado por este proyecto: $PSQL_BIN${RESET}"
    else
        echo -e "${YELLOW}ℹ psql gestionado por este proyecto: no detectado${RESET}"
    fi

    if command -v psql >/dev/null 2>&1; then
        echo -e "${CYAN}  psql actualmente visible en PATH: $(command -v psql)${RESET}"
    else
        echo -e "${YELLOW}ℹ psql no está visible en PATH${RESET}"
    fi

    if [[ -d "$PGADMIN_DIR" ]]; then
        echo -e "${GREEN}✓ Instalación pgAdmin detectada: $PGADMIN_DIR${RESET}"
    else
        echo -e "${YELLOW}ℹ Instalación pgAdmin no detectada${RESET}"
    fi
    echo
}

stop_pgadmin()
{
    local pids pid answer remaining
    pids="$(pgrep -u "$(id -u)" -f "$PGADMIN_EXEC" 2>/dev/null || true)"

    echo -e "${BLUE}${BOLD}⏹ DETENER pgAdmin${RESET}"
    echo "Se detendran solo procesos pgAdmin del usuario actual."
    echo "No se eliminaran archivos ni datos."
    echo

    if [[ -z "$pids" ]]; then
        echo -e "${YELLOW}ℹ pgAdmin ya está detenido.${RESET}"
        return 0
    fi

    echo "Procesos detectados:"
    for pid in $pids; do
        ps -p "$pid" -o pid=,user=,args= 2>/dev/null || true
    done
    echo
    if ! ask_yes_no "¿Detener estos procesos pgAdmin?"; then
        echo -e "${YELLOW}Operación cancelada.${RESET}"
        return 0
    fi

    for pid in $pids; do
        kill -TERM "$pid" 2>/dev/null || true
    done
    sleep 1
    remaining=0
    for pid in $pids; do
        kill -0 "$pid" 2>/dev/null && remaining=1
    done

    if [[ "$remaining" -eq 1 ]]; then
        echo -e "${YELLOW}⚠ Algunos procesos siguen activos.${RESET}"
        if ask_yes_no "¿Forzar su terminación con SIGKILL?"; then
            for pid in $pids; do
                kill -KILL "$pid" 2>/dev/null || true
            done
        else
            echo -e "${YELLOW}Se conservan los procesos restantes.${RESET}"
            return 1
        fi
    fi

    rm -f "$PGADMIN_PID_FILE" 2>/dev/null || true
    echo -e "${GREEN}✓ pgAdmin detenido. La instalación se conserva.${RESET}"
}

stop_postgres()
{
    echo -e "${BLUE}${BOLD}⏹ DETENER POSTGRESQL${RESET}"
    echo "Se detendrá $CONTAINER_NAME."
    echo "El contenedor, el volumen y todos los datos se conservarán."
    echo

    if ! command -v docker >/dev/null 2>&1 || ! docker ps --format '{{.Names}}' 2>/dev/null | grep -qx "$CONTAINER_NAME"; then
        echo -e "${YELLOW}ℹ PostgreSQL ya está detenido o no se detecta.${RESET}"
        return 0
    fi

    echo "Comando que se ejecutaría: docker stop $CONTAINER_NAME"
    if ask_yes_no "¿Detener PostgreSQL?"; then
        if docker stop "$CONTAINER_NAME"; then
            echo -e "${GREEN}✓ PostgreSQL detenido; los datos se conservan.${RESET}"
        else
            echo -e "${RED}✗ No se pudo detener PostgreSQL.${RESET}"
            return 1
        fi
    else
        echo -e "${YELLOW}Operación cancelada.${RESET}"
    fi
}

remove_psql()
{
    local path_entry=0
    echo -e "${RED}${BOLD}🗑 ELIMINAR INSTALACIÓN GESTIONADA DE psql${RESET}"
    echo "Solo se considerarán archivos creados por este proyecto:"
    echo "  Binario : $PSQL_BIN"
    echo "  Archivo temporal: $PSQL_ARCHIVE"
    echo "  Temporal extraído: $PSQL_EXTRACTED"
    echo

    if [[ -f "$ZSHRC" ]] && grep -qF 'export PATH="$HOME/goinfre/bin:$PATH"' "$ZSHRC"; then
        path_entry=1
        echo "  PATH detectado en: $ZSHRC"
    fi

    if [[ ! -e "$PSQL_BIN" && ! -e "$PSQL_ARCHIVE" && ! -e "$PSQL_EXTRACTED" && "$path_entry" -eq 0 ]]; then
        echo -e "${YELLOW}ℹ No se detectó la instalación gestionada de psql.${RESET}"
        return 0
    fi

    if command -v psql >/dev/null 2>&1 && [[ "$(command -v psql)" != "$PSQL_BIN" ]]; then
        echo -e "${YELLOW}⚠ psql también existe en otra ubicación: $(command -v psql)${RESET}"
        echo "No se tocará esa instalación externa."
    fi
    echo
    if ! confirm_destructive "Se eliminarán el psql gestionado, sus temporales y la entrada PATH gestionada."; then
        echo -e "${YELLOW}Operación cancelada.${RESET}"
        return 0
    fi

    rm -f "$PSQL_BIN" "$PSQL_ARCHIVE" "$PSQL_EXTRACTED"
    if [[ "$path_entry" -eq 1 ]]; then
        sed -i '\|^export PATH="\$HOME/goinfre/bin:\$PATH"$|d' "$ZSHRC"
    fi
    echo -e "${GREEN}✓ Instalación gestionada de psql eliminada.${RESET}"
    echo -e "${YELLOW}ℹ Las sesiones de terminal ya abiertas pueden conservar su PATH hasta reiniciarse.${RESET}"
}

remove_pgadmin()
{
    local pids
    echo -e "${RED}${BOLD}🗑 ELIMINAR INSTALACIÓN LOCAL DE pgAdmin${RESET}"
    echo "Ruta detectada: $PGADMIN_DIR"
    echo
    pids="$(pgrep -u "$(id -u)" -f "$PGADMIN_EXEC" 2>/dev/null || true)"
    if [[ -n "$pids" ]]; then
        echo -e "${RED}⚠ pgAdmin sigue ejecutándose.${RESET}"
        echo "Deténlo primero para evitar borrar una instalación en uso."
        return 1
    fi
    if [[ ! -e "$PGADMIN_DIR" ]]; then
        echo -e "${YELLOW}ℹ No se detectó la instalación de pgAdmin.${RESET}"
        return 0
    fi

    echo -e "${RED}Se eliminarán el entorno virtual, configuración, logs, sesiones y la base SQLite local de pgAdmin.${RESET}"
    echo -e "${RED}Esto no elimina PostgreSQL ni el volumen postgres_data.${RESET}"
    echo
    if ! confirm_destructive "Se eliminará completamente $PGADMIN_DIR."; then
        echo -e "${YELLOW}Operación cancelada.${RESET}"
        return 0
    fi

    rm -rf -- "$PGADMIN_DIR"
    echo -e "${GREEN}✓ Instalación local de pgAdmin eliminada.${RESET}"
}

main_menu()
{
    local option
    while true; do
        echo -e "${MAGENTA}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
        echo -e "${MAGENTA}${BOLD}🧭 MENÚ DE APAGADO Y LIMPIEZA${RESET}"
        echo -e "${MAGENTA}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
        echo
        echo "  1) Mostrar estado (solo lectura)"
        echo "  2) Detener pgAdmin (conserva instalación y datos)"
        echo "  3) Detener PostgreSQL (conserva volumen y datos)"
        echo "  4) Detener pgAdmin y PostgreSQL"
        echo "  5) Eliminar instalación gestionada de psql"
        echo "  6) Eliminar instalación local de pgAdmin"
        echo "  7) Detener servicios y eliminar ambas instalaciones"
        echo "  0) Salir sin cambios"
        echo
        read -r -p "$(echo -e "${YELLOW}Elige una opción (0-7) → ${RESET}")" option
        echo

        case "$option" in
            1) show_status ;;
            2) stop_pgadmin ;;
            3) stop_postgres ;;
            4) stop_pgadmin; echo; stop_postgres ;;
            5) remove_psql ;;
            6) remove_pgadmin ;;
            7)
                stop_pgadmin
                echo
                stop_postgres
                echo
                remove_psql
                echo
                remove_pgadmin
                ;;
            0) echo -e "${GREEN}Hasta luego. No se ha realizado ninguna acción adicional.${RESET}"; return 0 ;;
            *) echo -e "${RED}Opción no válida.${RESET}" ;;
        esac
        echo
        read -r -p "Pulsa ENTER para volver al menú..." _
        echo
    done
}

print_header
show_status
main_menu
