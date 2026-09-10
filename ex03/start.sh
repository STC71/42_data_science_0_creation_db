#!/usr/bin/env bash

# ============================================================
# PISCINE PEDAGO - DATA SCIENCE
# Data Science 0 - Creation DB - EX03
# Automatic table (customer/*.csv → PostgreSQL)
#
# Cadena de arranque:
#   EX03/start.sh  →  puede llamar a EX01/start.sh
#   EX01/start.sh  →  puede llamar a EX00/start.sh
#
# Se puede ejecutar desde cualquier directorio:
#   /ruta/a/ex03/start.sh
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
# Rutas (portables: no dependen del cwd desde el que llames)
# ------------------------------------------------------------
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
EX00_DIR="$PROJECT_DIR/ex00"
EX01_DIR="$PROJECT_DIR/ex01"
EX01_START="$EX01_DIR/start.sh"
ENV_FILE="$EX00_DIR/.env"
CONTAINER_NAME="postgres_piscineds"
AUTO_TABLE_PY="$SCRIPT_DIR/automatic_table.py"

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
    echo -e "${CYAN}${BOLD}║                          EX03                              ║${RESET}"
    echo -e "${CYAN}${BOLD}║                                                            ║${RESET}"
    echo -e "${CYAN}${BOLD}║              Automatic table (customer → DB)               ║${RESET}"
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
# Lectura de .env (EX00)
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
# EX01 → EX00
# ------------------------------------------------------------
run_ex01()
{
    section "▶  EX01 — Preparación de PostgreSQL + pgAdmin"

    echo -e "EX03 necesita la base ${BOLD}piscineds${RESET} en marcha."
    echo -e "EX01 prepara PostgreSQL (llamando a EX00) y, si quieres, pgAdmin."
    echo
    echo -e "${CYAN}→ Por qué:${RESET} sin EX00/EX01 no hay contenedor, .env ni base lista para el COPY."
    echo -e "${CYAN}→ Comando:${RESET}"
    echo "  cd \"$EX01_DIR\" && ./start.sh"
    echo
    echo -e "${YELLOW}Nota:${RESET} EX01 es interactivo. Al salir, vuelves a este menú de EX03."
    echo

    if [[ ! -f "$EX01_START" ]]; then
        echo -e "${RED}✗ No se encontró EX01/start.sh${RESET}"
        echo "  $EX01_START"
        return 1
    fi

    if [[ ! -x "$EX01_START" ]]; then
        echo -e "${YELLOW}⚠ No es ejecutable. Intentando chmod +x...${RESET}"
        chmod +x "$EX01_START" || {
            echo -e "${RED}✗ No se pudo hacer ejecutable${RESET}"
            return 1
        }
    fi

    if ! ask_yes_no "¿Ejecutar EX01/start.sh ahora?" "s"; then
        echo -e "${YELLOW}⏭️  Se omite la llamada a EX01${RESET}"
        return 0
    fi

    echo
    echo -e "${CYAN}→ Entrando en EX01...${RESET}"
    echo
    (
        cd "$EX01_DIR" || exit 1
        "$EX01_START"
    )
    local exit_code=$?
    echo
    if [[ $exit_code -eq 0 ]]; then
        echo -e "${GREEN}✓ EX01 finalizó (código 0)${RESET}"
    else
        echo -e "${YELLOW}⚠ EX01 terminó con código $exit_code${RESET}"
        echo -e "  Puedes seguir si PostgreSQL ya es usable."
    fi
    echo
    return 0
}

