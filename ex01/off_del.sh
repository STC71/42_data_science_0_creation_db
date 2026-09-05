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
PSQL_BIN="${PSQL_BIN:-$HOME/goinfre/bin/psql}"
PSQL_ARCHIVE="/tmp/psql-x86-linux-static.tar.gz"
PSQL_EXTRACTED="/tmp/psql"
ZSHRC="$HOME/.zshrc"
declare -a SHELL_CONFIG_FILES=(
    "$HOME/.zshrc"
    "$HOME/.zprofile"
    "$HOME/.zshenv"
    "$HOME/.bashrc"
    "$HOME/.bash_profile"
    "$HOME/.profile"
)
declare -a PSQL_CANDIDATES=()
declare -a PGADMIN_CANDIDATES=()

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

add_candidate()
{
    local value="$1" array_name="$2" candidate
    declare -n candidates="$array_name"

    [[ -e "$value" ]] || return 0
    for candidate in "${candidates[@]}"; do
        [[ "$candidate" == "$value" ]] && return 0
    done
    candidates+=("$value")
}

discover_installations()
{
    local path candidate root
    PSQL_CANDIDATES=()
    PGADMIN_CANDIDATES=()

    add_candidate "$PSQL_BIN" PSQL_CANDIDATES
    if path="$(command -v psql 2>/dev/null)" && [[ -x "$path" && "$path" == "$HOME/"* ]]; then
        add_candidate "$(readlink -f "$path" 2>/dev/null || printf '%s' "$path")" PSQL_CANDIDATES
    fi
    while IFS= read -r path; do
        add_candidate "$path" PSQL_CANDIDATES
    done < <(find "$HOME" -type f -path '*/bin/psql' -perm -u+x -print 2>/dev/null)

    add_candidate "$PGADMIN_DIR" PGADMIN_CANDIDATES
    while IFS= read -r path; do
        root="$(dirname "$(dirname "$(dirname "$path")")")"
        add_candidate "$root" PGADMIN_CANDIDATES
    done < <(find "$HOME" -type f -path '*/venv/bin/pgadmin4' -perm -u+x -print 2>/dev/null)
}

choose_candidate()
{
    local array_name="$1" label="$2" count candidate choice index=0
    declare -n candidates="$array_name"
    count="${#candidates[@]}"

    [[ "$count" -gt 0 ]] || return 1
    echo -e "${CYAN}Instalaciones de ${label} detectadas dentro de tu usuario:${RESET}"
    for candidate in "${candidates[@]}"; do
        index=$((index + 1))
        echo "  [$index] $candidate"
    done
    echo "  [0] Cancelar"
    read -r -p "$(echo -e "${YELLOW}Elige una ruta → ${RESET}")" choice
    [[ "$choice" =~ ^[0-9]+$ && "$choice" -gt 0 && "$choice" -le "$count" ]] || return 1
    SELECTED_CANDIDATE="${candidates[$((choice - 1))]}"
}

get_pgadmin_pids()
{
    local candidate
    discover_installations
    for candidate in "${PGADMIN_CANDIDATES[@]}"; do
        pgrep -u "$(id -u)" -f "$candidate/venv/bin/pgadmin4" 2>/dev/null || true
    done | sort -nu
}

cleanup_shell_references()
{
    local installation="$1" label="$2" file temp found=0
    local -a matching_files=()

    echo -e "${BLUE}${BOLD}🔎 Referencias de ${label} en configuraciones del shell${RESET}"
    for file in "${SHELL_CONFIG_FILES[@]}"; do
        if [[ -f "$file" ]] && grep -Fq -- "$installation" "$file"; then
            matching_files+=("$file")
            found=1
            echo -e "${YELLOW}  $file${RESET}"
            grep -Fn -- "$installation" "$file"
        fi
    done

    if [[ "$label" == "psql" && "$installation" == "$PSQL_BIN" ]]; then
        for file in "${SHELL_CONFIG_FILES[@]}"; do
            if [[ -f "$file" ]] && grep -Fq 'export PATH="$HOME/goinfre/bin:$PATH"' "$file"; then
                if [[ "$found" -eq 0 || ! " ${matching_files[*]} " =~ " $file " ]]; then
                    matching_files+=("$file")
                fi
                found=1
                echo -e "${YELLOW}  $file${RESET}"
                grep -Fn 'export PATH="$HOME/goinfre/bin:$PATH"' "$file"
            fi
        done
    fi

    if [[ "$found" -eq 0 ]]; then
        echo -e "${GREEN}✓ No se encontraron referencias de ${label} en los archivos del shell.${RESET}"
        return 0
    fi

    echo
    if ! confirm_destructive "Se eliminarán de las configuraciones del shell las líneas mostradas de ${label}."; then
        echo -e "${YELLOW}Limpieza del shell cancelada; esas referencias se conservan.${RESET}"
        return 0
    fi

    for file in "${matching_files[@]}"; do
        temp="$(mktemp)" || {
            echo -e "${RED}✗ No se pudo preparar la limpieza de $file.${RESET}"
            return 1
        }
        awk -v installation="$installation" -v managed_psql="$PSQL_BIN" -v is_psql="$label" \
            'index($0, installation) == 0 && !(is_psql == "psql" && installation == managed_psql && index($0, "export PATH=\"$HOME/goinfre/bin:$PATH\"") > 0)' \
            "$file" > "$temp"
        chmod --reference="$file" "$temp" 2>/dev/null || true
        if ! mv -- "$temp" "$file"; then
            rm -f -- "$temp"
            echo -e "${RED}✗ No se pudo actualizar $file.${RESET}"
            return 1
        fi
        echo -e "${GREEN}✓ Referencias eliminadas de $file.${RESET}"
    done
}

