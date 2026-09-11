#!/usr/bin/env bash

# ============================================================
# PISCINE PEDAGO - DATA SCIENCE
# Data Science 0 - Creation DB — ASISTENTE GLOBAL (raíz)
#
# INDEPENDIENTE de ex00…ex04/start.sh
#   • Este script hace el recorrido del Module 0 por sí solo.
#   • Si existen start.sh en cada ex/, puede ofrecerlos como
#     atajo opcional, pero NO son obligatorios.
#   • Un compañero puede clonar solo entregables + este start.sh
#     y seguir el flujo de trabajo / evaluación.
#
# Uso (cualquier directorio):
#   /ruta/a/data_science_0_creation_db/start.sh
#   ./start.sh
#
# Seguridad:
#   - Sin push automático (default N)
#   - Sin borrar volúmenes Docker sin confirmación
#   - .env y CSV pesados no se copian a la carpeta de evaluación
#   - chmod +x solo tras confirmar
# ============================================================

set -u

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
PROJECT_DIR="$SCRIPT_DIR"
EX00_DIR="$PROJECT_DIR/ex00"
EX01_DIR="$PROJECT_DIR/ex01"
EX02_DIR="$PROJECT_DIR/ex02"
EX03_DIR="$PROJECT_DIR/ex03"
EX04_DIR="$PROJECT_DIR/ex04"
ENV_FILE="$EX00_DIR/.env"
CONTAINER_NAME="postgres_piscineds"
EVAL_DIR_LAST=""