# ------------------------------------------------------------
# Arrancar contenedor si está detenido (sin abrir EX01)
# ------------------------------------------------------------
try_start_container()
{
    if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
        if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
            echo -e "${YELLOW}El contenedor existe pero está detenido.${RESET}"
            echo -e "${CYAN}→ Comando:${RESET} docker start $CONTAINER_NAME"
            echo -e "${CYAN}→ Por qué:${RESET} evita entrar en EX01 solo para levantar Postgres."
            echo
            if ask_yes_no "¿Arrancar el contenedor ahora?" "s"; then
                echo
                echo -e "${BLUE}→ Ejecutando: docker start $CONTAINER_NAME${RESET}"
                if docker start "$CONTAINER_NAME"; then
                    echo -e "${GREEN}✓ Contenedor arrancado${RESET}"
                    sleep 2
                    return 0
                fi
                echo -e "${RED}✗ No se pudo arrancar${RESET}"
                return 1
            fi
        fi
    fi
    return 1
}

# ------------------------------------------------------------
# Comprobaciones (con comando + por qué)
# ------------------------------------------------------------
check_docker()
{
    section "🐳  PASO 1: Docker"

    echo -e "${CYAN}→ Por qué:${RESET} sin Docker no hay contenedor PostgreSQL ni puerto 5432."
    echo -e "${CYAN}→ Comandos:${RESET}"
    echo "  command -v docker"
    echo "  docker info"
    echo

    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}✗ Docker no está en el PATH${RESET}"
        return 1
    fi
    echo -e "${GREEN}✓ Comando docker disponible${RESET}"

    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}✗ Docker no responde (demonio caído o sin permisos)${RESET}"
        return 1
    fi
    echo -e "${GREEN}✓ Docker operativo${RESET}"
    echo
    return 0
}

check_env()
{
    section "🔐  PASO 2: Archivo .env (EX00)"

    echo -e "${CYAN}→ Por qué:${RESET} usuario, contraseña y nombre de BD no deben ir hardcodeados en el Python."
    echo -e "${CYAN}→ Ruta:${RESET} $ENV_FILE"
    echo -e "${CYAN}→ Comando conceptual:${RESET} leer POSTGRES_USER / PASSWORD / DB del .env"
    echo

    if ! read_env; then
        echo -e "${RED}✗ Falta .env o está incompleto${RESET}"
        echo -e "${YELLOW}  Solución: EX00 o EX01 → crear .env${RESET}"
        return 1
    fi

    echo -e "${GREEN}✓ .env encontrado${RESET}"
    echo "  POSTGRES_USER = $POSTGRES_USER"
    echo "  POSTGRES_DB   = $POSTGRES_DB"
    echo "  PASSWORD      = [oculta]"
    echo
    return 0
}

check_container()
{
    section "🐘  PASO 3: Contenedor PostgreSQL"

    echo -e "${CYAN}→ Por qué:${RESET} el servidor vive en el contenedor $CONTAINER_NAME."
    echo -e "${CYAN}→ Comando:${RESET}"
    echo "  docker ps --filter name=^/${CONTAINER_NAME}\$"
    echo

    if docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
        echo -e "${GREEN}✓ Contenedor $CONTAINER_NAME está CORRIENDO${RESET}"
        docker ps \
            --filter "name=^/${CONTAINER_NAME}$" \
            --format "  Nombre: {{.Names}}\n  Imagen: {{.Image}}\n  Estado: {{.Status}}\n  Puertos: {{.Ports}}"
        echo
        return 0
    fi

    if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
        echo -e "${YELLOW}⚠ Existe pero está DETENIDO${RESET}"
        try_start_container && return 0
        echo -e "  Alternativa: opción 2 del menú (EX01 → EX00) o: docker start $CONTAINER_NAME"
    else
        echo -e "${RED}✗ No existe el contenedor $CONTAINER_NAME${RESET}"
        echo -e "  Ejecuta EX00 o la opción 2 (EX01)."
    fi
    echo
    return 1
}

