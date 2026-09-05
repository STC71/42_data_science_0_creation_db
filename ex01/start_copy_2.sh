#!/usr/bin/env bash

# ============================================================
# PISCINE PEDAGO - DATA SCIENCE
# Data Science 0 - Creation DB - EX01
# PostgreSQL + pgAdmin
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

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
EX00_DIR="$SCRIPT_DIR/../ex00"
EX00_START="$EX00_DIR/start.sh"
ENV_FILE="$EX00_DIR/.env"
CONTAINER_NAME="postgres_piscineds"

# Configuración centralizada de pgAdmin. Se usa $HOME para que el script
# sea portable entre usuarios y no dependa de rutas personales.
PGADMIN_DIR="$HOME/sgoinfre/pgadmin4"
PGADMIN_VENV="$PGADMIN_DIR/venv"
PGADMIN_EXEC="$PGADMIN_VENV/bin/pgadmin4"
PGADMIN_CONFIG_DIR="$PGADMIN_DIR/config"
PGADMIN_CONFIG_FILE="$PGADMIN_CONFIG_DIR/config_local.py"
PGADMIN_URL="http://127.0.0.1:5050"

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
    echo -e "${CYAN}${BOLD}║                  PostgreSQL + pgAdmin                      ║${RESET}"
    echo -e "${CYAN}${BOLD}║                                                            ║${RESET}"
    echo -e "${CYAN}${BOLD}║                                                            ║${RESET}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════╝${RESET}"
    echo
}

run_ex00()
{
    echo
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BLUE}${BOLD}▶ EX00 - Preparación de PostgreSQL${RESET}"
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo

    if [[ ! -f "$EX00_START" ]]; then
        echo -e "${RED}✗ No se encontró EX00/start.sh${RESET}"
        echo "  $EX00_START"
        return 1
    fi

    if [[ ! -x "$EX00_START" ]]; then
        echo -e "${YELLOW}⚠ EX00/start.sh no es ejecutable.${RESET}"
        echo -e "${CYAN}→ Añadiendo permiso de ejecución...${RESET}"

        if ! chmod +x "$EX00_START"; then
            echo -e "${RED}✗ No se pudo hacer ejecutable EX00/start.sh.${RESET}"
            return 1
        fi
    fi

    echo -e "${GREEN}✓ EX00/start.sh encontrado.${RESET}"
    echo
    echo -e "${CYAN}→ Ejecutando EX00 desde su propio directorio...${RESET}"
    echo

    (
        cd "$EX00_DIR" || exit 1
        "$EX00_START"
    )

    local exit_code=$?

    echo
    if [[ $exit_code -eq 0 ]]; then
        echo -e "${GREEN}✓ EX00 ha finalizado correctamente.${RESET}"
    else
        echo -e "${RED}✗ EX00 ha terminado con código $exit_code.${RESET}"
    fi

    echo
    return $exit_code
}

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

check_docker()
{
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BLUE}${BOLD}🐳 1. Comprobación de Docker${RESET}"
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo

    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}✗ Docker no está instalado o no está en PATH.${RESET}"
        return 1
    fi

    echo -e "${GREEN}✓ Comando docker disponible.${RESET}"

    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}✗ Docker no está funcionando.${RESET}"
        echo -e "${YELLOW}  Inicia Docker y vuelve a intentarlo.${RESET}"
        return 1
    fi

    echo -e "${GREEN}✓ Docker está operativo.${RESET}"
    echo
    return 0
}

check_env()
{
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BLUE}${BOLD}🔐 2. Comprobación del entorno PostgreSQL${RESET}"
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo

    echo -e "${CYAN}→ Buscando:${RESET}"
    echo "  $ENV_FILE"
    echo

    if ! read_env; then
        echo -e "${RED}✗ Falta .env o contiene variables incompletas.${RESET}"
        echo -e "${YELLOW}  Ejecuta primero EX00 y permite crear el .env.${RESET}"
        return 1
    fi

    echo -e "${GREEN}✓ .env encontrado y contiene las variables necesarias.${RESET}"
    echo
    echo "  POSTGRES_USER = $POSTGRES_USER"
    echo "  POSTGRES_DB   = $POSTGRES_DB"
    echo "  PASSWORD      = [oculta]"
    echo

    return 0
}