# ------------------------------------------------------------
# UI
# ------------------------------------------------------------
print_header()
{
    clear
    echo
    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║                                                            ║${RESET}"
    echo -e "${CYAN}${BOLD}║    PISCINE PEDAGO - DATA SCIENCE - sternero - 42 Málaga    ║${RESET}"
    echo -e "${CYAN}${BOLD}║                                                            ║${RESET}"
    echo -e "${CYAN}${BOLD}║     Data Science 0 – Asistente GLOBAL (autosuficiente)     ║${RESET}"
    echo -e "${CYAN}${BOLD}║                                                            ║${RESET}"
    echo -e "${CYAN}${BOLD}║      Trabajo · Cargas · Evaluación · Git · Permisos +x     ║${RESET}"
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

info()  { echo -e "${CYAN}→ $1${RESET}"; }
ok()    { echo -e "${GREEN}✓ $1${RESET}"; }
warn()  { echo -e "${YELLOW}⚠ $1${RESET}"; }
err()   { echo -e "${RED}✗ $1${RESET}"; }

# ------------------------------------------------------------
# .env
# ------------------------------------------------------------
read_env()
{
    POSTGRES_USER=""
    POSTGRES_PASSWORD=""
    POSTGRES_DB=""
    [[ -f "$ENV_FILE" ]] || return 1
    POSTGRES_USER="$(sed -n 's/^POSTGRES_USER=//p' "$ENV_FILE" | head -n 1)"
    POSTGRES_PASSWORD="$(sed -n 's/^POSTGRES_PASSWORD=//p' "$ENV_FILE" | head -n 1)"
    POSTGRES_DB="$(sed -n 's/^POSTGRES_DB=//p' "$ENV_FILE" | head -n 1)"
    [[ -n "$POSTGRES_USER" && -n "$POSTGRES_PASSWORD" && -n "$POSTGRES_DB" ]]
}

ensure_env()
{
    section "🔐  Archivo .env (EX00)"

    echo -e "${CYAN}→ Por qué:${RESET} usuario, contraseña y BD sin hardcodear en scripts."
    echo -e "${CYAN}→ Ruta:${RESET} $ENV_FILE"
    echo

    if read_env; then
        ok ".env ya existe"
        echo "  USER=$POSTGRES_USER  DB=$POSTGRES_DB  PASS=[oculta]"
        if ask_yes_no "¿Regenerar .env con valores por defecto del subject?" "n"; then
            :
        else
            return 0
        fi
    fi

    mkdir -p "$EX00_DIR"
    local u p d
    u="$(id -un 2>/dev/null || whoami)"
    p="mysecretpassword"
    d="piscineds"
    echo -e "Valores propuestos: USER=$u  PASS=$p  DB=$d"
    if ! ask_yes_no "¿Escribir estos valores en ex00/.env?" "s"; then
        warn "No se modificó .env"
        return 1
    fi
    printf 'POSTGRES_USER=%s\nPOSTGRES_PASSWORD=%s\nPOSTGRES_DB=%s\n' "$u" "$p" "$d" > "$ENV_FILE"
    ok "Escrito $ENV_FILE"
    read_env
}

# ------------------------------------------------------------
# Permisos +x
# ------------------------------------------------------------
# Lista de scripts que suelen necesitar ejecución
collect_exec_candidates()
{
    local base="${1:-$PROJECT_DIR}"
    local f
    # start.sh en raíz y en cada ex
    [[ -f "$base/start.sh" ]] && echo "$base/start.sh"
    for f in "$base"/ex0{0,1,2,3,4}/start.sh \
             "$base"/ex01/install.sh \
             "$base"/ex01/off_del.sh \
             "$base"/ex03/automatic_table.py \
             "$base"/ex04/items_table.py
    do
        [[ -f "$f" ]] && echo "$f"
    done
    # cualquier automatic_table.* / items_table.py ya cubierto
}

fix_executable_permissions()
{
    section "🔑  Permisos de ejecución (+x)"

    echo -e "${CYAN}→ Por qué:${RESET} tras clonar, Git a veces no conserva el bit ejecutable"
    echo -e "  y aparecen errores del tipo: ${WHITE}Permission denied${RESET} o"
    echo -e "  ${WHITE}bash: ./start.sh: Permission denied${RESET}."
    echo
    echo -e "Este paso hace ${BOLD}chmod +x${RESET} solo sobre scripts conocidos."
    echo -e "No cambia el dueño ni toca datos de PostgreSQL."
    echo

    local root="${1:-$PROJECT_DIR}"
    local -a files=()
    local line
    while IFS= read -r line; do
        [[ -n "$line" ]] && files+=("$line")
    done < <(collect_exec_candidates "$root")

    if [[ ${#files[@]} -eq 0 ]]; then
        warn "No se encontraron scripts candidatos en $root"
        return 0
    fi

    echo -e "${BOLD}Candidatos:${RESET}"
    local f
    for f in "${files[@]}"; do
        if [[ -x "$f" ]]; then
            echo -e "  ${GREEN}[ya +x]${RESET} $f"
        else
            echo -e "  ${YELLOW}[sin +x]${RESET} $f"
        fi
    done
    echo

    if ! ask_yes_no "¿Aplicar chmod +x a los que falten (y opcionalmente a todos)?" "s"; then
        warn "Permisos no modificados"
        return 0
    fi

    for f in "${files[@]}"; do
        if chmod +x "$f" 2>/dev/null; then
            ok "chmod +x → $f"
        else
            err "No se pudo chmod: $f"
        fi
    done
    echo
    ok "Permisos de ejecución actualizados en $root"
    echo
    echo -e "${BOLD}Nota Git:${RESET} para que el clon futuro conserve +x:"
    echo -e "  ${WHITE}git update-index --chmod=+x ruta/al/script${RESET}"
    echo -e "  (opción del menú: marcar ejecutables en el índice Git)"
    echo
}

git_mark_executables()
{
    section "📌  Marcar +x en el índice Git (para clones futuros)"

    echo -e "${CYAN}→ Por qué:${RESET} ${WHITE}chmod +x${RESET} en disco no siempre se sube al remoto."
    echo -e "  ${WHITE}git update-index --chmod=+x${RESET} guarda el bit en el commit."
    echo

    if ! command -v git >/dev/null 2>&1; then
        err "git no está en el PATH"
        return 1
    fi
    if [[ ! -d "$PROJECT_DIR/.git" ]]; then
        warn "Este proyecto aún no es un repo git (no hay .git en $PROJECT_DIR)"
        echo "  Puedes hacerlo más tarde en la carpeta de evaluación."
        return 1
    fi

    (
        cd "$PROJECT_DIR" || exit 1
        local f rel
        while IFS= read -r f; do
            [[ -f "$f" ]] || continue
            rel="${f#$PROJECT_DIR/}"
            # Solo si el archivo está tracked o se puede añadir
            if git ls-files --error-unmatch "$rel" >/dev/null 2>&1; then
                if ask_yes_no "¿git update-index --chmod=+x $rel ?" "s"; then
                    git update-index --chmod=+x "$rel" 2>/dev/null \
                        && ok "índice: +x $rel" \
                        || warn "No se pudo marcar $rel (¿sin cambios en índice?)"
                fi
            else
                info "Sin trackear aún: $rel (haz git add antes o en carpeta de entrega)"
            fi
        done < <(collect_exec_candidates "$PROJECT_DIR")
    )
    echo
    info "Después: git commit -m \"chmod +x scripts\" && git push (con supervisión)"
    echo
}

# ------------------------------------------------------------
# Docker / contenedor
# ------------------------------------------------------------
ensure_docker()
{
    if ! command -v docker >/dev/null 2>&1; then
        err "Docker no está en el PATH"
        return 1
    fi
    if ! docker info >/dev/null 2>&1; then
        err "Docker no responde (demonio o permisos)"
        return 1
    fi
    ok "Docker operativo"
    return 0
}

start_postgres()
{
    section "🐘  EX00 – Levantar PostgreSQL"

    echo -e "${CYAN}→ Por qué:${RESET} el Module 0 vive en el contenedor $CONTAINER_NAME."
    echo

    if ! ensure_docker; then
        return 1
    fi
    ensure_env || true

    if [[ ! -f "$EX00_DIR/docker-compose.yml" ]]; then
        err "Falta $EX00_DIR/docker-compose.yml"
        return 1
    fi

    if docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
        ok "Contenedor ya está en marcha"
        docker ps --filter "name=^/${CONTAINER_NAME}$" --format "  {{.Status}} | {{.Ports}}"
        return 0
    fi

    if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
        info "Contenedor existe pero parado → docker start"
        if ask_yes_no "¿Arrancar $CONTAINER_NAME?" "s"; then
            docker start "$CONTAINER_NAME" && sleep 2
            ok "Arrancado"
            return 0
        fi
        return 1
    fi

    echo -e "${CYAN}→ Comando:${RESET} cd ex00 && docker-compose up -d"
    if ! ask_yes_no "¿Ejecutar docker-compose up -d en ex00?" "s"; then
        warn "Omitido"
        return 1
    fi
    (
        cd "$EX00_DIR" || exit 1
        docker-compose up -d
    )
    sleep 2
    if docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
        ok "PostgreSQL arriba"
    else
        err "No se ve el contenedor; revisa: docker logs / docker-compose logs"
        return 1
    fi
}

status_environment()
{
    section "📊  Estado del entorno"

    echo -e "${BOLD}Docker${RESET}"
    ensure_docker || true
    echo
    echo -e "${BOLD}.env${RESET}"
    if read_env; then
        ok "USER=$POSTGRES_USER DB=$POSTGRES_DB"
    else
        warn "Falta $ENV_FILE"
    fi
    echo
    echo -e "${BOLD}Contenedor${RESET}"
    if docker ps --format '{{.Names}}' 2>/dev/null | grep -qx "$CONTAINER_NAME"; then
        ok "Up"
        docker ps --filter "name=^/${CONTAINER_NAME}$" --format "  {{.Status}} | {{.Ports}}" 2>/dev/null || true
    else
        warn "No está corriendo"
    fi
    echo
    echo -e "${BOLD}pg_isready / \\dt${RESET}"
    if docker ps --format '{{.Names}}' 2>/dev/null | grep -qx "$CONTAINER_NAME" && read_env; then
        if docker exec "$CONTAINER_NAME" pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" >/dev/null 2>&1; then
            ok "PostgreSQL responde"
            docker exec -i "$CONTAINER_NAME" \
                psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\dt' 2>/dev/null || true
        else
            warn "pg_isready falló"
        fi
    else
        info "Sin comprobación SQL (falta contenedor o .env)"
    fi
    echo
}

# ------------------------------------------------------------
# Cargas EX02 / EX03 / EX04 (sin depender de otros start.sh)
# ------------------------------------------------------------
find_customer_csv_dir()
{
    local c
    for c in \
        "$PROJECT_DIR/subject/customer" \
        "$PROJECT_DIR/customer" \
        "$EX03_DIR/customer"
    do
        if [[ -d "$c" ]] && compgen -G "$c/*.csv" >/dev/null 2>&1; then
            echo "$c"
            return 0
        fi
    done
    return 1
}

find_item_csv()
{
    local c
    for c in \
        "$PROJECT_DIR/subject/item/item.csv" \
        "$PROJECT_DIR/subject/items/item.csv" \
        "$PROJECT_DIR/item/item.csv"
    do
        [[ -f "$c" ]] && { echo "$c"; return 0; }
    done
    return 1
}

run_ex02_load()
{
    section "📥  EX02 – First table (SQL + COPY)"

    echo -e "${CYAN}→ Por qué:${RESET} crear/cargar una tabla de customer a mano (subject)."
    local sql="$EX02_DIR/table.sql"
    if [[ ! -f "$sql" ]]; then
        err "Falta $sql"
        return 1
    fi
    if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
        err "Contenedor parado — usa antes la opción de levantar PostgreSQL"
        return 1
    fi
    read_env || { err "Sin .env"; return 1; }

    # El table.sql de EX02 suele referirse a data_2022_dec; copiamos ese CSV si existe
    local csv_dir csv
    csv_dir="$(find_customer_csv_dir || true)"
    csv=""
    if [[ -n "$csv_dir" && -f "$csv_dir/data_2022_dec.csv" ]]; then
        csv="$csv_dir/data_2022_dec.csv"
    elif [[ -n "$csv_dir" ]]; then
        csv="$(ls "$csv_dir"/*.csv 2>/dev/null | head -n 1)"
    fi

    echo -e "SQL: $sql"
    echo -e "CSV: ${csv:-'(no encontrado — solo se aplicará el SQL)'}"
    echo
    if ! ask_yes_no "¿Aplicar table.sql (y COPY si hay CSV)?" "s"; then
        warn "Omitido"
        return 0
    fi

    docker cp "$sql" "$CONTAINER_NAME:/tmp/table.sql" 2>/dev/null || true
    docker exec -i "$CONTAINER_NAME" \
        psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /tmp/table.sql

    if [[ -n "$csv" && -f "$csv" ]]; then
        local base
        base="$(basename "$csv")"
        docker cp "$csv" "$CONTAINER_NAME:/tmp/$base" 2>/dev/null || true
        # Intento genérico: muchas table.sql ya incluyen COPY; si no, aviso
        info "CSV copiado a /tmp/$base dentro del contenedor"
        info "Si table.sql ya hace COPY, listo. Si no, ejecuta COPY a mano (ver README EX02)."
    fi
    echo
    ok "EX02: SQL aplicado (revisa mensajes arriba)"
    echo
}

run_ex03_load()
{
    section "🤖  EX03 – Automatic table"

    local py="$EX03_DIR/automatic_table.py"
    if [[ ! -f "$py" ]]; then
        err "Falta $py"
        return 1
    fi
    if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
        err "Contenedor parado"
        return 1
    fi
    read_env || true

    chmod +x "$py" 2>/dev/null || true
    local cdir
    cdir="$(find_customer_csv_dir || true)"
    echo -e "Script: $py"
    echo -e "customer/: ${cdir:-'(pásala como argumento)'}"
    echo
    if ! ask_yes_no "¿Ejecutar automatic_table.py ahora? (puede tardar minutos)" "s"; then
        warn "Omitido"
        return 0
    fi
    (
        cd "$EX03_DIR" || exit 1
        if [[ -n "$cdir" ]]; then
            python3 "$py" "$cdir"
        else
            python3 "$py"
        fi
    )
    echo
}

run_ex04_load()
{
    section "📦  EX04 – Items table"

    echo -e "Puedes cargar con ${BOLD}SQL+COPY${RESET} o con ${BOLD}Python${RESET}."
    echo -e "  1) SQL (items_table.sql)"
    echo -e "  2) Python (items_table.py)"
    read -r -p "$(echo -e "${YELLOW}1 o 2 [1] → ${RESET}")" mode
    mode="${mode:-1}"

    if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
        err "Contenedor parado"
        return 1
    fi
    read_env || { err "Sin .env"; return 1; }

    local item
    item="$(find_item_csv || true)"

    if [[ "$mode" == "2" ]]; then
        local py="$EX04_DIR/items_table.py"
        if [[ ! -f "$py" ]]; then
            err "Falta $py"
            return 1
        fi
        chmod +x "$py" 2>/dev/null || true
        if ! ask_yes_no "¿Ejecutar items_table.py?" "s"; then
            warn "Omitido"
            return 0
        fi
        (
            cd "$EX04_DIR" || exit 1
            if [[ -n "$item" ]]; then
                python3 "$py" "$item"
            else
                python3 "$py"
            fi
        )
        return 0
    fi

    local sql="$EX04_DIR/items_table.sql"
    if [[ ! -f "$sql" ]]; then
        err "Falta $sql"
        return 1
    fi
    if [[ -z "$item" ]]; then
        err "No se encontró item.csv"
        return 1
    fi
    if ! ask_yes_no "¿docker cp + CREATE + COPY items?" "s"; then
        warn "Omitido"
        return 0
    fi
    docker cp "$item" "$CONTAINER_NAME:/tmp/item.csv" 2>/dev/null || true
    docker cp "$sql" "$CONTAINER_NAME:/tmp/items_table.sql" 2>/dev/null || true
    docker exec -i "$CONTAINER_NAME" \
        psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /tmp/items_table.sql
    docker exec -i "$CONTAINER_NAME" \
        psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c \
        "COPY items FROM '/tmp/item.csv' WITH (FORMAT csv, HEADER true);"
    echo
    ok "EX04 SQL+COPY terminado (revisa COPY nnn arriba)"
    echo
}

open_psql()
{
    section "💻  psql en el contenedor"
    if ! read_env || ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
        err "Entorno incompleto"
        return 1
    fi
    echo -e "${YELLOW}Salir: \\q${RESET}"
    docker exec -it "$CONTAINER_NAME" \
        psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"
}

# ------------------------------------------------------------
# Verificación entregables
# ------------------------------------------------------------
check_delivery_files()
{
    section "📁  Archivos de entrega (subject)"

    local missing=0
    [[ -f "$EX00_DIR/docker-compose.yml" ]] && ok "ex00/docker-compose.yml" || { err "falta docker-compose.yml"; missing=$((missing+1)); }
    [[ -f "$EX02_DIR/table.sql" ]] && ok "ex02/table.sql" || { warn "ex02/table.sql?"; missing=$((missing+1)); }
    if compgen -G "$EX03_DIR/automatic_table.*" >/dev/null 2>&1; then
        ok "ex03/automatic_table.*"
    else
        err "falta automatic_table.*"; missing=$((missing+1))
    fi
    if compgen -G "$EX04_DIR/items_table.*" >/dev/null 2>&1; then
        ok "ex04/items_table.*"
    else
        err "falta items_table.*"; missing=$((missing+1))
    fi
    echo
    [[ $missing -eq 0 ]] && ok "Entregables principales OK" || warn "$missing aviso(s)"
    echo
}

eval_reminder()
{
    section "📋  Recordatorio evaluación"
    cat << EOF
• Demo en máquina del evaluado
• EX00: Postgres (login + mysecretpassword + piscineds)
• EX01: GUI (pgAdmin, etc.)
• EX02–04: scripts y tablas según subject
• No subas .env ni CSV enormes salvo que te lo pidan
• Datos: subject/customer/ y subject/item/item.csv
EOF
    echo
}

# ------------------------------------------------------------
# Empaquetado evaluación
# ------------------------------------------------------------
prepare_eval_folder()
{
    section "📦  Carpeta de evaluación (lista blanca)"

    local login dest_name dest_path
    login="$(id -un 2>/dev/null || whoami)"
    dest_name="repo_${login}"
    echo -e "Default: ${BOLD}$dest_name${RESET}"
    read -r -p "$(echo -e "${YELLOW}Nombre (Enter = default) → ${RESET}")" dest_name
    dest_name="${dest_name:-repo_${login}}"
    dest_name="${dest_name##*/}"

    echo "1) Padre del proyecto  2) sgoinfre/goinfre  3) Ruta manual"
    read -r -p "$(echo -e "${YELLOW}1/2/3 [1] → ${RESET}")" where
    where="${where:-1}"
    case "$where" in
        2)
            if [[ -d "$HOME/sgoinfre" ]]; then dest_path="$HOME/sgoinfre/$dest_name"
            elif [[ -d "$HOME/goinfre" ]]; then dest_path="$HOME/goinfre/$dest_name"
            else dest_path="$(cd "$PROJECT_DIR/.." && pwd)/$dest_name"
            fi
            ;;
        3)
            read -r -p "$(echo -e "${YELLOW}Directorio padre → ${RESET}")" parent
            dest_path="${parent%/}/$dest_name"
            ;;
        *) dest_path="$(cd "$PROJECT_DIR/.." && pwd)/$dest_name" ;;
    esac

    info "Destino: $dest_path"
    if [[ -e "$dest_path" ]]; then
        warn "Ya existe"
        ask_yes_no "¿Continuar y sobrescribir archivos de la lista blanca?" "n" || { err "Abortado"; return 1; }
    else
        ask_yes_no "¿Crear y copiar entregables?" "s" || { warn "Abortado"; return 0; }
        mkdir -p "$dest_path" || return 1
    fi

    mkdir -p "$dest_path"/{ex00,ex01,ex02,ex03,ex04}

    copy_if()
    {
        local src="$1" dst="$2"
        [[ -f "$src" ]] || return 0
        mkdir -p "$(dirname "$dst")"
        cp -f "$src" "$dst" && ok "→ ${dst#$dest_path/}"
    }

    copy_if "$EX00_DIR/docker-compose.yml" "$dest_path/ex00/docker-compose.yml"
    warn ".env NO se copia (secretos)"
    copy_if "$EX01_DIR/README.md" "$dest_path/ex01/README.md"
    copy_if "$EX02_DIR/table.sql" "$dest_path/ex02/table.sql"
    copy_if "$EX02_DIR/README.md" "$dest_path/ex02/README.md"

    local f
    for f in "$EX03_DIR"/automatic_table.*; do
        [[ -f "$f" ]] || continue
        [[ "$f" == *.md ]] && continue
        copy_if "$f" "$dest_path/ex03/$(basename "$f")"
    done
    copy_if "$EX03_DIR/README.md" "$dest_path/ex03/README.md"

    for f in "$EX04_DIR"/items_table.*; do
        [[ -f "$f" ]] || continue
        copy_if "$f" "$dest_path/ex04/$(basename "$f")"
    done
    copy_if "$EX04_DIR/README.md" "$dest_path/ex04/README.md"
    copy_if "$PROJECT_DIR/README.md" "$dest_path/README.md"
    # Este start.sh global: útil en la carpeta de entrega para el evaluado
    copy_if "$PROJECT_DIR/start.sh" "$dest_path/start.sh"

    if [[ ! -f "$dest_path/.gitignore" ]]; then
        cat > "$dest_path/.gitignore" << 'GI'
.env
*.env
__pycache__/
*.pyc
.venv/
venv/
*.log
.DS_Store
GI
        ok ".gitignore creado"
    fi

    echo
    info "Aplicando +x en la carpeta de evaluación…"
    if ask_yes_no "¿chmod +x scripts en $dest_path?" "s"; then
        fix_executable_permissions "$dest_path"
    fi

    EVAL_DIR_LAST="$dest_path"
    ok "Listo: $dest_path"
    echo "  Recuerda: sin subject/ CSV; sin .env."
    echo
}

# ------------------------------------------------------------
# Git asistido
# ------------------------------------------------------------
git_assisted()
{
    section "🔧  Git asistido"

    local target="${EVAL_DIR_LAST:-$PROJECT_DIR}"
    echo -e "Directorio: ${BOLD}$target${RESET}"
    if ! ask_yes_no "¿Usar esta ruta?" "s"; then
        read -r -p "$(echo -e "${YELLOW}Ruta → ${RESET}")" target
    fi
    [[ -d "$target" ]] || { err "No existe"; return 1; }
    cd "$target" || return 1

    echo "1) status  2) init  3) add  4) commit  5) remote  6) push (default N)  7) update-index +x  b) volver"
    read -r -p "$(echo -e "${YELLOW}→ ${RESET}")" gopt
    case "$gopt" in
        1) git status 2>&1 || true ;;
        2)
            [[ -d .git ]] && warn "Ya hay .git" || {
                ask_yes_no "¿git init?" "s" && git init
            }
            ;;
        3)
            if ask_yes_no "¿git add README.md .gitignore ex00 ex01 ex02 ex03 ex04 start.sh?" "s"; then
                git add README.md .gitignore start.sh 2>/dev/null || true
                git add ex00 ex01 ex02 ex03 ex04 2>/dev/null || true
                git status
            fi
            ;;
        4)
            read -r -p "$(echo -e "${YELLOW}Mensaje → ${RESET}")" msg
            msg="${msg:-Module 0 delivery}"
            ask_yes_no "¿commit?" "s" && git commit -m "$msg" 2>&1 || true
            ;;
        5)
            git remote -v 2>/dev/null || true
            if ask_yes_no "¿add origin?" "n"; then
                read -r -p "$(echo -e "${YELLOW}URL → ${RESET}")" url
                [[ -n "$url" ]] && git remote remove origin 2>/dev/null; git remote add origin "$url"
            fi
            ;;
        6)
            echo -e "${RED}PUSH sensible${RESET}"
            git status -sb 2>/dev/null || true
            if ask_yes_no "¿git push -u origin HEAD?" "n"; then
                git push -u origin HEAD 2>&1 || warn "Falló; prueba main/master a mano"
            else
                warn "Push cancelado"
            fi
            ;;
        7)
            local rel
            for rel in start.sh ex03/automatic_table.py ex04/items_table.py \
                       ex00/start.sh ex01/start.sh ex03/start.sh ex04/start.sh \
                       ex01/install.sh ex01/off_del.sh
            do
                [[ -f "$rel" ]] || continue
                if git ls-files --error-unmatch "$rel" >/dev/null 2>&1; then
                    if ask_yes_no "¿update-index --chmod=+x $rel?" "s"; then
                        git update-index --chmod=+x "$rel" && ok "+x índice $rel"
                    fi
                fi
            done
            ;;
        *) ;;
    esac
    echo
}

