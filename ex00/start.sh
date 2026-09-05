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

if ask_yes_no "¿Crear el archivo .env ahora?" "s"; then
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
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}🔒  PASO 1B: Proteger las credenciales con .gitignore${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "El archivo ${BOLD}.env${NC} contiene credenciales y no debe subirse a GitHub."
echo -e "Se añadirá la entrada ${BOLD}.env${NC} a ${BOLD}.gitignore${NC}."
echo -e "Si ${BOLD}.gitignore${NC} no existe, se creará en este directorio."
echo ""
echo -e "${RED}⚠️  Sin esta protección podrías publicar accidentalmente tu contraseña.${NC}"
echo ""

if ask_yes_no "¿Añadir .env a .gitignore ahora?" "s"; then
    if [ ! -e .gitignore ]; then
        printf '%s\n' ".env" > .gitignore
        echo -e "${GREEN}✅  .gitignore creado con la entrada .env${NC}"
    elif [ ! -f .gitignore ]; then
        echo -e "${RED}❌  .gitignore existe, pero no es un archivo regular${NC}"
    elif grep -qxF '.env' .gitignore; then
        echo -e "${GREEN}✅  .env ya estaba protegido en .gitignore${NC}"
    else
        printf '\n%s\n' ".env" >> .gitignore
        echo -e "${GREEN}✅  Entrada .env añadida a .gitignore${NC}"
    fi
else
    echo -e "${RED}⚠️  No se ha modificado .gitignore: .env podría subirse a GitHub.${NC}"
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

if ask_yes_no "¿Instalar el cliente psql en el host ahora?" "s"; then
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

if ask_yes_no "¿Arrancar el contenedor ahora?" "s"; then
    echo -e "\n${BLUE}→ Ejecutando: docker-compose up -d${NC}"
    echo ""
    docker-compose up -d
    echo ""

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅  Contenedor arrancado correctamente${NC}"
    else
        echo -e "${RED}❌  Error al arrancar el contenedor${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⏭️  Se omite el arranque del contenedor${NC}"
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

if ask_yes_no "¿Verificar el estado del contenedor ahora?" "s"; then
    echo -e "\n${BLUE}→ Ejecutando: docker ps --filter \"name=postgres_piscineds\"${NC}"
    echo ""
    docker ps --filter "name=postgres_piscineds" --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"
    echo ""

    if docker ps --format '{{.Names}}' | grep -q "postgres_piscineds"; then
        echo -e "${GREEN}✅  El contenedor postgres_piscineds está corriendo correctamente${NC}"
    else
        echo -e "${RED}❌  El contenedor no está corriendo${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⏭️  Se omite la verificación${NC}"
fi

echo ""
sleep 1

# ------------------------------------------------------------
# MENSAJE FINAL DE ÉXITO
# ------------------------------------------------------------
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
echo "║   1. psql -U \$(whoami) -d piscineds -h localhost -W                           ║"
echo "║                                                                               ║"
echo "║   Usa la contraseña: mysecretpassword                                         ║"
echo "║                                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

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
    echo "  0) Salir del script"
    echo ""
    read -p "$(echo -e "${YELLOW}Elige una opción (0-5) → ${NC}")" OPTION

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
            echo -e "\n${BLUE}→ Conectando a la base de datos...${NC}"
            echo ""
            echo -e "Se usará el comando:"
            echo -e "  ${BOLD}psql -U \$(whoami) -d piscineds -h localhost -W${NC}"
            echo ""
            echo -e "${BLUE}📌  Cuando pida la contraseña escribe: ${YELLOW}mysecretpassword${NC}"
            echo -e "${BLUE}📌  Para salir de la base de datos escribe: ${YELLOW}\\q${BLUE}  y pulsa Enter${NC}"
            echo ""
            psql -U "$(whoami)" -d piscineds -h localhost -W
            ;;
        0)
            echo -e "\n${GREEN}👋  ¡Hasta luego!${NC}"
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}❌  Opción no válida. Introduce un número del 0 al 5.${NC}"
            ;;
    esac
done
