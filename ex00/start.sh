#!/bin/bash

# ============================================================
#  PISCINE PEDAGO - DATA SCIENCE
#  Data Science 0 - Creation DB - ex00
#  sternero - 42 Málaga
# ============================================================

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

clear

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                                                          ║"
echo "║          PISCINE PEDAGO - DATA SCIENCE                   ║"
echo "║                                                          ║"
echo "║        Data Science 0 - Creation DB - ex00               ║"
echo "║                                                          ║"
echo "║              sternero - 42 Málaga                        ║"
echo "║                                                          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# ------------------------------------------------------------
# Función auxiliar para preguntar s/n
# ------------------------------------------------------------
ask_yes_no() {
    local prompt="$1"
    local default="$2"
    local answer

    if [ "$default" = "s" ]; then
        read -p "$(echo -e "${YELLOW}${prompt} [S/n] → ${NC}")" answer
        answer=${answer:-s}
    else
        read -p "$(echo -e "${YELLOW}${prompt} [s/N] → ${NC}")" answer
        answer=${answer:-n}
    fi

    [[ "$answer" =~ ^[sS]$ ]]
}

env_is_valid() {
    [ -f .env ] \
        && grep -qxF "POSTGRES_USER=$(id -un)" .env \
        && grep -qxF 'POSTGRES_PASSWORD=mysecretpassword' .env \
        && grep -qxF 'POSTGRES_DB=piscineds' .env
}

# ------------------------------------------------------------
# GESTIÓN INICIAL DEL CONTENEDOR
# ------------------------------------------------------------
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}🔄  GESTIÓN INICIAL DEL CONTENEDOR (opcional)${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "Puedes apagar el contenedor conservando los datos, o hacer una"
echo -e "limpieza completa si el entorno está en un estado inconsistente."
echo ""
echo -e "  ${BOLD}1) Apagar el contenedor${NC}"
echo -e "     Detiene el contenedor, pero conserva el contenedor, la red,"
echo -e "     el volumen ${BOLD}postgres_data${NC} y todos los datos de la base de datos."
echo ""
echo -e "  ${BOLD}2) Limpieza completa${NC}"
echo -e "     Detiene y elimina el contenedor, la red y el volumen."
echo -e "     ${RED}⚠️  Borra permanentemente todas las bases de datos y tablas. 💥${NC}"
echo ""
echo "  0) No hacer nada y continuar"
echo ""

read -p "$(echo -e "${YELLOW}Elige una opción (0-2) → ${NC}")" INITIAL_ACTION

case "$INITIAL_ACTION" in
    1)
        echo ""
        echo -e "${YELLOW}⚠️  Vas a apagar el contenedor activo.${NC}"
        echo -e "El contenedor dejará de ejecutarse, pero ${BOLD}tus datos se conservarán${NC}"
        echo -e "en el volumen postgres_data y podrás recuperarlos al volver a arrancar."
        echo ""
        if ask_yes_no "¿Confirmas apagar el contenedor?" "n"; then
            echo -e "\n${BLUE}→ Ejecutando: docker-compose stop${NC}"
            echo ""
            docker-compose stop
            echo ""
            echo -e "${GREEN}✅  Contenedor apagado; contenedor y datos conservados${NC}"
        else
            echo -e "${YELLOW}⏭️  Operación cancelada. Continuamos...${NC}"
        fi
        ;;
    2)
        echo ""
        echo -e "${RED}⚠️  PELIGRO: Vas a hacer una limpieza completa.${NC}"
        echo -e "Se eliminarán el contenedor, la red y el volumen postgres_data."
        echo -e "${BOLD}${RED}Todas las bases de datos, tablas y datos se perderán y no se podrán recuperar.${NC}"
        echo ""
        read -p "$(echo -e "${YELLOW}Escribe 'si' para confirmar la limpieza completa → ${NC}")" CLEAN_CONFIRM
        if [[ "$CLEAN_CONFIRM" == "si" ]]; then
            echo -e "\n${BLUE}→ Ejecutando: docker-compose down -v${NC}"
            echo ""
            docker-compose down -v
            echo ""
            echo -e "${GREEN}✅  Contenedor y datos eliminados${NC}"
        else
            echo -e "${YELLOW}⏭️  Limpieza cancelada. Continuamos...${NC}"
        fi
        ;;
    0|"")
        echo -e "${YELLOW}⏭️  No se realiza ninguna acción. Continuamos...${NC}"
        ;;
    *)
        echo -e "${YELLOW}⚠️  Opción no válida. No se realiza ninguna acción. Continuamos...${NC}"
        ;;
