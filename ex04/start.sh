#!/usr/bin/env bash

# ============================================================
# PISCINE PEDAGO - DATA SCIENCE
# Data Science 0 - Creation DB - EX04
# Items table (item.csv → PostgreSQL tabla «items»)
#
# Cadena de arranque:
#   EX04/start.sh  →  puede llamar a EX03/start.sh
#   EX03/start.sh  →  puede llamar a EX01/start.sh
#   EX01/start.sh  →  puede llamar a EX00/start.sh
#
# Se puede ejecutar desde cualquier directorio:
#   /ruta/a/ex04/start.sh
#   ./start.sh
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

# ------------------------------------------------------------
# Rutas portables
# ------------------------------------------------------------
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
EX00_DIR="$PROJECT_DIR/ex00"
EX01_DIR="$PROJECT_DIR/ex01"
EX03_DIR="$PROJECT_DIR/ex03"
EX01_START="$EX01_DIR/start.sh"
EX03_START="$EX03_DIR/start.sh"
ENV_FILE="$EX00_DIR/.env"
CONTAINER_NAME="postgres_piscineds"
ITEMS_SQL="$SCRIPT_DIR/items_table.sql"
ITEMS_PY="$SCRIPT_DIR/items_table.py"

# ------------------------------------------------------------
# Utilidades
# ------------------------------------------------------------
print_header()
{
    clear
    echo
    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║                                                            ║${RESET}"
    echo -e "${CYAN}${BOLD}║    PISCINE PEDAGO - DATA SCIENCE - sternero - 42 Málaga    ║${RESET}"
    echo -e "${CYAN}${BOLD}║                                                            ║${RESET}"
    echo -e "${CYAN}${BOLD}║               Data Science 0 - Creation DB                 ║${RESET}"
    echo -e "${CYAN}${BOLD}║                          EX04                              ║${RESET}"
    echo -e "${CYAN}${BOLD}║                                                            ║${RESET}"
    echo -e "${CYAN}${BOLD}║              Items table (item.csv → items)                ║${RESET}"
    echo -e "${CYAN}${BOLD}║                                                            ║${RESET}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════╝${RESET}"
    echo
    echo -e "${WHITE}  Script:   ${SCRIPT_DIR}/start.sh${RESET}"
    echo -e "${WHITE}  Proyecto: ${PROJECT_DIR}${RESET}"
    echo
}

ask_yes_no()
{
    local prompt="$1"
    local default="$2"
    local answer

    if [ "$default" = "s" ]; then
        read -r -p "$(echo -e "${YELLOW}${prompt} [S/n] → ${RESET}")" answer
        answer=${answer:-s}
    else
        read -r -p "$(echo -e "${YELLOW}${prompt} [s/N] → ${RESET}")" answer
        answer=${answer:-n}
    fi

    [[ "$answer" =~ ^[sS]$ ]]
}

pause()
{
    echo
    read -r -p "$(echo -e "${CYAN}Pulsa Enter para continuar...${RESET}")"
}

section()
{
    echo
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BOLD}$1${RESET}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo
}

# ------------------------------------------------------------
# .env de EX00
# ------------------------------------------------------------
read_env()
{
    POSTGRES_USER=""
    POSTGRES_PASSWORD=""
    POSTGRES_DB=""

    if [[ ! -f "$ENV_FILE" ]]; then
        return 1
    fi

    POSTGRES_USER="$(sed -n 's/^POSTGRES_USER=//p' "$ENV_FILE" | head -n 1)"
    POSTGRES_PASSWORD="$(sed -n 's/^POSTGRES_PASSWORD=//p' "$ENV_FILE" | head -n 1)"
    POSTGRES_DB="$(sed -n 's/^POSTGRES_DB=//p' "$ENV_FILE" | head -n 1)"

    [[ -n "$POSTGRES_USER" && -n "$POSTGRES_PASSWORD" && -n "$POSTGRES_DB" ]]
}