check_postgres_ready()
{
    section "🔌  PASO 4: PostgreSQL acepta conexiones"

    echo -e "${CYAN}→ Por qué:${RESET} el contenedor Up no basta; el motor debe aceptar clientes."
    echo -e "${CYAN}→ Comando:${RESET}"
    echo "  docker exec $CONTAINER_NAME pg_isready -U \"\$POSTGRES_USER\" -d \"\$POSTGRES_DB\""
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
        echo -e "  Base: $POSTGRES_DB  ·  Usuario: $POSTGRES_USER"
        echo
        return 0
    fi

    echo -e "${RED}✗ PostgreSQL no responde todavía${RESET}"
    echo -e "  Espera unos segundos o: docker logs $CONTAINER_NAME"
    echo
    return 1
}

find_customer_folder()
{
    local candidates=(
        "$PROJECT_DIR/subject/customer"
        "$PROJECT_DIR/customer"
        "$SCRIPT_DIR/customer"
    )
    local c
    for c in "${candidates[@]}"; do
        if [[ -d "$c" ]]; then
            echo "$c"
            return 0
        fi
    done
    return 1
}

check_auto_table_script()
{
    section "📜  PASO 5: Script automatic_table.py"

    echo -e "${CYAN}→ Por qué:${RESET} el subject exige automatic_table.* en ex03/."
    echo -e "${CYAN}→ Ruta:${RESET} $AUTO_TABLE_PY"
    echo -e "${CYAN}→ Comando:${RESET} test -f \"$AUTO_TABLE_PY\" && command -v python3"
    echo

    if [[ ! -f "$AUTO_TABLE_PY" ]]; then
        echo -e "${RED}✗ No se encontró automatic_table.py${RESET}"
        return 1
    fi
    echo -e "${GREEN}✓ automatic_table.py encontrado${RESET}"

    if command -v python3 >/dev/null 2>&1; then
        echo -e "${GREEN}✓ python3: $(command -v python3)${RESET}"
    else
        echo -e "${RED}✗ python3 no está en el PATH${RESET}"
        return 1
    fi
    echo
    return 0
}

check_customer()
{
    section "📁  PASO 6: Carpeta customer/"

    echo -e "${CYAN}→ Por qué:${RESET} EX03 debe descubrir CSV solos (sin hardcodear nombres)."
    echo -e "${CYAN}→ Candidatos:${RESET} subject/customer, customer/, ex03/customer/"
    echo -e "${CYAN}→ Comando conceptual:${RESET} find ... -name '*.csv'"
    echo

    CUSTOMER_DIR="$(find_customer_folder || true)"
    if [[ -z "$CUSTOMER_DIR" ]]; then
        echo -e "${RED}✗ No se encontró customer/${RESET}"
        echo -e "  A mano: python3 automatic_table.py /ruta/a/customer"
        return 1
    fi

    local count
    count="$(find "$CUSTOMER_DIR" -maxdepth 1 -type f -name '*.csv' 2>/dev/null | wc -l | tr -d ' ')"
    echo -e "${GREEN}✓ Carpeta: $CUSTOMER_DIR${RESET}"
    echo -e "${GREEN}✓ Archivos .csv: $count${RESET}"
    if [[ "$count" -eq 0 ]]; then
        echo -e "${YELLOW}⚠ Carpeta sin CSV${RESET}"
        return 1
    fi
    echo
    return 0
}

run_all_checks()
{
    check_docker
    check_env
    check_container
    check_postgres_ready
    check_auto_table_script
    check_customer
}