esac

echo ""
sleep 1

# ------------------------------------------------------------
# PASO 1: Crear .env
# ------------------------------------------------------------
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}📝  PASO 1: Crear el archivo .env${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "Vamos a crear un archivo llamado ${BOLD}.env${NC} que contendrá:"
echo -e "  • POSTGRES_USER      → tu login del sistema"
echo -e "  • POSTGRES_PASSWORD  → mysecretpassword"
echo -e "  • POSTGRES_DB        → piscineds"
echo ""
echo -e "Esto evita hardcodear las credenciales en el docker-compose.yml"
echo -e "y sigue las buenas prácticas del proyecto Inception."
echo ""
echo -e "Comando que se ejecutará:"
echo -e "  ${BOLD}echo \"POSTGRES_USER=\$(id -un) ...\" > .env${NC}"
echo ""

if env_is_valid; then
    echo -e "${GREEN}✅  Ya existe un .env válido para este ejercicio.${NC}"
    echo -e "${CYAN}   Se conservará para evitar sobrescribir tus credenciales.${NC}"
    echo ""
    if ask_yes_no "¿Quieres regenerar el .env de todos modos?" "n"; then
        CREATE_ENV=1
    else
        CREATE_ENV=0
        echo -e "${YELLOW}⏭️  Se conserva el .env existente${NC}"
    fi
elif [ -f .env ]; then
    echo -e "${RED}⚠️  Existe un .env, pero no contiene la configuración esperada.${NC}"
    echo -e "   Regenerarlo sobrescribirá su contenido actual."
    echo ""
    if ask_yes_no "¿Sobrescribir el .env con la configuración de este ejercicio?" "n"; then
        CREATE_ENV=1
    else
        CREATE_ENV=0
        echo -e "${YELLOW}⏭️  Se conserva el .env no validado${NC}"
    fi
else
    if ask_yes_no "¿Crear el archivo .env ahora?" "s"; then
        CREATE_ENV=1
    else
        CREATE_ENV=0
    fi
fi

if [ "$CREATE_ENV" -eq 1 ]; then
    echo -e "\n${BLUE}→ Creando archivo .env...${NC}"
    echo "POSTGRES_USER=$(id -un)
POSTGRES_PASSWORD=mysecretpassword
POSTGRES_DB=piscineds" > .env

    if [ -f .env ]; then
        echo -e "${GREEN}✅  Archivo .env creado correctamente${NC}"
        echo -e "\nContenido del archivo:"
        echo -e "${CYAN}"
        cat .env | sed 's/^/    /'
        echo -e "${NC}"
    else
        echo -e "${RED}❌  Error al crear el archivo .env${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⏭️  Se omite la creación del .env${NC}"
fi

echo ""
sleep 1

# ------------------------------------------------------------
# PASO 1B: Proteger .env con .gitignore
# ------------------------------------------------------------
if [ -f .env ]; then
    if [ -f .gitignore ] && grep -qxF '.env' .gitignore; then
        echo -e "${GREEN}✅  .env ya está protegido por .gitignore; se omite el paso 1B.${NC}"
    elif [ -e .gitignore ] && [ ! -f .gitignore ]; then
        echo -e "${RED}❌  .gitignore existe, pero no es un archivo regular; no se puede modificar.${NC}"
    else
        echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BOLD}🔒  PASO 1B: Proteger las credenciales con .gitignore${NC}"
        echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "El archivo ${BOLD}.env${NC} contiene credenciales y no debe subirse a GitHub."
        if [ -e .gitignore ]; then
            echo -e "Se añadirá la entrada ${BOLD}.env${NC} al .gitignore existente."
        else
            echo -e "Se creará ${BOLD}.gitignore${NC} con la entrada ${BOLD}.env${NC}."
        fi
        echo ""
        echo -e "${RED}⚠️  Sin esta protección podrías publicar accidentalmente tu contraseña.${NC}"
        echo ""

        if ask_yes_no "¿Proteger .env en .gitignore ahora?" "s"; then
            if [ ! -e .gitignore ]; then
                printf '%s\n' ".env" > .gitignore
                echo -e "${GREEN}✅  .gitignore creado con la entrada .env${NC}"
            else
                printf '\n%s\n' ".env" >> .gitignore
                echo -e "${GREEN}✅  Entrada .env añadida a .gitignore${NC}"
            fi
        else
            echo -e "${RED}⚠️  No se ha modificado .gitignore: .env podría subirse a GitHub.${NC}"
        fi
    fi