check_container()
{
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BLUE}${BOLD}🐘 3. Comprobación del contenedor PostgreSQL${RESET}"
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo

    if docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
        echo -e "${GREEN}✓ El contenedor $CONTAINER_NAME está CORRIENDO.${RESET}"
        echo
        docker ps \
            --filter "name=^/${CONTAINER_NAME}$" \
            --format "  Nombre: {{.Names}}\n  Imagen: {{.Image}}\n  Estado: {{.Status}}\n  Puertos: {{.Ports}}"
        echo
        return 0
    fi

    if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
        echo -e "${YELLOW}⚠ El contenedor existe pero está DETENIDO.${RESET}"
    else
        echo -e "${RED}✗ El contenedor $CONTAINER_NAME no existe.${RESET}"
    fi

    echo
    return 1
}

check_postgres()
{
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BLUE}${BOLD}🔌 4. Comprobación REAL de PostgreSQL${RESET}"
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo

    if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
        echo -e "${RED}✗ No se puede comprobar PostgreSQL: el contenedor no está corriendo.${RESET}"
        return 1
    fi

    echo -e "${CYAN}→ Preguntando al propio PostgreSQL si acepta conexiones...${RESET}"
    echo

    if docker exec "$CONTAINER_NAME" \
        pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ PostgreSQL responde correctamente.${RESET}"
        echo -e "${GREEN}✓ Base de datos: $POSTGRES_DB${RESET}"
        echo -e "${GREEN}✓ Usuario: $POSTGRES_USER${RESET}"
        return 0
    fi

    echo -e "${RED}✗ PostgreSQL no está respondiendo correctamente.${RESET}"
    return 1
}

check_postgres_config()
{
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BLUE}${BOLD}📡 5. Comprobación del puerto PostgreSQL${RESET}"
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo

    if docker port "$CONTAINER_NAME" 5432/tcp 2>/dev/null | grep -q ':5432'; then
        echo -e "${GREEN}✓ PostgreSQL está publicado en el puerto 5432 del host.${RESET}"
        echo
        return 0
    fi

    echo -e "${RED}✗ No se detecta el puerto host 5432 publicado.${RESET}"
    echo
    return 1
}