# ------------------------------------------------------------
# Carga y verificación
# ------------------------------------------------------------
run_automatic_table()
{
    section "🤖  Ejecutar automatic_table.py"

    echo -e "Crea/recrea una tabla por cada CSV e importa los datos (${BOLD}COPY${RESET})."
    echo -e "${YELLOW}Puede tardar varios minutos${RESET} (CSV grandes)."
    echo
    echo -e "${CYAN}→ Por qué:${RESET} automatizar EX03 sin escribir nombres de fichero a mano."
    echo -e "${CYAN}→ Comando:${RESET}"
    echo "  cd \"$SCRIPT_DIR\""
    if [[ -n "${CUSTOMER_DIR:-}" ]]; then
        echo "  python3 automatic_table.py \"$CUSTOMER_DIR\""
    else
        echo "  python3 automatic_table.py"
    fi
    echo

    if ! ask_yes_no "¿Ejecutar automatic_table.py ahora?" "s"; then
        echo -e "${YELLOW}⏭️  Ejecución omitida${RESET}"
        return 0
    fi

    echo
    (
        cd "$SCRIPT_DIR" || exit 1
        if [[ -n "${CUSTOMER_DIR:-}" ]]; then
            python3 "$AUTO_TABLE_PY" "$CUSTOMER_DIR"
        else
            python3 "$AUTO_TABLE_PY"
        fi
    )
    local exit_code=$?
    echo
    if [[ $exit_code -eq 0 ]]; then
        echo -e "${GREEN}✓ automatic_table.py terminó con éxito${RESET}"
    else
        echo -e "${RED}✗ Terminó con código $exit_code${RESET}"
    fi
    echo
    return $exit_code
}

list_tables()
{
    section "📋  Tablas en piscineds (\\dt)"

    echo -e "${CYAN}→ Por qué:${RESET} ver si existen data_2022_oct, data_2022_nov, etc."
    echo -e "${CYAN}→ Comando:${RESET}"
    echo "  docker exec -i $CONTAINER_NAME psql -U \"\$USER\" -d \"\$DB\" -c '\\dt'"
    echo

    if ! read_env; then
        echo -e "${RED}✗ No se pudo leer .env${RESET}"
        return 1
    fi
    if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
        echo -e "${RED}✗ Contenedor no está corriendo${RESET}"
        return 1
    fi

    docker exec -i "$CONTAINER_NAME" \
        psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\dt'
    echo
}

count_customer_tables()
{
    section "🔢  COUNT(*) de tablas data_*"

    echo -e "${CYAN}→ Por qué:${RESET} confirmar que el COPY cargó filas (COUNT > 0)."
    echo -e "${CYAN}→ Comando:${RESET} consulta SQL sobre tablas public.data_%"
    echo

    if ! read_env; then
        echo -e "${RED}✗ No se pudo leer .env${RESET}"
        return 1
    fi
    if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
        echo -e "${RED}✗ Contenedor no está corriendo${RESET}"
        return 1
    fi

    docker exec -i "$CONTAINER_NAME" \
        psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" <<'SQL'
SELECT c.relname AS table_name,
       (xpath('/row/c/text()', query_to_xml(format('SELECT COUNT(*) AS c FROM %I', c.relname), false, true, '')))[1]::text::bigint AS row_count
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
  AND c.relkind = 'r'
  AND c.relname LIKE 'data_%'
ORDER BY 1;
SQL
    echo
}