# ------------------------------------------------------------
# Llamar a EX03 (→ EX01 → EX00)
# ------------------------------------------------------------
run_ex03()
{
    section "▶  EX03 — Preparación previa (customer + entorno)"

    echo -e "EX04 necesita PostgreSQL en marcha (y opcionalmente las tablas de EX03)."
    echo -e "${CYAN}→ Por qué:${RESET} EX03/start.sh puede levantar EX01 → EX00 y el contenedor."
    echo -e "${CYAN}→ Comando:${RESET}"
    echo "  cd \"$EX03_DIR\" && ./start.sh"
    echo

    if [[ ! -f "$EX03_START" ]]; then
        echo -e "${YELLOW}⚠ No hay EX03/start.sh. Intentaremos EX01 directamente.${RESET}"
        run_ex01
        return $?
    fi

    if [[ ! -x "$EX03_START" ]]; then
        chmod +x "$EX03_START" || true
    fi

    if ! ask_yes_no "¿Ejecutar EX03/start.sh ahora?" "s"; then
        echo -e "${YELLOW}⏭️  Se omite EX03${RESET}"
        return 0
    fi

    (
        cd "$EX03_DIR" || exit 1
        "$EX03_START"
    )
    echo
    return 0
}

run_ex01()
{
    section "▶  EX01 — PostgreSQL + pgAdmin"

    echo -e "${CYAN}→ Comando:${RESET} cd \"$EX01_DIR\" && ./start.sh"
    echo

    if [[ ! -f "$EX01_START" ]]; then
        echo -e "${RED}✗ No se encontró EX01/start.sh${RESET}"
        return 1
    fi

    if [[ ! -x "$EX01_START" ]]; then
        chmod +x "$EX01_START" || true
    fi

    if ! ask_yes_no "¿Ejecutar EX01/start.sh ahora?" "s"; then
        echo -e "${YELLOW}⏭️  Se omite EX01${RESET}"
        return 0
    fi

    (
        cd "$EX01_DIR" || exit 1
        "$EX01_START"
    )
    return 0
}

try_start_container()
{
    if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
        if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
            echo -e "${YELLOW}El contenedor existe pero está detenido.${RESET}"
            echo -e "${CYAN}→ Comando:${RESET} docker start $CONTAINER_NAME"
            if ask_yes_no "¿Arrancar el contenedor ahora?" "s"; then
                docker start "$CONTAINER_NAME" && sleep 2 && return 0
            fi
        fi
    fi
    return 1
}

# ------------------------------------------------------------
# Comprobaciones
# ------------------------------------------------------------
check_docker()
{
    section "🐳  PASO 1: Docker"

    echo -e "${CYAN}→ Por qué:${RESET} sin Docker no hay PostgreSQL del módulo."
    echo -e "${CYAN}→ Comandos:${RESET} command -v docker ; docker info"
    echo

    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}✗ Docker no está en el PATH${RESET}"
        return 1
    fi
    echo -e "${GREEN}✓ docker disponible${RESET}"

    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}✗ Docker no responde${RESET}"
        return 1
    fi
    echo -e "${GREEN}✓ Docker operativo${RESET}"
    echo
    return 0
}

check_env()
{
    section "🔐  PASO 2: Archivo .env (EX00)"

    echo -e "${CYAN}→ Por qué:${RESET} credenciales sin hardcodear en scripts."
    echo -e "${CYAN}→ Ruta:${RESET} $ENV_FILE"
    echo

    if ! read_env; then
        echo -e "${RED}✗ Falta .env o está incompleto${RESET}"
        return 1
    fi
    echo -e "${GREEN}✓ .env OK${RESET}"
    echo "  USER = $POSTGRES_USER — DB = $POSTGRES_DB — PASS = $POSTGRES_PASSWORD"
    echo
    return 0
}