check_pgadmin()
{
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BLUE}${BOLD}🖥️  6. Comprobación de pgAdmin${RESET}"
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo

    local pgadmin_dir="$PGADMIN_DIR"
    local pgadmin_venv="$PGADMIN_VENV"
    local pgadmin_config="$PGADMIN_CONFIG_FILE"
    local pgadmin_url="$PGADMIN_URL"
    local result=0

    echo -e "${CYAN}Vamos a comprobar la instalación local de pgAdmin.${RESET}"
    echo -e "Se verificará:"
    echo -e "  • Directorio de instalación"
    echo -e "  • Entorno virtual (venv)"
    echo -e "  • Configuración local"
    echo -e "  • Proceso pgAdmin"
    echo -e "  • Respuesta HTTP en el puerto 5050"
    echo

    echo -e "${CYAN}→ Comando que se utilizará:${RESET}"
    echo "  ls -ld \"$pgadmin_dir\" \"$pgadmin_venv\" \"$pgadmin_config\""
    echo

    if [[ -d "$pgadmin_dir" ]]; then
        echo -e "${GREEN}✓ Directorio de pgAdmin encontrado.${RESET}"
        echo "  $pgadmin_dir"
    else
        echo -e "${RED}✗ No se encontró la instalación de pgAdmin.${RESET}"
        echo "  $pgadmin_dir"
        result=1
    fi

    if [[ -d "$pgadmin_venv" ]]; then
        echo -e "${GREEN}✓ Entorno virtual de pgAdmin encontrado.${RESET}"
    else
        echo -e "${RED}✗ No se encontró el entorno virtual de pgAdmin.${RESET}"
        result=1
    fi

    if [[ -f "$pgadmin_config" ]]; then
        echo -e "${GREEN}✓ Configuración local encontrada.${RESET}"
        echo "  $pgadmin_config"
    else
        echo -e "${RED}✗ No se encontró config_local.py.${RESET}"
        result=1
    fi

    if [[ $result -ne 0 ]]; then
        echo
        echo -e "${YELLOW}⚠ La instalación de pgAdmin está incompleta.${RESET}"
        return 1
    fi

    echo
    echo -e "${CYAN}→ Comando que se utilizará para comprobar el proceso:${RESET}"
    echo "  ps aux | grep '[p]gadmin4'"
    echo

    if ps aux | grep '[p]gadmin4' >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Se ha detectado un proceso de pgAdmin.${RESET}"
    else
        echo -e "${YELLOW}ℹ pgAdmin no está ejecutándose actualmente.${RESET}"
    fi

    echo
    echo -e "${CYAN}→ Comando que se utilizará para comprobar el puerto 5050:${RESET}"
    echo "  curl -s -o /dev/null -w '%{http_code}\\n' $pgadmin_url"
    echo

    if ! command -v curl >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠ curl no está disponible en el sistema.${RESET}"
        echo -e "  No podemos realizar la comprobación HTTP."
        return 1
    fi

    local http_code
    http_code="$(curl -s -o /dev/null -w '%{http_code}' "$pgadmin_url")"

    if [[ "$http_code" == "200" || "$http_code" == "302" ]]; then
        echo -e "${GREEN}✓ pgAdmin responde correctamente.${RESET}"
        echo "  URL: $pgadmin_url"
        echo "  Código HTTP: $http_code"
        return 0
    fi

    echo -e "${YELLOW}ℹ pgAdmin no está respondiendo actualmente en el puerto 5050.${RESET}"
    echo "  URL: $pgadmin_url"
    echo "  Código HTTP: $http_code"

    return 1
}
start_pgadmin()
{
    local pgadmin_dir="$PGADMIN_DIR"
    local pgadmin_venv="$PGADMIN_VENV"
    local pgadmin_exec="$PGADMIN_EXEC"
    local pgadmin_config="$PGADMIN_CONFIG_DIR"
    local pgadmin_url="$PGADMIN_URL"
    local http_code=""
    local i=0

    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BLUE}${BOLD}🚀 Arrancar pgAdmin${RESET}"
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo

    if ! command -v curl >/dev/null 2>&1; then
        echo -e "${RED}✗ curl no está disponible; no podemos verificar pgAdmin.${RESET}"
        return 1
    fi

    http_code="$(curl -s -o /dev/null -w "%{http_code}" "$pgadmin_url" 2>/dev/null)"

    if [[ "$http_code" == "200" || "$http_code" == "302" ]]; then
        echo -e "${GREEN}✓ pgAdmin ya está respondiendo correctamente.${RESET}"
        echo "  URL: $pgadmin_url"
        echo "  Código HTTP: $http_code"
        echo
        return 0
    fi

    if ps aux | grep "[p]gadmin4" >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠ Existe un proceso pgAdmin, pero no responde por HTTP.${RESET}"
        echo "  No se lanzará una segunda instancia."
        echo -e "${CYAN}  Ejecuta la opción 3 para diagnosticar el estado.${RESET}"
        echo
        return 1
    fi

    if [[ ! -x "$pgadmin_exec" ]]; then
        echo -e "${RED}✗ No se encontró el ejecutable de pgAdmin.${RESET}"
        echo "  $pgadmin_exec"
        return 1
    fi

    if [[ ! -d "$pgadmin_config" ]]; then
        echo -e "${RED}✗ No se encontró la configuración de pgAdmin.${RESET}"
        echo "  $pgadmin_config"
        return 1
    fi

    echo -e "${CYAN}Vamos a arrancar pgAdmin en segundo plano.${RESET}"
    echo -e "${CYAN}¿Por qué?${RESET} Para poder seguir utilizando esta terminal mientras pgAdmin permanece activo."
    echo
    echo -e "${CYAN}→ Comando que se ejecutará:${RESET}"
    printf '  PYTHONPATH="%s:$PYTHONPATH" "%s" >/dev/null 2>&1 &\n' "$pgadmin_config" "$pgadmin_exec"
    echo

    read -r -p "¿Quieres arrancar pgAdmin? [S/n]: " answer
    echo

    if [[ -n "$answer" && ! "$answer" =~ ^[SsYy]$ ]]; then
        echo -e "${YELLOW}ℹ Arranque cancelado.${RESET}"
        return 0
    fi

    echo -e "${CYAN}→ Arrancando pgAdmin...${RESET}"

    PYTHONPATH="$pgadmin_config:$PYTHONPATH" "$pgadmin_exec" >/dev/null 2>&1 &

    while [[ $i -lt 20 ]]; do
        sleep 1
        http_code="$(curl -s -o /dev/null -w "%{http_code}" "$pgadmin_url" 2>/dev/null)"

        if [[ "$http_code" == "200" || "$http_code" == "302" ]]; then
            echo -e "${GREEN}✓ pgAdmin se ha iniciado correctamente.${RESET}"
            echo -e "${GREEN}✓ Puerto 5050 respondiendo.${RESET}"
            echo "  URL: $pgadmin_url"
            echo "  Código HTTP: $http_code"
            return 0
        fi

        i=$((i + 1))
    done

    echo -e "${RED}✗ pgAdmin no ha respondido después de 20 segundos.${RESET}"
    echo -e "${YELLOW}Puedes ejecutar la opción 3 para comprobar su estado.${RESET}"
    return 1
}
stop_pgadmin()
{
    local pgadmin_pid=""

    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BLUE}${BOLD}⏹ Detener pgAdmin${RESET}"
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo
    echo -e "${CYAN}¿Qué va a ocurrir?${RESET}"
    echo "  Se detendrá únicamente el proceso de pgAdmin de este usuario."
    echo
    echo -e "${CYAN}¿Qué NO ocurrirá?${RESET}"
    echo "  No se eliminará la instalación ni su configuración."
    echo "  No se tocará PostgreSQL."
    echo
    echo -e "${CYAN}→ Comando que se ejecutará:${RESET}"
    echo "  kill <PID de pgAdmin>"
    echo

    pgadmin_pid="$(pgrep -u "$(id -u)" -f "$PGADMIN_EXEC" 2>/dev/null | head -n 1)"

    if [[ -z "$pgadmin_pid" ]]; then
        echo -e "${YELLOW}ℹ pgAdmin ya está detenido (no se encontró su proceso).${RESET}"
        return 0
    fi

    echo "  PID detectado: $pgadmin_pid"
    echo
    read -r -p "¿Quieres detener pgAdmin? [S/n]: " answer
    echo

    if [[ -n "$answer" && ! "$answer" =~ ^[SsYy]$ ]]; then
        echo -e "${YELLOW}ℹ Operación cancelada.${RESET}"
        return 0
    fi

    if kill "$pgadmin_pid" 2>/dev/null; then
        sleep 1
    else
        echo -e "${RED}✗ No se pudo enviar la señal de parada a pgAdmin.${RESET}"
        return 1
    fi

    if kill -0 "$pgadmin_pid" 2>/dev/null; then
        echo -e "${YELLOW}⚠ El proceso sigue activo; se enviará SIGTERM de nuevo.${RESET}"
        kill -TERM "$pgadmin_pid" 2>/dev/null
        sleep 1
    fi

    if kill -0 "$pgadmin_pid" 2>/dev/null; then
        echo -e "${RED}✗ El proceso de pgAdmin no se ha detenido.${RESET}"
        return 1
    fi

    echo -e "${GREEN}✓ pgAdmin se ha detenido correctamente.${RESET}"
    return 0
}