show_status()
{
    discover_installations
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

    if [[ -n "$(get_pgadmin_pids)" ]]; then
        echo -e "${GREEN}✓ pgAdmin: proceso activo${RESET}"
    else
        echo -e "${YELLOW}ℹ pgAdmin: proceso no detectado${RESET}"
    fi

    if [[ "${#PSQL_CANDIDATES[@]}" -gt 0 ]]; then
        echo -e "${GREEN}✓ Instalaciones de psql detectadas en tu usuario:${RESET}"
        printf '    %s\n' "${PSQL_CANDIDATES[@]}"
    else
        echo -e "${YELLOW}ℹ No se detectaron instalaciones de psql dentro de tu usuario${RESET}"
    fi

    if command -v psql >/dev/null 2>&1; then
        echo -e "${CYAN}  psql actualmente visible en PATH: $(command -v psql)${RESET}"
    else
        echo -e "${YELLOW}ℹ psql no está visible en PATH${RESET}"
    fi

    if [[ "${#PGADMIN_CANDIDATES[@]}" -gt 0 ]]; then
        echo -e "${GREEN}✓ Instalaciones de pgAdmin detectadas en tu usuario:${RESET}"
        printf '    %s\n' "${PGADMIN_CANDIDATES[@]}"
    else
        echo -e "${YELLOW}ℹ Instalación pgAdmin no detectada${RESET}"
    fi
    echo
}

stop_pgadmin()
{
    local pids pid answer remaining
    pids="$(get_pgadmin_pids)"

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
    local selected
    echo -e "${RED}${BOLD}🗑 ELIMINAR UNA INSTALACIÓN DE psql${RESET}"
    discover_installations
    echo

    if [[ "${#PSQL_CANDIDATES[@]}" -eq 0 ]]; then
        echo -e "${YELLOW}ℹ No se detectó una instalación de psql dentro de tu usuario.${RESET}"
        return 0
    fi

    if ! choose_candidate PSQL_CANDIDATES "psql"; then
        echo -e "${YELLOW}Operación cancelada.${RESET}"
        return 0
    fi
    selected="$SELECTED_CANDIDATE"
    if [[ "$selected" != "$HOME/"* || ! -f "$selected" || "$(basename "$selected")" != "psql" ]]; then
        echo -e "${RED}✗ Ruta rechazada por seguridad: solo se pueden eliminar binarios psql dentro de HOME.${RESET}"
        return 1
    fi
    echo
    echo -e "${YELLOW}Solo se eliminará esta ruta dentro de tu usuario:${RESET}"
    echo "  $selected"
    echo
    if ! confirm_destructive "Se eliminará únicamente la instalación seleccionada de psql."; then
        echo -e "${YELLOW}Operación cancelada.${RESET}"
        return 0
    fi

    rm -f -- "$selected"
    if [[ "$selected" == "$PSQL_BIN" ]]; then
        rm -f -- "$PSQL_ARCHIVE" "$PSQL_EXTRACTED"
        echo -e "${GREEN}✓ Temporales conocidos de la instalación también eliminados.${RESET}"
    fi
    echo -e "${GREEN}✓ Instalación gestionada de psql eliminada.${RESET}"
    cleanup_shell_references "$selected" "psql"
    echo -e "${YELLOW}ℹ Las sesiones de terminal ya abiertas pueden conservar su PATH hasta reiniciarse.${RESET}"
}

remove_pgadmin()
{
    local pids selected
    echo -e "${RED}${BOLD}🗑 ELIMINAR UNA INSTALACIÓN LOCAL DE pgAdmin${RESET}"
    discover_installations
    echo
    if [[ "${#PGADMIN_CANDIDATES[@]}" -eq 0 ]]; then
        echo -e "${YELLOW}ℹ No se detectó una instalación de pgAdmin dentro de tu usuario.${RESET}"
        return 0
    fi
    if ! choose_candidate PGADMIN_CANDIDATES "pgAdmin"; then
        echo -e "${YELLOW}Operación cancelada.${RESET}"
        return 0
    fi
    selected="$SELECTED_CANDIDATE"
    if [[ "$selected" == "$HOME" || "$selected" == "/" || "$selected" != "$HOME/"* || ! -x "$selected/venv/bin/pgadmin4" ]]; then
        echo -e "${RED}✗ Ruta rechazada por seguridad: no coincide con una instalación pgAdmin válida dentro de HOME.${RESET}"
        return 1
    fi
    pids="$(pgrep -u "$(id -u)" -f "$selected/venv/bin/pgadmin4" 2>/dev/null || true)"
    if [[ -n "$pids" ]]; then
        echo -e "${RED}⚠ pgAdmin sigue ejecutándose.${RESET}"
        echo "Detén esta instalación primero para evitar borrar una instalación en uso."
        return 1
    fi

    echo -e "${RED}Se eliminarán el entorno virtual, configuración, logs, sesiones y la base SQLite local de pgAdmin.${RESET}"
    echo "Ruta seleccionada: $selected"
    echo -e "${RED}Esto no elimina PostgreSQL ni el volumen postgres_data.${RESET}"
    echo
    if ! confirm_destructive "Se eliminará completamente $selected."; then
        echo -e "${YELLOW}Operación cancelada.${RESET}"
        return 0
    fi

    rm -rf -- "$selected"
    echo -e "${GREEN}✓ Instalación local de pgAdmin eliminada.${RESET}"
    cleanup_shell_references "$selected" "pgAdmin"
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