check_container()
{
    section "🐘  PASO 3: Contenedor PostgreSQL"

    echo -e "${CYAN}→ Comando:${RESET} docker ps --filter name=$CONTAINER_NAME"
    echo

    if docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
        echo -e "${GREEN}✓ $CONTAINER_NAME está CORRIENDO${RESET}"
        docker ps --filter "name=^/${CONTAINER_NAME}$" \
            --format "  {{.Names}} | {{.Status}} | {{.Ports}}"
        echo
        return 0
    fi

    if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
        echo -e "${YELLOW}⚠ Existe pero está DETENIDO${RESET}"
        try_start_container && return 0
    else
        echo -e "${RED}✗ No existe $CONTAINER_NAME${RESET}"
    fi
    echo
    return 1
}

check_postgres_ready()
{
    section "🔌  PASO 4: PostgreSQL acepta conexiones"

    echo -e "${CYAN}→ Comando:${RESET} docker exec $CONTAINER_NAME pg_isready ..."
    echo

    if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
        echo -e "${RED}✗ Contenedor no está corriendo${RESET}"
        return 1
    fi
    if ! read_env; then
        echo -e "${RED}✗ No se pudo leer .env${RESET}"
        return 1
    fi

    if docker exec "$CONTAINER_NAME" \
        pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ PostgreSQL responde${RESET}"
        echo
        return 0
    fi
    echo -e "${RED}✗ PostgreSQL no responde${RESET}"
    echo
    return 1
}

find_item_csv()
{
    local candidates=(
        "$PROJECT_DIR/subject/item/item.csv"
        "$PROJECT_DIR/subject/items/item.csv"
        "$PROJECT_DIR/subject/items/items.csv"
        "$PROJECT_DIR/item/item.csv"
        "$PROJECT_DIR/items/item.csv"
        "$SCRIPT_DIR/item.csv"
    )
    local c
    for c in "${candidates[@]}"; do
        if [[ -f "$c" ]]; then
            echo "$c"
            return 0
        fi
    done
    return 1
}

check_item_csv()
{
    section "📁  PASO 5: CSV de productos"

    echo -e "${CYAN}→ Por qué:${RESET} EX04 carga item.csv en la tabla items."
    echo -e "${CYAN}→ Candidatos:${RESET} subject/item/item.csv, subject/items/..."
    echo

    ITEM_CSV="$(find_item_csv || true)"
    if [[ -z "$ITEM_CSV" ]]; then
        echo -e "${RED}✗ No se encontró item.csv${RESET}"
        return 1
    fi
    echo -e "${GREEN}✓ CSV: $ITEM_CSV${RESET}"
    echo
    return 0
}

check_scripts()
{
    section "📜  PASO 6: Scripts de entrega"

    echo -e "${CYAN}→ Subject:${RESET} items_table.* (sql y/o py)"
    echo

    local ok=0
    if [[ -f "$ITEMS_SQL" ]]; then
        echo -e "${GREEN}✓ items_table.sql${RESET}"
        ok=1
    else
        echo -e "${YELLOW}⚠ No hay items_table.sql${RESET}"
    fi
    if [[ -f "$ITEMS_PY" ]]; then
        echo -e "${GREEN}✓ items_table.py${RESET}"
        ok=1
    else
        echo -e "${YELLOW}⚠ No hay items_table.py${RESET}"
    fi
    echo
    [[ $ok -eq 1 ]]
}

run_all_checks()
{
    check_docker
    check_env
    check_container
    check_postgres_ready
    check_item_csv
    check_scripts
}