stop_postgres()
{
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BLUE}${BOLD}⏹ Detener PostgreSQL${RESET}"
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo
    echo -e "${CYAN}¿Qué va a ocurrir?${RESET}"
    echo "  Se detendrá el contenedor $CONTAINER_NAME."
    echo
    echo -e "${CYAN}¿Qué NO ocurrirá?${RESET}"
    echo "  No se eliminará el contenedor."
    echo "  No se eliminará el volumen postgres_data."
    echo "  No se eliminarán bases de datos, tablas ni datos."
    echo
    echo -e "${CYAN}→ Comando que se ejecutará:${RESET}"
    echo "  docker stop $CONTAINER_NAME"
    echo

    if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
        echo -e "${YELLOW}ℹ PostgreSQL ya está detenido o el contenedor no existe.${RESET}"
        return 0
    fi

    read -r -p "¿Quieres detener PostgreSQL? [S/n]: " answer
    echo

    if [[ -n "$answer" && ! "$answer" =~ ^[SsYy]$ ]]; then
        echo -e "${YELLOW}ℹ Operación cancelada.${RESET}"
        return 0
    fi

    if docker stop "$CONTAINER_NAME"; then
        echo -e "${GREEN}✓ PostgreSQL se ha detenido correctamente.${RESET}"
        echo -e "${GREEN}✓ Los datos se conservan intactos.${RESET}"
        return 0
    fi

    echo -e "${RED}✗ No se pudo detener PostgreSQL.${RESET}"
    return 1
}