else
    echo -e "${YELLOW}⏭️  No existe .env; se omite el paso 1B.${NC}"
fi

echo ""
sleep 1

# ------------------------------------------------------------
# PASO 2: Instalar psql en el host (opcional)
# ------------------------------------------------------------
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}💻  PASO 2: Instalar el cliente psql en el host (sin sudo)${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "En la mayoría de los ordenadores del campus no está instalado el"
echo -e "cliente ${BOLD}psql${NC}. Vamos a instalar un binario estático en tu"
echo -e "carpeta personal ${BOLD}~/goinfre/bin${NC} para poder usarlo desde fuera"
echo -e "del contenedor (comando oficial del subject)."
echo ""
echo -e "Pasos que se ejecutarán:"
echo -e "  1. Crear la carpeta ~/goinfre/bin"
echo -e "  2. Descargar el binario estático de psql"
echo -e "  3. Extraerlo y copiarlo a ~/goinfre/bin"
echo -e "  4. Añadirlo al PATH de forma permanente"
echo ""

if command -v psql &> /dev/null; then
    echo -e "${GREEN}✅  El cliente psql ya está instalado; se omite el PASO 2.${NC}"
    echo -e "   Versión detectada: $(psql --version)"
elif ask_yes_no "¿Instalar el cliente psql en el host ahora?" "s"; then
    echo -e "\n${BLUE}→ Instalando psql...${NC}"
    echo ""

    CURRENT_DIR=$(pwd)
    mkdir -p ~/goinfre/bin
    cd /tmp

    if [ ! -f psql-x86-linux-static.tar.gz ]; then
        echo -e "${BLUE}  Descargando binario...${NC}"
        wget -q --show-progress https://github.com/IxDay/psql/releases/download/15.10.0/psql-x86-linux-static.tar.gz
    else
        echo -e "${YELLOW}  El archivo ya existe, se omite la descarga${NC}"
    fi

    echo -e "${BLUE}  Extrayendo...${NC}"
    tar -xzf psql-x86-linux-static.tar.gz

    echo -e "${BLUE}  Copiando a ~/goinfre/bin...${NC}"
    cp psql ~/goinfre/bin/

    if ! grep -q 'goinfre/bin' ~/.zshrc 2>/dev/null; then
        echo 'export PATH="$HOME/goinfre/bin:$PATH"' >> ~/.zshrc
        echo -e "${BLUE}  PATH actualizado en ~/.zshrc${NC}"
    fi

    # Aplicar el PATH en la sesión actual
    export PATH="$HOME/goinfre/bin:$PATH"

    cd "$CURRENT_DIR"

    echo ""
    if command -v psql &> /dev/null; then
        echo -e "${GREEN}✅  Cliente psql instalado correctamente${NC}"
        echo -e "  Versión detectada: $(psql --version)"
    else
        echo -e "${YELLOW}⚠️  psql se ha copiado, pero puede que necesites abrir una nueva terminal${NC}"
        echo -e "  para que el PATH se aplique completamente."
    fi
else
    echo -e "${YELLOW}⏭️  Se omite la instalación de psql en el host${NC}"
fi

echo ""
sleep 1

# ------------------------------------------------------------
# PASO 3: Arrancar el contenedor
# ------------------------------------------------------------
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}🚀  PASO 3: Arrancar PostgreSQL con Docker Compose${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "Vamos a levantar el servicio de PostgreSQL usando el archivo"
echo -e "${BOLD}docker-compose.yml${NC}."
echo ""
echo -e "Se creará (si no existe):"
echo -e "  • Una red de Docker"
echo -e "  • Un volumen para persistir los datos"
echo -e "  • El contenedor llamado ${BOLD}postgres_piscineds${NC}"
echo ""
echo -e "Comando que se ejecutará:"
echo -e "  ${BOLD}docker-compose up -d${NC}"
echo ""

CONTAINER_RUNNING=0

if docker ps --format '{{.Names}}' | grep -qx 'postgres_piscineds'; then
    echo -e "${GREEN}✅  PostgreSQL ya está arrancado en el contenedor postgres_piscineds.${NC}"
    echo -e "${CYAN}   Se omite docker-compose up -d.${NC}"
    CONTAINER_RUNNING=1
elif docker inspect postgres_piscineds &> /dev/null; then
    echo -e "${YELLOW}⚠️  El contenedor postgres_piscineds existe, pero está detenido.${NC}"
    echo -e "   Se puede iniciar de nuevo conservando sus datos y configuración."
    echo ""
    if ask_yes_no "¿Iniciar el contenedor ahora?" "s"; then
        echo -e "\n${BLUE}→ Ejecutando: docker-compose up -d${NC}"
        echo ""
        docker-compose up -d
        DOCKER_COMPOSE_STATUS=$?
        echo ""

        if [ "$DOCKER_COMPOSE_STATUS" -eq 0 ]; then
            echo -e "${GREEN}✅  Contenedor arrancado correctamente${NC}"
            CONTAINER_RUNNING=1
        else
            echo -e "${RED}❌  Error al arrancar el contenedor${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}⏭️  Se omite el arranque del contenedor${NC}"
    fi
else
    echo -e "${YELLOW}ℹ️  No existe todavía el contenedor postgres_piscineds.${NC}"
    echo -e "   docker-compose up -d lo creará junto con la red y el volumen si son necesarios."
    echo ""
    if ask_yes_no "¿Crear y arrancar el contenedor ahora?" "s"; then
        echo -e "\n${BLUE}→ Ejecutando: docker-compose up -d${NC}"
        echo ""
        docker-compose up -d
        DOCKER_COMPOSE_STATUS=$?
        echo ""

        if [ "$DOCKER_COMPOSE_STATUS" -eq 0 ]; then
            echo -e "${GREEN}✅  Contenedor creado y arrancado correctamente${NC}"
            CONTAINER_RUNNING=1
        else
            echo -e "${RED}❌  Error al crear o arrancar el contenedor${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}⏭️  Se omite el arranque del contenedor${NC}"
    fi
fi

echo ""
sleep 2

# ------------------------------------------------------------
# PASO 4: Verificar el contenedor
# ------------------------------------------------------------
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}🔍  PASO 4: Verificar que el contenedor está corriendo${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "Vamos a comprobar si el contenedor ${BOLD}postgres_piscineds${NC}"
echo -e "está activo y escuchando en el puerto 5432."
echo ""
echo -e "Comando que se ejecutará:"
echo -e "  ${BOLD}docker ps --filter \"name=postgres_piscineds\"${NC}"
echo ""

if [ "$CONTAINER_RUNNING" -eq 1 ]; then
    echo -e "${GREEN}✅  El estado ya se ha verificado en el paso 3; no se repite la comprobación.${NC}"
elif ask_yes_no "¿Verificar el estado del contenedor ahora?" "s"; then
    echo -e "\n${BLUE}→ Ejecutando: docker ps --filter \"name=postgres_piscineds\"${NC}"
    echo ""
    docker ps --filter "name=postgres_piscineds" --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"
    echo ""

    if docker ps --format '{{.Names}}' | grep -q "postgres_piscineds"; then
        echo -e "${GREEN}✅  El contenedor postgres_piscineds está corriendo correctamente${NC}"
    else
        echo -e "${RED}❌  El contenedor no está corriendo${NC}"
        CONTAINER_RUNNING=0
    fi
else
    echo -e "${YELLOW}⏭️  Se omite la verificación${NC}"
fi

echo ""
sleep 1

# ------------------------------------------------------------
# RESUMEN REAL DEL ESTADO
# ------------------------------------------------------------
ENV_EXISTS=0
GITIGNORE_PROTECTED=0
PSQL_AVAILABLE=0

if [ -f .env ]; then
    ENV_EXISTS=1
    if [ -f .gitignore ] && grep -qxF '.env' .gitignore; then
        GITIGNORE_PROTECTED=1
    fi
fi

if command -v psql &> /dev/null; then
    PSQL_AVAILABLE=1
fi

if docker ps --format '{{.Names}}' | grep -qx 'postgres_piscineds'; then
    CONTAINER_RUNNING=1
fi

# ------------------------------------------------------------
# RESUMEN FINAL
# ------------------------------------------------------------
if [ "$ENV_EXISTS" -eq 1 ] && [ "$GITIGNORE_PROTECTED" -eq 1 ] && [ "$CONTAINER_RUNNING" -eq 1 ]; then
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                               ║"
    echo "║               ✅  TODO LISTO Y FUNCIONANDO                                    ║"
    echo "║                                                                               ║"
    echo "║   Base de datos :  piscineds                                                  ║"
    echo "║   Usuario       :  $(id -un)                                                   ║"
    echo "║   Contraseña    :  mysecretpassword                                           ║"
    echo "║                                                                               ║"
    echo "║   Formas de conectarte:                                                       ║"
    echo "║                                                                               ║"
    if [ "$PSQL_AVAILABLE" -eq 1 ]; then
        echo "║   1. psql -U \$(whoami) -d piscineds -h localhost -W                           ║"
    else
        echo "║   1. docker exec -it postgres_piscineds psql -U \$(whoami) -d piscineds -W     ║"
    fi
    echo "║                                                                               ║"
    echo "║   Usa la contraseña: mysecretpassword                                         ║"
    echo "║                                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
else
    echo -e "${YELLOW}"
    echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                         ⚠️  ENTORNO INCOMPLETO                                ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${YELLOW}Antes de conectarte, revisa lo siguiente:${NC}"
    if [ "$ENV_EXISTS" -eq 0 ]; then
        echo -e "  ${RED}❌ Falta .env: Docker Compose no tiene las credenciales de PostgreSQL.${NC}"
        echo -e "     Solución: usa la opción 8 del menú para crearlo ahora."
    else
        echo -e "  ${GREEN}✅ .env existe${NC}"
    fi
    if [ "$GITIGNORE_PROTECTED" -eq 0 ] && [ "$ENV_EXISTS" -eq 1 ]; then
        echo -e "  ${RED}⚠️  .env no está protegido por .gitignore.${NC}"
        echo -e "     Solución: usa la opción 7 del menú para protegerlo."
    elif [ "$ENV_EXISTS" -eq 1 ]; then
        echo -e "  ${GREEN}✅ .env está protegido por .gitignore${NC}"
    fi
    if [ "$CONTAINER_RUNNING" -eq 0 ]; then
        echo -e "  ${RED}❌ El contenedor postgres_piscineds no está corriendo.${NC}"
        echo -e "     Solución: usa la opción 6 del menú para arrancarlo."
    else
        echo -e "  ${GREEN}✅ El contenedor está corriendo${NC}"
    fi
    if [ "$PSQL_AVAILABLE" -eq 0 ]; then
        echo -e "  ${YELLOW}⚠️  psql no está instalado en el host.${NC}"
        echo -e "     PostgreSQL sigue funcionando; la opción 5 usará psql dentro del contenedor."
        echo -e "     Puedes instalar el cliente aceptando el PASO 2 al volver a ejecutar este script."
    else
        echo -e "  ${GREEN}✅ Cliente psql disponible${NC}"
    fi
fi

# ------------------------------------------------------------
# MENÚ INTERACTIVO FINAL
# ------------------------------------------------------------
while true; do
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}📋  MENÚ DE OPCIONES${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  1) Confirmar que el contenedor está corriendo"
    echo "  2) Ver los logs completos del contenedor"
    echo "  3) Ver solo las últimas 20 líneas de los logs"
    echo "  4) Parar el servicio y borrar TODOS los datos (¡cuidado!)"
    echo "  5) Conectar con la base de datos"
    echo "  6) Arrancar el contenedor si está detenido"
    echo "  7) Añadir .env a .gitignore"
    echo "  8) Crear el archivo .env si falta"
    echo "  0) Salir de este script de ex00"
    echo ""
    read -p "$(echo -e "${YELLOW}Elige una opción (0-8) → ${NC}")" OPTION

    case $OPTION in
        1)
            echo -e "\n${BLUE}→ Estado actual del contenedor:${NC}"
            echo ""
            docker ps --filter "name=postgres_piscineds" --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"
            echo ""
            if docker ps --format '{{.Names}}' | grep -q "postgres_piscineds"; then
                echo -e "${GREEN}✅  El contenedor está corriendo${NC}"
            else
                echo -e "${RED}❌  El contenedor NO está corriendo${NC}"
            fi
            ;;
        2)
            echo -e "\n${BLUE}→ Logs completos del contenedor:${NC}"
            echo ""
            docker logs postgres_piscineds
            ;;
        3)
            echo -e "\n${BLUE}→ Últimas 20 líneas de los logs:${NC}"
            echo ""
            docker logs --tail 20 postgres_piscineds
            ;;
        4)
            echo -e "\n${RED}⚠️  ATENCIÓN: Vas a borrar el contenedor y TODOS los datos del volumen.${NC}"
            echo -e "Esta acción ${BOLD}no se puede deshacer${NC}."
            echo ""
            read -p "$(echo -e "${YELLOW}Escribe 'si' para confirmar → ${NC}")" CONFIRM
            if [[ "$CONFIRM" == "si" ]]; then
                echo -e "\n${BLUE}→ Ejecutando: docker-compose down -v${NC}"
                echo ""
                docker-compose down -v
                echo ""
                echo -e "${GREEN}✅  Contenedor y datos eliminados${NC}"
            else
                echo -e "${YELLOW}⏭️  Operación cancelada${NC}"
            fi
            ;;
        5)
            if [ "$CONTAINER_RUNNING" -eq 0 ]; then
                echo -e "\n${RED}⚠️  No se puede conectar: el contenedor no está corriendo.${NC}"
                echo -e "Usa primero la opción 6 para arrancarlo."
            elif [ "$PSQL_AVAILABLE" -eq 0 ]; then
                echo -e "\n${BLUE}→ Conectando con el psql incluido en el contenedor...${NC}"
                echo -e "${BLUE}📌  Para salir de la base de datos escribe: ${YELLOW}\\q${BLUE}  y pulsa Enter${NC}"
                echo ""
                docker exec -it postgres_piscineds psql -U "$(id -un)" -d piscineds -W
            else
                echo -e "\n${BLUE}→ Conectando a la base de datos...${NC}"
                echo ""
                echo -e "Se usará el comando:"
                echo -e "  ${BOLD}psql -U \$(whoami) -d piscineds -h localhost -W${NC}"
                echo ""
                echo -e "${BLUE}📌  Cuando pida la contraseña escribe: ${YELLOW}mysecretpassword${NC}"
                echo -e "${BLUE}📌  Para salir de la base de datos escribe: ${YELLOW}\\q${BLUE}  y pulsa Enter${NC}"
                echo ""
                psql -U "$(whoami)" -d piscineds -h localhost -W
            fi
            ;;
        6)
            echo -e "\n${BLUE}→ Arrancando el contenedor...${NC}"
            if [ "$ENV_EXISTS" -eq 0 ]; then
                echo -e "${RED}❌  No se puede arrancar: falta .env. Usa primero la opción 8.${NC}"
            elif docker-compose up -d; then
                CONTAINER_RUNNING=1
                echo -e "${GREEN}✅  Contenedor arrancado correctamente${NC}"
            else
                echo -e "${RED}❌  No se pudo arrancar el contenedor${NC}"
            fi
            ;;
        7)
            if [ ! -f .env ]; then
                echo -e "\n${RED}⚠️  No existe .env; no hay credenciales que proteger.${NC}"
            elif [ -f .gitignore ] && grep -qxF '.env' .gitignore; then
                echo -e "\n${GREEN}✅  .env ya estaba protegido en .gitignore${NC}"
                GITIGNORE_PROTECTED=1
            elif [ -e .gitignore ] && [ ! -f .gitignore ]; then
                echo -e "\n${RED}❌  .gitignore existe, pero no es un archivo regular${NC}"
            else
                printf '%s\n' ".env" >> .gitignore
                GITIGNORE_PROTECTED=1
                echo -e "\n${GREEN}✅  Entrada .env añadida a .gitignore${NC}"
            fi
            ;;
        8)
            if [ "$ENV_EXISTS" -eq 1 ]; then
                echo -e "\n${GREEN}✅  El archivo .env ya existe${NC}"
            else
                echo -e "\n${YELLOW}⚠️  Se crearán credenciales locales para PostgreSQL.${NC}"
                echo -e "El archivo contendrá la contraseña ${BOLD}mysecretpassword${NC}."
                echo -e "Después, usa la opción 7 para protegerlo con .gitignore."
                echo ""
                if ask_yes_no "¿Crear .env ahora?" "n"; then
                    printf 'POSTGRES_USER=%s\nPOSTGRES_PASSWORD=mysecretpassword\nPOSTGRES_DB=piscineds\n' "$(id -un)" > .env
                    if [ -f .env ]; then
                        ENV_EXISTS=1
                        echo -e "${GREEN}✅  Archivo .env creado correctamente${NC}"
                    else
                        echo -e "${RED}❌  No se pudo crear .env${NC}"
                    fi
                else
                    echo -e "${YELLOW}⏭️  Creación cancelada${NC}"
                fi
            fi
            ;;
        0)
            echo -e "\n${GREEN}👋  ¡Hasta luego!${NC}"
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}❌  Opción no válida. Introduce un número del 0 al 8.${NC}"
            ;;
    esac
done