# ------------------------------------------------------------
# Carga: SQL + COPY  o  Python
# ------------------------------------------------------------
run_sql_path()
{
    section "📦  Cargar con SQL + COPY"

    echo -e "${CYAN}→ Por qué:${RESET} entrega clásica del subject (DDL visible en .sql)."
    echo -e "Pasos: docker cp CSV y SQL → psql -f → COPY FROM /tmp/item.csv"
    echo

    if ! read_env; then
        echo -e "${RED}✗ .env incompleto${RESET}"
        return 1
    fi
    if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
        echo -e "${RED}✗ Contenedor no está corriendo${RESET}"
        return 1
    fi

    ITEM_CSV="$(find_item_csv || true)"
    if [[ -z "$ITEM_CSV" || ! -f "$ITEMS_SQL" ]]; then
        echo -e "${RED}✗ Falta item.csv o items_table.sql${RESET}"
        return 1
    fi

    echo -e "${CYAN}→ Comandos:${RESET}"
    echo "  docker cp \"$ITEM_CSV\" $CONTAINER_NAME:/tmp/item.csv"
    echo "  docker cp \"$ITEMS_SQL\" $CONTAINER_NAME:/tmp/items_table.sql"
    echo "  docker exec ... psql -f /tmp/items_table.sql"
    echo "  docker exec ... -c \"COPY items FROM '/tmp/item.csv' WITH (FORMAT csv, HEADER true);\""
    echo

    if ! ask_yes_no "¿Ejecutar carga SQL ahora?" "s"; then
        echo -e "${YELLOW}⏭️  Omitido${RESET}"
        return 0
    fi

    echo
    docker cp "$ITEM_CSV" "$CONTAINER_NAME:/tmp/item.csv" || true
    docker cp "$ITEMS_SQL" "$CONTAINER_NAME:/tmp/items_table.sql" || true

    echo -e "${BLUE}→ CREATE TABLE...${RESET}"
    docker exec -i "$CONTAINER_NAME" \
        psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /tmp/items_table.sql

    echo -e "${BLUE}→ COPY...${RESET}"
    docker exec -i "$CONTAINER_NAME" \
        psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c \
        "COPY items FROM '/tmp/item.csv' WITH (FORMAT csv, HEADER true);"

    echo
    echo -e "${GREEN}✓ Ruta SQL finalizada (revisa mensajes COPY arriba)${RESET}"
    echo
}

run_python_path()
{
    section "🐍  Cargar con items_table.py"

    echo -e "${CYAN}→ Por qué:${RESET} mismo patrón que EX03 (un solo comando crea + carga)."
    echo -e "${CYAN}→ Comando:${RESET} python3 \"$ITEMS_PY\""
    echo

    if [[ ! -f "$ITEMS_PY" ]]; then
        echo -e "${RED}✗ No existe items_table.py${RESET}"
        return 1
    fi

    if ! ask_yes_no "¿Ejecutar items_table.py ahora?" "s"; then
        echo -e "${YELLOW}⏭️  Omitido${RESET}"
        return 0
    fi

    echo
    (
        cd "$SCRIPT_DIR" || exit 1
        ITEM_CSV="$(find_item_csv || true)"
        if [[ -n "$ITEM_CSV" ]]; then
            python3 "$ITEMS_PY" "$ITEM_CSV"
        else
            python3 "$ITEMS_PY"
        fi
    )
    echo
}

show_items_schema()
{
    section "📋  \\d items"

    if ! read_env || ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
        echo -e "${RED}✗ Entorno no listo${RESET}"
        return 1
    fi
    docker exec -i "$CONTAINER_NAME" \
        psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\d items'
    echo
}

count_items()
{
    section "🔢  COUNT(*) FROM items"

    if ! read_env || ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
        echo -e "${RED}✗ Entorno no listo${RESET}"
        return 1
    fi
    docker exec -i "$CONTAINER_NAME" \
        psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c 'SELECT COUNT(*) FROM items;'
    echo
}

sample_items()
{
    section "👀  SELECT * FROM items LIMIT 5"

    if ! read_env || ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
        echo -e "${RED}✗ Entorno no listo${RESET}"
        return 1
    fi
    docker exec -i "$CONTAINER_NAME" \
        psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c 'SELECT * FROM items LIMIT 5;'
    echo
}

connect_psql()
{
    section "💻  Abrir psql"

    if ! read_env || ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
        echo -e "${RED}✗ Entorno no listo${RESET}"
        return 1
    fi
    echo -e "${YELLOW}Salir: \\q${RESET}"
    echo
    docker exec -it "$CONTAINER_NAME" \
        psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"
}