stop_services()
{
    local option=""

    while true; do
        echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
        echo -e "${BLUE}${BOLD}⏹ Detener servicios${RESET}"
        echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
        echo
        echo -e "${CYAN}Estas operaciones son NO DESTRUCTIVAS.${RESET}"
        echo "No se eliminarán datos de PostgreSQL ni la instalación de pgAdmin."
        echo
        echo -e "  ${GREEN}[1]${RESET} Detener PostgreSQL"
        echo "      Conserva contenedor, volumen y datos."
        echo
        echo -e "  ${GREEN}[2]${RESET} Detener pgAdmin"
        echo "      Conserva instalación y configuración."
        echo
        echo -e "  ${GREEN}[3]${RESET} Detener PostgreSQL + pgAdmin"
        echo "      Primero pgAdmin y después PostgreSQL."
        echo
        echo -e "  ${RED}[0]${RESET} Cancelar"
        echo

        read -r -p "Selecciona una opción [1/2/3/0]: " option
        echo

        case "$option" in
            1)
                stop_postgres
                ;;
            2)
                stop_pgadmin
                ;;
            3)
                stop_pgadmin
                echo
                stop_postgres
                ;;
            0)
                echo -e "${YELLOW}ℹ Operación cancelada.${RESET}"
                return 0
                ;;
            *)
                echo -e "${RED}✗ Opción no válida.${RESET}"
                ;;
        esac

        echo
        read -r -p "Pulsa ENTER para volver al menú de servicios..."
        echo
    done
}

check_postgres_environment()
{
    local result=0

    check_docker || result=1
    echo

    check_env || result=1
    echo

    if [[ $result -eq 0 ]]; then
        check_container || result=1
        echo

        if docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
            check_postgres || result=1
            echo
            check_postgres_config || result=1
        fi
    fi

    echo
    echo -e "${MAGENTA}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    if [[ $result -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}✓ ENTORNO POSTGRESQL OPERATIVO${RESET}"
    else
        echo -e "${YELLOW}${BOLD}⚠ ENTORNO POSTGRESQL INCOMPLETO${RESET}"
    fi

    echo -e "${MAGENTA}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo

    return $result
}

show_menu()
{
    echo -e "${WHITE}${BOLD}¿Qué quieres hacer?${RESET}"
    echo
    echo -e "  ${GREEN}[1]${RESET} ▶ Ejecutar ${BOLD}START.SH de EX00${RESET}"
    echo -e "      Preparar el entorno PostgreSQL."
    echo
    echo -e "  ${GREEN}[2]${RESET} ▶ Comprobar ${BOLD}PostgreSQL${RESET}"
    echo -e "      Verificar Docker, .env, contenedor, PostgreSQL y puerto 5432."
    echo
    echo -e "  ${GREEN}[3]${RESET} ▶ Comprobar ${BOLD}pgAdmin${RESET}"
    echo -e "      Verificar instalación, configuración, proceso y puerto 5050."
    echo
    echo -e "  ${GREEN}[4]${RESET} ▶ Arrancar ${BOLD}pgAdmin${RESET}"
    echo -e "      Iniciar pgAdmin en segundo plano y comprobar el puerto 5050."
    echo
    echo -e "  ${RED}[q]${RESET} ✖ Salir"
    echo
}

main()
{
    print_header

    echo -e "${CYAN}Script:${RESET}"
    echo "  $SCRIPT_DIR/start.sh"
    echo

    while true; do
        show_menu

        read -r -p "Selecciona una opción [1/2/3/4/5/q]: " OPTION
        echo

        case "$OPTION" in
            1)
                run_ex00
                echo
                read -r -p "Pulsa ENTER para volver al menú de EX01..."
                print_header
                ;;

            2)
                check_postgres_environment
                echo
                read -r -p "Pulsa ENTER para volver al menú de EX01..."
                print_header
                ;;

            3)
                check_pgadmin
                echo
                read -r -p "Pulsa ENTER para volver al menú de EX01..."
                print_header
                ;;

            4)
                start_pgadmin
                echo
                read -r -p "Pulsa ENTER para volver al menú de EX01..."
                print_header
                ;;

            5)
                stop_services
                print_header
                ;;

            q|Q)
                echo -e "${CYAN}👋  ¡Hasta pronto!${RESET}"
                exit 0
                ;;

            *)
                echo -e "${RED}✗ Opción no válida.${RESET}"
                echo
                ;;
        esac
    done
}

main