# Atajo opcional a start.sh de un ex (si existe)
optional_ex_start()
{
    local dir="$1" label="$2"
    local s="$dir/start.sh"
    section "▶  $label (atajo opcional)"
    if [[ ! -f "$s" ]]; then
        info "No hay $s — no es obligatorio. Usa las opciones de carga de este script."
        return 0
    fi
    echo -e "Hay un start.sh local. ${BOLD}Opcional${RESET}: puedes abrirlo o seguir con el menú global."
    if ask_yes_no "¿Abrir $s?" "n"; then
        chmod +x "$s" 2>/dev/null || true
        ( cd "$dir" && "$s" )
    else
        info "Sigue con las opciones 3–7 de este menú (flujo integrado)."
    fi
}

# ------------------------------------------------------------
# Menú
# ------------------------------------------------------------
show_menu()
{
    echo
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${CYAN}${BOLD}  MENÚ GLOBAL – Module 0 (autosuficiente)${RESET}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo
    echo -e "  ${BOLD}${WHITE}— Entorno —${RESET}"
    echo -e "  ${BOLD}1)${RESET}  Estado (Docker / .env / contenedor / tablas)"
    echo -e "  ${BOLD}2)${RESET}  Crear/regenerar .env + levantar PostgreSQL"
    echo -e "  ${BOLD}p)${RESET}  Permisos +x en scripts del proyecto"
    echo
    echo -e "  ${BOLD}${WHITE}— Cargas (integradas; no requieren otros start.sh) —${RESET}"
    echo -e "  ${BOLD}3)${RESET}  EX02 – aplicar table.sql (+ CSV si hay)"
    echo -e "  ${BOLD}4)${RESET}  EX03 – automatic_table.py"
    echo -e "  ${BOLD}5)${RESET}  EX04 – items (SQL o Python)"
    echo -e "  ${BOLD}6)${RESET}  Abrir psql"
    echo -e "  ${BOLD}7)${RESET}  Verificar archivos de entrega"
    echo
    echo -e "  ${BOLD}${WHITE}— Atajos opcionales (solo si existen) —${RESET}"
    echo -e "  ${BOLD}a)${RESET}  ex00/start.sh   ${BOLD}b)${RESET} ex01   ${BOLD}c)${RESET} ex03   ${BOLD}d)${RESET} ex04"
    echo
    echo -e "  ${BOLD}${WHITE}— Evaluación —${RESET}"
    echo -e "  ${BOLD}8)${RESET}  Preparar repo_<login> (lista blanca + chmod)"
    echo -e "  ${BOLD}9)${RESET}  Recordatorio de defensa"
    echo -e "  ${BOLD}0)${RESET}  Git asistido (push default N; update-index +x)"
    echo
    echo -e "  ${RED}${BOLD}q)${RESET}  ${RED}Salir${RESET}"
    echo
}

