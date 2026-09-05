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
    echo -e "${CYAN}${BOLD}║                  sternero - 42 Málaga                      ║${RESET}"
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

    local pgadmin_dir="$HOME/sgoinfre/pgadmin4"
    local pgadmin_venv="$pgadmin_dir/venv"
    local pgadmin_config="$pgadmin_dir/config/config_local.py"
    local pgadmin_url="http://127.0.0.1:5050"
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
    local pgadmin_dir="$HOME/sgoinfre/pgadmin4"
    local pgadmin_venv="$pgadmin_dir/venv"
    local pgadmin_exec="$pgadmin_venv/bin/pgadmin4"
    local pgadmin_config="$pgadmin_dir/config"
    local pgadmin_url="http://127.0.0.1:5050"
    local http_code=""
    local i=0

    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BLUE}${BOLD}🚀 Arrancar pgAdmin${RESET}"
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo

    if ps aux | grep "[p]gadmin4" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ pgAdmin ya está ejecutándose.${RESET}"
        echo "  URL: $pgadmin_url"
        echo
        return 0
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

        read -r -p "Selecciona una opción [1/2/3/4/q]: " OPTION
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