connect_psql()
{
    section "💻  Abrir psql"

    echo -e "${CYAN}→ Por qué:${RESET} inspeccionar datos a mano (\\d, SELECT, etc.)."
    echo -e "${CYAN}→ Comando:${RESET}"
    echo "  docker exec -it $CONTAINER_NAME psql -U \"\$POSTGRES_USER\" -d \"\$POSTGRES_DB\""
    echo -e "${YELLOW}  Salir de psql: \\q${RESET}"
    echo

    if ! read_env; then
        echo -e "${RED}✗ No se pudo leer .env${RESET}"
        return 1
    fi
    if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
        echo -e "${RED}✗ Contenedor no está corriendo${RESET}"
        return 1
    fi

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
    echo -e "${CYAN}${BOLD}  MENÚ EX03 – Automatic table${RESET}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo
    echo -e "  ${BOLD}${WHITE}— Preparación —${RESET}"
    echo -e "  ${BOLD}1)${RESET}  Comprobar entorno (Docker / .env / contenedor / PostgreSQL / CSV)"
    echo -e "  ${BOLD}2)${RESET}  Ejecutar EX01/start.sh ${WHITE}(→ EX00)${RESET}"
    echo
    echo -e "  ${BOLD}${WHITE}— Carga de datos —${RESET}"
    echo -e "  ${BOLD}3)${RESET}  Localizar customer/ y contar CSV"
    echo -e "  ${BOLD}4)${RESET}  Ejecutar automatic_table.py"
    echo
    echo -e "  ${BOLD}${WHITE}— Comprobación —${RESET}"
    echo -e "  ${BOLD}5)${RESET}  Listar tablas (\\dt)"
    echo -e "  ${BOLD}6)${RESET}  COUNT(*) de tablas data_*"
    echo -e "  ${BOLD}7)${RESET}  Abrir psql en el contenedor"
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
            1)
                run_all_checks
                pause
                ;;
            2)
                run_ex01
                pause
                ;;
            3)
                check_customer
                pause
                ;;
            4)
                CUSTOMER_DIR="$(find_customer_folder || true)"
                if [[ -z "$CUSTOMER_DIR" ]]; then
                    echo -e "${YELLOW}No se auto-detectó customer/. Indica la ruta:${RESET}"
                    read -r -p "$(echo -e "${YELLOW}Ruta a customer/ (vacío = cancelar) → ${RESET}")" CUSTOMER_DIR
                    if [[ -z "$CUSTOMER_DIR" ]]; then
                        echo -e "${YELLOW}⏭️  Cancelado${RESET}"
                        pause
                        continue
                    fi
                fi
                run_automatic_table
                pause
                ;;
            5)
                list_tables
                pause
                ;;
            6)
                count_customer_tables
                pause
                ;;
            7)
                connect_psql
                pause
                ;;
            q|Q)
                echo -e "${GREEN}Hasta luego. EX03 listo cuando las tablas estén cargadas.${RESET}"
                echo
                exit 0
                ;;
            *)
                echo -e "${YELLOW}Opción no válida (usa 1-7 o q)${RESET}"
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
    echo -e "  • Puede comprobar Docker, .env (EX00) y el contenedor PostgreSQL"
    echo -e "  • Puede lanzar ${BOLD}EX01/start.sh${RESET} (que a su vez puede lanzar EX00)"
    echo -e "  • Localiza ${BOLD}customer/${RESET} y ejecuta ${BOLD}automatic_table.py${RESET}"
    echo -e "  • Te deja comprobar tablas y abrir psql"
    echo
    echo -e "${CYAN}No borra datos${RESET} (un reset total solo si lo haces tú en EX00 con down -v)."
    echo

    echo -e "${BOLD}Comprobaciones iniciales${RESET}"
    echo -e "  Revisan Docker, .env, contenedor, PostgreSQL, el script Python y customer/."
    echo -e "  ${YELLOW}No ejecutan${RESET} automatic_table.py (eso es la opción 4 del menú)."
    echo

    if ask_yes_no "¿Ejecutar comprobaciones iniciales ahora?" "s"; then
        echo
        run_all_checks

        # Si el entorno base falla, ofrecer EX01 una sola vez
        if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME" \
            || ! read_env; then
            echo -e "${YELLOW}⚠ El entorno de PostgreSQL no está completo.${RESET}"
            if ask_yes_no "¿Abrir EX01/start.sh (→ EX00) para prepararlo?" "s"; then
                run_ex01
                echo
                echo -e "${CYAN}→ Re-ejecutando comprobaciones básicas...${RESET}"
                check_docker
                check_env
                check_container
                check_postgres_ready || true
            fi
        fi

        echo
        echo -e "${GREEN}${BOLD}✔ Comprobaciones iniciales terminadas.${RESET}"
    else
        echo -e "${YELLOW}⏭️  Preflight omitido. Puedes usar la opción 1 del menú cuando quieras.${RESET}"
    fi

    echo
    echo -e "  Usa el menú para cargar CSV o verificar resultados."
    echo

    menu_loop
}

main "$@"