# ------------------------------------------------------------
# Menú
# ------------------------------------------------------------
show_menu()
{
    echo
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${CYAN}${BOLD}  MENÚ EX04 – Items table${RESET}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo
    echo -e "  ${BOLD}${WHITE}— Preparación —${RESET}"
    echo -e "  ${BOLD}1)${RESET}  Comprobar entorno (Docker / .env / contenedor / CSV)"
    echo -e "  ${BOLD}2)${RESET}  Ejecutar ex03/start.sh ${WHITE}(→ ex01 → ex00)${RESET}"
    echo -e "  ${BOLD}3)${RESET}  Ejecutar ex01/start.sh ${WHITE}(→ ex00)${RESET}"
    echo
    echo -e "  ${BOLD}${WHITE}— Carga de datos —${RESET}"
    echo -e "  ${BOLD}4)${RESET}  Cargar con SQL + COPY ${WHITE}(items_table.sql)${RESET}"
    echo -e "  ${BOLD}5)${RESET}  Cargar con Python ${WHITE}(items_table.py)${RESET}"
    echo
    echo -e "  ${BOLD}${WHITE}— Comprobación —${RESET}"
    echo -e "  ${BOLD}6)${RESET}  Estructura de items (\\d)"
    echo -e "  ${BOLD}7)${RESET}  COUNT(*) de items"
    echo -e "  ${BOLD}8)${RESET}  Muestra de 5 filas"
    echo -e "  ${BOLD}9)${RESET}  Abrir psql"
    echo
    echo -e "  ${RED}${BOLD}q)${RESET}  ${RED}Salir${RESET}"
    echo
}

menu_loop()
{
    local choice
    while true; do
        show_menu
        read -r -p "$(echo -e "${YELLOW}Elige una opción → ${RESET}")" choice
        echo
        case "$choice" in
            1) run_all_checks; pause ;;
            2) run_ex03; pause ;;
            3) run_ex01; pause ;;
            4) run_sql_path; pause ;;
            5) run_python_path; pause ;;
            6) show_items_schema; pause ;;
            7) count_items; pause ;;
            8) sample_items; pause ;;
            9) connect_psql; pause ;;
            q|Q)
                echo -e "${GREEN}Hasta luego. Module 0 listo cuando items esté cargada.${RESET}"
                echo
                exit 0
                ;;
            *)
                echo -e "${YELLOW}Opción no válida (1-9 o q)${RESET}"
                ;;
        esac
    done
}

# ------------------------------------------------------------
# main
# ------------------------------------------------------------
main()
{
    print_header

    echo -e "${WHITE}Este asistente:${RESET}"
    echo -e "  • Comprueba Docker, .env y el contenedor"
    echo -e "  • Puede lanzar ${BOLD}EX03${RESET} o ${BOLD}EX01${RESET} (cadena hasta EX00)"
    echo -e "  • Carga la tabla ${BOLD}items${RESET} por SQL+COPY o por Python"
    echo -e "  • Verifica estructura, COUNT y muestra de filas"
    echo
    echo -e "${CYAN}No borra datos${RESET} salvo el DROP de items al recrear la tabla."
    echo

    if ask_yes_no "¿Ejecutar comprobaciones iniciales ahora?" "s"; then
        echo
        run_all_checks
        if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME" \
            || ! read_env; then
            echo -e "${YELLOW}⚠ Entorno incompleto.${RESET}"
            if ask_yes_no "¿Abrir EX03/start.sh para prepararlo?" "s"; then
                run_ex03
            fi
        fi
        echo -e "${GREEN}${BOLD}✔ Comprobaciones iniciales terminadas.${RESET}"
    else
        echo -e "${YELLOW}⏭️  Preflight omitido (opción 1 del menú cuando quieras).${RESET}"
    fi

    echo
    menu_loop
}

main "$@"