menu_loop()
{
    local choice
    while true; do
        show_menu
        read -r -p "$(echo -e "${YELLOW}Opción → ${RESET}")" choice
        echo
        case "$choice" in
            1) status_environment; pause ;;
            2) start_postgres; pause ;;
            p|P) fix_executable_permissions "$PROJECT_DIR"; pause ;;
            3) run_ex02_load; pause ;;
            4) run_ex03_load; pause ;;
            5) run_ex04_load; pause ;;
            6) open_psql; pause ;;
            7) check_delivery_files; pause ;;
            a|A) optional_ex_start "$EX00_DIR" "EX00"; pause ;;
            b|B) optional_ex_start "$EX01_DIR" "EX01"; pause ;;
            c|C) optional_ex_start "$EX03_DIR" "EX03"; pause ;;
            d|D) optional_ex_start "$EX04_DIR" "EX04"; pause ;;
            8) prepare_eval_folder; pause ;;
            9) eval_reminder; pause ;;
            0) git_assisted; pause ;;
            q|Q)
                echo -e "${GREEN}Hasta luego.${RESET}"
                exit 0
                ;;
            *) warn "Opción no válida" ;;
        esac
    done
}

main()
{
    print_header
    echo -e "${WHITE}Asistente ${BOLD}independiente${RESET}${WHITE}: no necesita los start.sh de cada ex.${RESET}"
    echo -e "  Si existen, puedes usarlos como atajo (a–d). El flujo completo está en 1–7."
    echo
    echo -e "${CYAN}Sin push automático · sin borrar volúmenes · +x solo con permiso.${RESET}"
    echo

    if ask_yes_no "¿Comprobar y aplicar permisos +x al arrancar?" "s"; then
        fix_executable_permissions "$PROJECT_DIR"
    fi
    if ask_yes_no "¿Ver estado del entorno?" "s"; then
        status_environment
    fi
    menu_loop
}

main "$@"
