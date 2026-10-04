#!/usr/bin/env bash
###############################################################################
#  DATA SCIENCE 0 – Creation of a DB · evaluation.sh
#
#  Guía interactiva de defensa basada en:
#    HOJA DE EVALUACIÓN (SCALE) – PROJECT DATA SCIENCE - 0  (/PROJECTS/DATA-SCIENCE-0)
#
#  Estilo alineado con evaluation.sh de otros proyectos Outer Core
#  (p. ej. Arachnida): cabeceras, colores, secciones, checklist Yes/No.
#
#  Uso (desde la raíz del repo del evaluado o de este módulo):
#    chmod +x evaluation.sh
#    ./evaluation.sh
#
#  Automatiza comprobaciones Docker/estructura, ofrece lanzar table.*/
#  automatic_table.*/items_table.* (auto o manual) y guía eval.zip.
#  Cada bloque explica contexto (hoja de evaluación), muestra comandos copiables y pide s/n.
#  Este fichero NO es entregable ni puntúa: solo guía de defensa.
#
#  sternero – 42 Málaga – Octubre 2026
###############################################################################

set -u
# no set -e: un fallo de comprobación no debe abortar toda la defensa

# ============================================================================
# COLORES Y FORMATO
# ============================================================================
readonly RED=$'\033[0;31m'
readonly GREEN=$'\033[0;32m'
readonly YELLOW=$'\033[1;33m'
readonly BLUE=$'\033[0;34m'
readonly CYAN=$'\033[0;36m'
readonly MAGENTA=$'\033[0;35m'
readonly BOLD=$'\033[1m'
readonly DIM=$'\033[2m'
readonly RESET=$'\033[0m'

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

# Resultados acumulados (Yes = 1, No = 0, Skip = -)
declare -A RESULT
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0
STOP_EVAL=false   # true si la hoja de evaluación dice "evaluation ends / stops here"
LAST_RESULT_KIND="info"
LAST_RESULT_TEXT="Evaluación iniciada"

# ============================================================================
# SALIDA
# ============================================================================
header() {
  clear 2>/dev/null || true
  echo -e "${BOLD}${BLUE}"
  echo "╔══════════════════════════════════════════════════════════════════╗"
  echo "║  DATA SCIENCE 0 – Creation of a DB · DEFENSA / EVALUATION        ║"
  echo "║  Hoja: /PROJECTS/DATA-SCIENCE-0                                 ║"
  echo "╚══════════════════════════════════════════════════════════════════╝"
  echo -e "${RESET}"
  echo -e "  ${DIM}Repo: ${SCRIPT_DIR}${RESET}"
  echo -e "  ${DIM}Login evaluado: $(whoami) · $(date '+%Y-%m-%d %H:%M')${RESET}"
  echo
}

section() {
  echo
  echo
  echo -e "${BOLD}${CYAN}▶ $1${RESET}"
  echo -e "${CYAN}────────────────────────────────────────────────────────────────${RESET}"
  echo
}

subsection() {
  echo -e "  ${MAGENTA}├─ $1${RESET}"
}

ok() {
  LAST_RESULT_KIND="success"
  LAST_RESULT_TEXT="$1"
  echo -e "    ${GREEN}✓${RESET} $1"
  ((PASS_COUNT++)) || true
}
fail() {
  LAST_RESULT_KIND="error"
  LAST_RESULT_TEXT="$1"
  echo -e "    ${RED}✗${RESET} $1"
  ((FAIL_COUNT++)) || true
}
warn() {
  LAST_RESULT_KIND="warning"
  LAST_RESULT_TEXT="$1"
  echo -e "    ${YELLOW}⚠${RESET} $1"
  ((WARN_COUNT++)) || true
}
info() { echo -e "    ${CYAN}ℹ${RESET} $1"; }
note() { echo -e "    ${DIM}→ $1${RESET}"; }
show_cmd() { echo -e "    ${DIM}${BOLD}\$${RESET} ${YELLOW}$1${RESET}"; }
ctx() {
  # Párrafo de contexto (evaluación / por qué / cómo se comprueba)
  echo -e "  ${DIM}$1${RESET}"
}
ctx_blank() { echo; echo; }

show_last_result() {
  case "$LAST_RESULT_KIND" in
    success)
      echo -e "  ${GREEN}${BOLD}✅ Último resultado: éxito${RESET}"
      echo -e "  ${GREEN}${LAST_RESULT_TEXT}${RESET}"
      ;;
    error)
      echo -e "  ${RED}${BOLD}❌ Último resultado: error${RESET}"
      echo -e "  ${RED}${LAST_RESULT_TEXT}${RESET}"
      ;;
    warning)
      echo -e "  ${YELLOW}${BOLD}⚠ Último resultado: advertencia${RESET}"
      echo -e "  ${YELLOW}${LAST_RESULT_TEXT}${RESET}"
      ;;
    *)
      echo -e "  ${CYAN}${BOLD}ℹ Último resultado${RESET}"
      echo -e "  ${CYAN}${LAST_RESULT_TEXT}${RESET}"
      ;;
  esac
  echo -e "  ${DIM}Comprobaciones acumuladas: OK=$PASS_COUNT · Error=$FAIL_COUNT · Avisos=$WARN_COUNT${RESET}"
  echo
}

redraw_after_continue() {
  header
  show_last_result
}

pause() {
  echo
  read -r -p "$(echo -e "${CYAN}Pulsa Enter para continuar…${RESET}")"
  redraw_after_continue
}

ask_yes_no() {
  # $1 = clave RESULT  $2 = pregunta de la hoja
  # Respuesta: s = sí (Yes en la hoja) · n = no · k = omitir (skip)
  # Enter = sí (por defecto, como en start.sh)
  local key="$1"
  local prompt="$2"
  local ans
  echo
  echo -e "  ${BOLD}${prompt}${RESET}"
  while true; do
    read -r -p "  ${GREEN}s${RESET}/${RED}n${RESET}  (${YELLOW}k${RESET}=omitir) → " ans
    case "${ans:-s}" in
      s|S|y|Y|yes|Yes|YES|sí|Sí|SI|si)
        RESULT["$key"]="yes"
        ok "Marcado SÍ (Yes) en la hoja de evaluación"
        return 0
        ;;
      n|N|no|No|NO)
        RESULT["$key"]="no"
        fail "Marcado NO en la hoja de evaluación"
        return 1
        ;;
      k|K|skip|Skip)
        RESULT["$key"]="skip"
        warn "Omitido por el evaluador"
        return 2
        ;;
      *)
        echo -e "    ${YELLOW}Responde s (sí), n (no) o k (omitir)${RESET}"
        ;;
    esac
  done
}


# ============================================================================
# HELPERS: ejecución de scripts (auto o manual)
# ============================================================================

find_pg_container() {
  docker ps --format '{{.Names}}' 2>/dev/null | grep -iE 'postgres|piscine' | head -1 || true
}

pg_login() {
  echo "$(whoami)"
}

offer_run_choice() {
  # $1 = título corto → RUN_CHOICE: auto | manual | skip
  local title="$1"
  local ans
  RUN_CHOICE="manual"
  echo
  echo -e "  ${BOLD}${title}${RESET}"
  echo -e "  ${GREEN}a${RESET}) Automático: evaluation.sh intenta lanzarlo ahora"
  echo -e "  ${CYAN}m${RESET}) Manual: se muestran los comandos exactos; el evaluado (o tú) los ejecuta"
  echo -e "  ${YELLOW}s${RESET}) Saltar: no ejecutar; solo ficheros / s-n después"
  while true; do
    read -r -p "  → " ans
    case "${ans:-m}" in
      a|A) RUN_CHOICE="auto"; return 0 ;;
      m|M|"") RUN_CHOICE="manual"; return 0 ;;
      s|S) RUN_CHOICE="skip"; return 0 ;;
      *) echo -e "    ${YELLOW}Elige a, m o s${RESET}" ;;
    esac
  done
}

show_manual_sql() {
  # $1 path del .sql
  local f="$1"
  local cname base login
  cname=$(find_pg_container)
  cname="${cname:-postgres_piscineds}"
  base="$(basename "$f")"
  login="$(pg_login)"
  echo
  echo -e "  ${BOLD}Modo MANUAL – SQL (copia cada comando en otra terminal)${RESET}"
  echo
  note "Paso 1 – Contenedor en marcha:"
  show_cmd "docker ps"
  show_cmd "cd ex00 && docker-compose up -d   # si no está Up"
  echo
  note "Paso 2 – Copiar el script al contenedor:"
  show_cmd "docker cp \"$f\" $cname:/tmp/$base"
  echo
  note "Paso 3 – Ejecutar el SQL (usuario = login del sistema: $login):"
  show_cmd "docker exec -it $cname psql -U $login -d piscineds -f /tmp/$base"
  echo
  note "Alternativa si tienes psql en el host:"
  show_cmd "psql -U $login -d piscineds -h localhost -W -f \"$f\""
  note "Password de la hoja de evaluación: mysecretpassword"
  echo
  note "Paso 4 – Comprobar resultado:"
  show_cmd "docker exec -it $cname psql -U $login -d piscineds -c '\\dt'"
  show_cmd "docker exec -it $cname psql -U $login -d piscineds -c '\\d nombre_de_la_tabla'"
  note "O pgAdmin en el navegador: http://localhost:5050"
}

show_manual_python() {
  local f="$1"
  local extra="${2:-}"
  local dir base login
  dir="$(dirname "$f")"
  base="$(basename "$f")"
  login="$(pg_login)"
  echo
  echo -e "  ${BOLD}Modo MANUAL – Python (copia cada comando en otra terminal)${RESET}"
  echo
  note "Paso 1 – Postgres up y credenciales:"
  show_cmd "docker ps"
  show_cmd "cat ex00/.env   # POSTGRES_USER / PASSWORD / DB"
  note "Usuario típico = login del sistema ($login); password hoja: mysecretpassword"
  echo
  note "Paso 2 – Ejecutar el script desde su carpeta:"
  show_cmd "cd $dir"
  if [[ -n "$extra" ]]; then
    show_cmd "python3 $base $extra"
    note "Si no encuentra los CSV, el argumento es la carpeta de datos: $extra"
  else
    show_cmd "python3 $base"
  fi
  echo
  note "Paso 3 – Comprobar tablas:"
  show_cmd "docker exec -it postgres_piscineds psql -U $login -d piscineds -c '\\dt'"
  note "O pgAdmin: http://localhost:5050"
}

try_run_sql() {
  local f="$1"
  local cname
  cname=$(find_pg_container)
  if [[ -z "$cname" ]]; then
    fail "No hay contenedor Postgres en docker ps – no se puede lanzar solo"
    show_manual_sql "$f"
    return 1
  fi
  show_cmd "docker cp \"$f\" $cname:/tmp/$(basename "$f")"
  info "Copiando $(basename "$f") → $cname:/tmp/"
  if ! docker cp "$f" "$cname:/tmp/$(basename "$f")" 2>/dev/null; then
    warn "docker cp falló (permisos Lchown a veces dan warning pero el fichero puede estar)"
  fi
  show_cmd "docker exec -it $cname psql -U $(pg_login) -d piscineds -f /tmp/$(basename "$f")"
  info "Ejecutando psql -f /tmp/$(basename "$f") …"
  if docker exec -e PGPASSWORD=mysecretpassword "$cname" \
      psql -U "$(pg_login)" -d piscineds -v ON_ERROR_STOP=1 -f "/tmp/$(basename "$f")" 2>&1 | tail -30 | sed 's/^/      /'; then
    ok "psql terminó (revisa arriba si hubo ERROR)"
    return 0
  else
    warn "psql devolvió error – prueba manual o revisa usuario/contraseña"
    show_manual_sql "$f"
    return 1
  fi
}

try_run_python() {
  local f="$1"
  shift
  local args=("$@")
  show_cmd "cd $(dirname "$f") && python3 $(basename "$f") ${args[*]:-}"
  info "Ejecutando: python3 $f ${args[*]:-}"
  if ( cd "$(dirname "$f")" && python3 "$(basename "$f")" "${args[@]}" ); then
    ok "Script Python terminó con código 0"
    return 0
  else
    warn "Script Python falló o pidió argumentos – modo manual:"
    show_manual_python "$f" "${args[*]:-}"
    return 1
  fi
}

wait_confirm() {
  local msg="${1:-Cuando hayáis terminado este paso (comandos de arriba o GUI)}"
  echo
  read -r -p "$(echo -e "${CYAN}${msg}. Enter para seguir…${RESET}")"
  redraw_after_continue
}

# ============================================================================
confirm_stop() {
  local reason="$1"
  echo
  echo -e "${RED}${BOLD}⚠ SEGÚN LA HOJA DE EVALUACIÓN: la evaluación debería PARAR aquí.${RESET}"
  echo -e "${RED}  Motivo: ${reason}${RESET}"
  read -r -p "  ¿Continuar igualmente solo para discutir? [s/N] → " ans
  if [[ "${ans:-}" =~ ^[sSyY] ]]; then
    warn "Continuáis por pedagogía (la nota oficial puede ser 0 en este punto)"
    return 0
  fi
  STOP_EVAL=true
  return 1
}

# ============================================================================
# 0. PREÁMBULO (Guidelines de la hoja de evaluación)
# ============================================================================
preamble() {
  section "0 · Guidelines (hoja de evaluación) – antes de tocar código"

  echo -e "  ${BOLD}Qué es este script${RESET}"
  ctx "evaluation.sh es solo una GUÍA de defensa (como un checklist hablado)."
  ctx "NO es un entregable del subject ni forma parte de la nota en Intra."
  ctx "Si este fichero menciona 'sleep infinity' o '--link', es para EXPLICAR la regla,"
  ctx "no porque el alumno los use. La hoja de evaluación solo juzga lo que hay en ex00–ex04 (y demos en vivo)."
  ctx_blank

  echo -e "  ${BOLD}Recordatorio para el evaluador (texto de la hoja de evaluación):${RESET}"
  note "Solo evaluar lo que está en el Git del estudiante"
  note "git clone en carpeta vacía; comprobar que el repo es el suyo"
  note "Revisar aliases maliciosos si algo huele raro"
  note "Ambos habéis leído scripts de ayuda (start.sh, evaluation.sh, …)"
  note "Si no has hecho el proyecto, lee el subject completo antes"
  note "Flags: empty / incomplete / cheat / crash / concern / forbidden"
  note "No editar ficheros del evaluado salvo config acordada"
  ctx_blank

  echo -e "  ${BOLD}Cómo usar esta guía${RESET}"
  info "En cada bloque verás: contexto → comando que puedes copiar → resultado → s/n"
  info "Tú decides la nota final en Intra; el script no 'aprueba' ni 'suspende' solo."
  show_cmd "./evaluation.sh   # desde la raíz del repo del evaluado"
  pause
}

# ============================================================================
# 1. GENERAL INSTRUCTIONS (Docker / structure)
# ============================================================================
check_structure() {
  section "1 · General instructions – estructura del repo"
  ctx "La hoja de evaluación pide que la configuración de la app esté en carpetas ex0* en la raíz del repo"
  ctx "(ex00, ex01, …). Así el evaluador encuentra docker-compose, scripts y entregas sin buscar."
  ctx_blank
  subsection "Carpetas ex0*"
  ctx "Comprobación interna: listar directorios ex0* en la raíz del clon."
  show_cmd "ls -la"
  show_cmd "ls -d ex0*"

  local found=0
  for d in ex00 ex01 ex02 ex03 ex04; do
    if [[ -d "$SCRIPT_DIR/$d" ]]; then
      ok "Existe $d/"
      ((found++)) || true
    else
      fail "Falta $d/"
    fi
  done
  if [[ $found -lt 5 ]]; then
    warn "La hoja de evaluación espera la configuración en carpetas ex0* en la raíz del repo"
  fi
}

check_subject_data() {
  section "1a · Datos del subject – CSV necesarios para la evaluación"
  ctx "Después de clonar el repositorio preparado para la evaluación, descarga el archivo comprimido subject y descomprímelo en esta raíz."
  ctx "La carpeta subject/ debe quedar junto a ex00/, ex01/, ex02/, ex03/ y ex04/; no dentro de ningún ejercicio."
  show_cmd "unzip /ruta/a/subject.zip -d \"$SCRIPT_DIR\""
  ctx "Estos CSV son necesarios para cargar y comprobar EX02 y EX04. EX03 usa además el eval.zip de Attachments de Intra."
  ctx_blank

  local subject_dir="$SCRIPT_DIR/subject"
  local customer_dir="$subject_dir/customer"
  local item_csv="$subject_dir/item/item.csv"
  local csv_count=0

  subsection "Ubicación de subject/"
  if [[ -d "$subject_dir" ]]; then
    ok "Encontrado: $subject_dir"
  else
    fail "No se encontró subject/ junto a ex00/…/ex04"
    note "Descarga el comprimido subject y descomprímelo en la raíz del repositorio clonado antes de continuar"
    RESULT["subject"]="no"
    return 0
  fi

  subsection "CSV disponibles"
  if [[ -d "$customer_dir" ]]; then
    local customer_count
    customer_count=$(find "$customer_dir" -maxdepth 1 -type f -name '*.csv' 2>/dev/null | wc -l | tr -d ' ')
    csv_count=$((csv_count + customer_count))
    ok "customer/: $customer_count CSV"
    find "$customer_dir" -maxdepth 1 -type f -name '*.csv' -printf '      %f\n' 2>/dev/null | sort
  else
    fail "Falta subject/customer/ (CSV de EX02/EX03)"
  fi

  if [[ -f "$item_csv" ]]; then
    ((csv_count++)) || true
    ok "Encontrado subject/item/item.csv"
  else
    fail "Falta subject/item/item.csv (CSV de EX04)"
  fi

  if [[ "$csv_count" -gt 0 && -d "$customer_dir" && -f "$item_csv" ]]; then
    RESULT["subject"]="yes"
    ok "subject/ está preparado para la evaluación ($csv_count CSV contabilizados)"
  else
    RESULT["subject"]="no"
    fail "subject/ está incompleto: no se puede garantizar la carga de los datos"
  fi
}

check_existing_runtime() {
  section "1b · Preflight del entorno Docker"
  ctx "Antes de la evaluación real se comprueba si ya hay contenedores del proyecto y si la BD contiene tablas o datos de una ejecución anterior."
  ctx "La limpieza nunca es automática: primero se muestran las consultas y el comando de eliminación, y solo se ejecuta con confirmación explícita."
  ctx_blank

  if ! command -v docker >/dev/null 2>&1; then
    warn "docker no está disponible; no se puede inspeccionar el entorno"
    return 0
  fi

  subsection "Contenedores existentes"
  show_cmd "docker ps -a --format 'table {{.Names}}\\t{{.Status}}\\t{{.Image}}'"
  local containers
  containers="$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -iE 'postgres|piscine' || true)"
  if [[ -z "$containers" ]]; then
    ok "No se encontraron contenedores Postgres/piscine existentes"
    return 0
  fi
  echo "$containers" | sed 's/^/      /'

  local has_data=false cname login
  login="$(pg_login)"
  while IFS= read -r cname; do
    [[ -n "$cname" ]] || continue
    subsection "Consulta de datos: $cname"
    if ! docker inspect -f '{{.State.Running}}' "$cname" 2>/dev/null | grep -q '^true$'; then
      info "$cname está detenido; no se puede consultar PostgreSQL sin arrancarlo"
      continue
    fi
    show_cmd "docker exec \"$cname\" psql -U $login -d piscineds -Atc \"SELECT count(*) FROM pg_tables WHERE schemaname = 'public'; SELECT coalesce(sum(n_live_tup), 0) FROM pg_stat_user_tables;\""
    local db_probe
    db_probe="$(
      docker exec "$cname" psql -U "$login" -d piscineds -Atc \
        "SELECT count(*) FROM pg_tables WHERE schemaname = 'public'; SELECT coalesce(sum(n_live_tup), 0) FROM pg_stat_user_tables;" \
        2>/dev/null || true
    )"
    if [[ -n "$db_probe" ]]; then
      echo "$db_probe" | sed 's/^/      /'
      if echo "$db_probe" | awk 'NF && $1 > 0 { found=1 } END { exit(found ? 0 : 1) }'; then
        has_data=true
        warn "$cname parece contener tablas o datos de una ejecución anterior"
      else
        ok "$cname responde y no muestra tablas/datos de usuario"
      fi
    else
      warn "No se pudo consultar piscineds en $cname (usuario o BD distintos)"
    fi
  done <<< "$containers"

  if [[ "$has_data" != true ]]; then
    return 0
  fi

  subsection "Propuesta de limpieza"
  local compose_file="" compose_bin=""
  for compose_file in "$SCRIPT_DIR/ex00/docker-compose.yml" \
                      "$SCRIPT_DIR/ex00/docker-compose.yaml" \
                      "$SCRIPT_DIR/docker-compose.yml"; do
    [[ -f "$compose_file" ]] && break
    compose_file=""
  done
  if [[ -z "$compose_file" ]]; then
    warn "Hay datos previos, pero no se encontró docker-compose.yml para proponer una limpieza segura"
    return 0
  fi
  if docker compose version >/dev/null 2>&1; then
    compose_bin="docker compose"
  elif command -v docker-compose >/dev/null 2>&1; then
    compose_bin="docker-compose"
  else
    warn "Hay datos previos, pero no se encontró Docker Compose para limpiarlos"
    return 0
  fi

  local compose_dir
  compose_dir="$(dirname "$compose_file")"
  show_cmd "cd \"$compose_dir\" && $compose_bin down -v"
  echo -e "  ${YELLOW}${BOLD}Esto detendrá y eliminará los contenedores y volúmenes del Compose, incluidos los datos cargados.${RESET}"
  read -r -p "  ¿Quieres eliminar este entorno antes de iniciar la evaluación? [s/N] → " answer
  if [[ ! "${answer:-}" =~ ^[sSyY]$ ]]; then
    info "No se eliminó nada; la evaluación continuará con el entorno existente"
    return 0
  fi

  info "Ejecutando la limpieza confirmada…"
  if (cd "$compose_dir" && $compose_bin down -v); then
    ok "Entorno Docker eliminado; la evaluación podrá empezar desde cero"
  else
    fail "No se pudo completar la limpieza de Docker"
  fi
}

check_pgadmin_runtime() {
  section "1c · Preflight de pgAdmin"
  ctx "EX01 requiere mostrar la base de datos mediante una interfaz gráfica durante la evaluación."
  ctx "Se comprobará pgAdmin en http://localhost:5050. Si no responde, podrás arrancarlo sin cerrar esta terminal."
  ctx_blank

  local pgadmin_dir="$HOME/sgoinfre/pgadmin4"
  local pgadmin_exec="$pgadmin_dir/venv/bin/pgadmin4"
  local pgadmin_config="$pgadmin_dir/config"
  local pgadmin_url="http://localhost:5050"
  local http_code=""

  subsection "Comprobar respuesta HTTP"
  show_cmd "curl -s -o /dev/null -w '%{http_code}\\n' $pgadmin_url"
  if ! command -v curl >/dev/null 2>&1; then
    warn "curl no está disponible; no se puede comprobar pgAdmin automáticamente"
    note "Siguiente paso: abre pgAdmin manualmente y confirma que puedes acceder a $pgadmin_url"
    RESULT["pgadmin"]="unknown"
    return 0
  fi

  http_code="$(curl -s -o /dev/null -w '%{http_code}' "$pgadmin_url" 2>/dev/null || true)"
  if [[ "$http_code" == "200" || "$http_code" == "302" ]]; then
    ok "pgAdmin está respondiendo en $pgadmin_url (HTTP $http_code)"
    RESULT["pgadmin"]="yes"
    note "Siguiente paso: mantén pgAdmin abierto y prepara la conexión a localhost:5432 / piscineds para EX01"
    return 0
  fi
  warn "pgAdmin no está respondiendo en $pgadmin_url (HTTP ${http_code:-sin respuesta})"

  subsection "Comprobar instalación local"
  show_cmd "ls -ld \"$pgadmin_dir\" \"$pgadmin_exec\" \"$pgadmin_config\""
  if [[ ! -x "$pgadmin_exec" || ! -d "$pgadmin_config" ]]; then
    fail "No se encuentra una instalación ejecutable/configurada de pgAdmin"
    note "Siguiente paso: instala pgAdmin con: cd ex01 && ./install.sh"
    note "Después vuelve a ejecutar evaluation.sh o arráncalo con: cd ex01 && ./start.sh"
    RESULT["pgadmin"]="no"
    return 0
  fi
  ok "Instalación local de pgAdmin encontrada"

  echo
  echo -e "  ${YELLOW}${BOLD}pgAdmin es necesario para demostrar EX01 y revisar visualmente las tablas.${RESET}"
  echo -e "  ${YELLOW}Se puede arrancar ahora en segundo plano y después comprobar su respuesta HTTP.${RESET}"
  echo
  show_cmd "PYTHONPATH=\"$pgadmin_config:\${PYTHONPATH:-}\" \"$pgadmin_exec\" >/tmp/pgadmin4-evaluation.log 2>&1 &"
  read -r -p "  ¿Quieres arrancar pgAdmin ahora? [s/N] → " answer
  if [[ ! "${answer:-}" =~ ^[sSyY]$ ]]; then
    warn "Arranque de pgAdmin cancelado"
    note "Siguiente paso: inicia pgAdmin manualmente y abre $pgadmin_url antes de EX01"
    RESULT["pgadmin"]="no"
    return 0
  fi

  info "Ejecutando el comando de arranque de pgAdmin…"
  PYTHONPATH="$pgadmin_config:${PYTHONPATH:-}" "$pgadmin_exec" \
    >/tmp/pgadmin4-evaluation.log 2>&1 &
  local pgadmin_pid=$!
  info "Proceso iniciado con PID $pgadmin_pid"

  local attempt=0
  while [[ $attempt -lt 20 ]]; do
    sleep 1
    http_code="$(curl -s -o /dev/null -w '%{http_code}' "$pgadmin_url" 2>/dev/null || true)"
    attempt=$((attempt + 1))
    if [[ "$http_code" == "200" || "$http_code" == "302" ]]; then
      ok "pgAdmin se ha iniciado correctamente (HTTP $http_code)"
      RESULT["pgadmin"]="yes"
      note "Siguiente paso: abre $pgadmin_url y conecta EX01 a localhost:5432 / piscineds"
      return 0
    fi
  done

  fail "pgAdmin no respondió después de 20 segundos (HTTP ${http_code:-sin respuesta})"
  note "Consulta el registro con: tail -n 40 /tmp/pgadmin4-evaluation.log"
  note "Siguiente paso: corrige el problema y abre $pgadmin_url antes de continuar con EX01"
  RESULT["pgadmin"]="no"
}

check_docker_compose_rules() {
  section "1b · docker-compose.yml (reglas que CIERRAN la evaluación)"
  ctx "Docker Compose describe servicios (p. ej. PostgreSQL) en un YAML."
  ctx "La hoja de evaluación prohíbe atajos de red peligrosos o anticuados:"
  ctx "  • network: host / network_mode: host  → el contenedor usa la red del host (mala práctica aquí)"
  ctx "  • links:  y  docker --link  → forma antigua de enlazar contenedores; debe usarse networks"
  ctx "Si aparecen, la hoja de evaluación dice que la evaluación TERMINA. Puedes continuar solo para discutir."
  ctx_blank
  ctx "Comprobación interna: buscar esas cadenas en el compose y en scripts de ex0*."
  show_cmd "grep -nE 'network:.*host|network_mode:|links:|--link' ex00/docker-compose.yml"
  show_cmd "grep -RInE -- '--link' ex00 ex01 ex02 ex03 ex04 --include='*.sh' --include='*.yml'"
  ctx_blank

  local compose=""
  # Buscar compose en ex00 (habitual) o raíz
  for c in "$SCRIPT_DIR/ex00/docker-compose.yml" \
           "$SCRIPT_DIR/ex00/docker-compose.yaml" \
           "$SCRIPT_DIR/docker-compose.yml"; do
    if [[ -f "$c" ]]; then
      compose="$c"
      break
    fi
  done

  if [[ -z "$compose" ]]; then
    warn "No se encontró docker-compose.yml (¿PostgreSQL nativo sin Docker?)"
    info "Si usa Postgres en máquina/VM sin Docker, las reglas Docker no aplican igual"
    return 0
  fi

  ok "Compose encontrado: $compose"
  local content
  content=$(cat "$compose")

  subsection "Prohibido: network: host / links:"
  if echo "$content" | grep -qiE 'network:\s*host|network_mode:\s*host'; then
    fail "Aparece network host → según la hoja de evaluación, la evaluación TERMINA"
    confirm_stop "network: host en docker-compose" || return 1
  else
    ok "No hay network: host"
  fi
  if echo "$content" | grep -qiE '^\s*links:'; then
    fail "Aparece links: → según la hoja de evaluación, la evaluación TERMINA"
    confirm_stop "links: en docker-compose" || return 1
  else
    ok "No hay links:"
  fi

  subsection "Obligatorio: network(s)"
  if echo "$content" | grep -qiE 'networks:'; then
    ok "Hay sección networks: (o referencia a networks)"
  else
    # Compose moderno crea red por defecto; la hoja de evaluación exige la palabra networks
    if echo "$content" | grep -qiE 'network'; then
      warn "Hay 'network' pero revisa si cumple el espíritu de la hoja de evaluación"
    else
      fail "No se ve 'networks' → según la hoja de evaluación, la evaluación TERMINA"
      confirm_stop "falta networks en docker-compose" || return 1
    fi
  fi

  subsection "Scripts / Makefile: sin --link (docker --link)"
  # Solo entregables ex0*. evaluation.sh no cuenta para la nota.
  local link_hits="" scan_dirs=() d
  for d in ex00 ex01 ex02 ex03 ex04; do
    [[ -d "$SCRIPT_DIR/$d" ]] && scan_dirs+=("$SCRIPT_DIR/$d")
  done
  if [[ ${#scan_dirs[@]} -gt 0 ]]; then
    link_hits="$(
      grep -RIn --include='*.sh' --include='Makefile' --include='*.yml' --include='*.yaml' \
        -E -- '(^|[[:space:]])--link(=|[[:space:]]|$)' \
        "${scan_dirs[@]}" 2>/dev/null || true
    )"
  fi
  if [[ -n "${link_hits}" ]]; then
    echo "$link_hits" | head -8 | sed 's/^/      /'
    fail "Se encontró docker --link en un entregable → según la hoja de evaluación, la evaluación TERMINA"
    confirm_stop "--link en scripts/Makefile/compose del proyecto" || return 1
  else
    ok "No hay docker --link en ex00–ex04"
    info "Nota: evaluation.sh no es parte del proyecto a evaluar; solo ayuda en la defensa."
  fi
}

check_dockerfile_rules() {
  section "1c · Dockerfiles / ENTRYPOINT / bucles infinitos"
  ctx "ENTRYPOINT es la orden principal que arranca cuando nace el contenedor (el 'programa por defecto')."
  ctx "La hoja de evaluación no quiere contenedores 'vivos' con trucos tipo: tail -f /dev/null, sleep infinity,"
  ctx "ni procesos en background (&) que dejen el entrypoint colgado a propósito."
  ctx "Motivo: en defensa el servicio debe ser el real (postgres, etc.), no un contenedor vacío eterno."
  ctx_blank
  ctx "Usar la imagen oficial postgres:15 (sin Dockerfile propio) es HABITUAL y está bien:"
  ctx "no hace falta un Dockerfile si solo levantas Postgres con compose + image:."
  ctx_blank
  ctx "Comprobación interna (solo entregables ex0*, nunca evaluation.sh):"
  show_cmd "find ex00 ex01 ex02 ex03 ex04 -name 'Dockerfile*' 2>/dev/null"
  show_cmd "grep -RInE 'sleep[[:space:]]+infinity|tail[[:space:]]+-f[[:space:]]+/dev/null' ex00 ex01 ex02 ex03 ex04 --include='*.sh' 2>/dev/null"
  ctx_blank

  local dfs
  dfs=$(find "$SCRIPT_DIR" -type f \( -name 'Dockerfile*' -o -name '*.dockerfile' \) 2>/dev/null || true)
  if [[ -z "$dfs" ]]; then
    info "No hay Dockerfile propio (imagen oficial postgres:XX es habitual y OK)"
  else
    while IFS= read -r df; do
      subsection "$(basename "$df")"
      if grep -qiE 'tail\s+-f|sleep\s+infinity|/dev/null|/dev/random' "$df"; then
        fail "Posible proceso en background / bucle infinito en $df"
        confirm_stop "tail -f / sleep infinity en Dockerfile" || return 1
      else
        ok "Sin tail -f / sleep infinity obvio en $df"
      fi
      if grep -qiE 'ENTRYPOINT.*\bbash\b|ENTRYPOINT.*\bsh\b' "$df"; then
        warn "ENTRYPOINT usa bash/sh – verificar que no deje procesos en background"
        note "Hoja de evaluación: si ENTRYPOINT es script, no debe lanzar 'nginx & bash' ni similar"
      fi
    done <<< "$dfs"
  fi

  subsection "Scripts del repo: bucles infinitos prohibidos"
  # La hoja de evaluación prohíbe en los scripts DEL PROYECTO (ex00–ex04), no en evaluation.sh.
  # evaluation.sh es herramienta de defensa: sus menciones a "sleep infinity"
  # son documentación y NO puntúan ni deben cerrar la evaluación.
  #
  # Solo se escanean ex00 ex01 ex02 ex03 ex04 (entregables).
  local loop_hits="" scan_dirs=() d
  for d in ex00 ex01 ex02 ex03 ex04; do
    [[ -d "$SCRIPT_DIR/$d" ]] && scan_dirs+=("$SCRIPT_DIR/$d")
  done
  if [[ ${#scan_dirs[@]} -eq 0 ]]; then
    warn "No hay carpetas ex0* que escanear"
  else
    loop_hits="$(
      grep -RIn --include='*.sh' --include='Makefile' --include='Dockerfile*' \
        -E 'sleep[[:space:]]+infinity|tail[[:space:]]+-f[[:space:]]+/dev/null|tail[[:space:]]+-f[[:space:]]+/dev/random' \
        "${scan_dirs[@]}" 2>/dev/null || true
    )"
  fi
  if [[ -n "${loop_hits}" ]]; then
    echo "$loop_hits" | head -8 | sed 's/^/      /'
    fail "Comando tipo sleep infinity / tail -f /dev/null en un entregable ex0*"
    confirm_stop "bucle infinito en scripts del proyecto" || return 1
  else
    ok "No hay sleep infinity / tail -f /dev/null en ex00–ex04"
    info "Nota: evaluation.sh no es parte del proyecto a evaluar; solo ayuda en la defensa."
  fi
}

check_makefile() {
  section "1d · Makefile"
  ctx "La hoja de evaluación dice 'Run the Makefile' si existe. No es obligatorio tenerlo si todo se lanza"
  ctx "con docker-compose / start.sh; si hay Makefile, conviene ejecutarlo en defensa."
  ctx_blank
  show_cmd "find . -maxdepth 2 -name Makefile"
  ctx_blank
  if [[ -f "$SCRIPT_DIR/Makefile" ]] || [[ -f "$SCRIPT_DIR/ex00/Makefile" ]]; then
    ok "Hay Makefile – la hoja de evaluación dice: Run the Makefile"
    note "Ejecuta make en presencia del evaluado y comprueba que no rompe nada"
    local mf
    mf=$(find "$SCRIPT_DIR" -maxdepth 2 -name Makefile | head -1)
    info "Makefile: $mf"
  else
    info "No hay Makefile (aceptable si todo se lanza con docker-compose / scripts)"
  fi
}

# ============================================================================
# 2. EX00 – Create postgres
# ============================================================================
check_ex00() {
  section "2 · Ex00 – Create postgres"
  ctx "Objetivo: un PostgreSQL alcanzable con el login del alumno, BD piscineds y password de la hoja de evaluación."
  ctx "Puede ser Docker (compose) o Postgres instalado en la máquina; ambos valen según la hoja de evaluación."
  ctx_blank
  echo -e "  ${BOLD}Comando de referencia (hoja de evaluación):${RESET}"
  show_cmd "psql -U \$(whoami) -d piscineds -h localhost -W"
  ctx "Password esperado en la hoja de evaluación: mysecretpassword"
  ctx_blank

  subsection "Ficheros / Docker"
  if [[ -f "$SCRIPT_DIR/ex00/docker-compose.yml" ]] || [[ -f "$SCRIPT_DIR/ex00/docker-compose.yaml" ]]; then
    ok "docker-compose en ex00/"
  else
    warn "Sin docker-compose en ex00/ (¿Postgres nativo?)"
  fi

  subsection "¿Contenedor en marcha?"
  ctx "Si usa Docker, debe verse un contenedor (nombre tipo postgres_piscineds) con puerto 5432."
  ctx "Comprobación interna:"
  if command -v docker >/dev/null 2>&1; then
    show_cmd "docker ps"
    show_cmd "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
    if docker ps --format '{{.Names}}' 2>/dev/null | grep -qiE 'postgres|piscine'; then
      ok "Hay contenedor Postgres/piscine en docker ps"
      docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' 2>/dev/null | head -6 | sed 's/^/      /'
    else
      warn "No se ve contenedor postgres en docker ps"
      note "El evaluado debe levantar:"
      show_cmd "cd ex00 && docker-compose up -d"
      note "(o ./start.sh del ex00)"
    fi
  else
    warn "docker no disponible en este host"
  fi

  subsection "Prueba de conexión (opcional, no rompe si falla el cliente)"
  local login
  login="$(whoami)"
  if command -v psql >/dev/null 2>&1; then
    show_cmd "PGPASSWORD=mysecretpassword psql -U $login -d piscineds -h localhost -c 'SELECT 1 AS ok;'"
    if PGPASSWORD=mysecretpassword psql -U "$login" -d piscineds -h localhost -c 'SELECT 1 AS ok;' 2>/dev/null | grep -q ok; then
      ok "Conexión psql OK (user=$login db=piscineds host=localhost)"
    else
      warn "No se pudo conectar automáticamente – el evaluado debe demostrar la conexión"
      show_cmd "docker exec -it postgres_piscineds psql -U $login -d piscineds"
    fi
  else
    info "psql no está en el PATH del host – el evaluador puede probar:"
    show_cmd "docker exec -it postgres_piscineds psql -U $login -d piscineds"
    show_cmd "psql -U $login -d piscineds -h localhost -W   # password: mysecretpassword"
  fi

  ask_yes_no "ex00" "Ex00 Create postgres – ¿conexión con login + piscineds + mysecretpassword OK?"
}

# ============================================================================
# 3. EX01 – Show me your DB  (si falla → STOP)
# ============================================================================
check_ex01() {
  [[ "$STOP_EVAL" == true ]] && return 1
  section "3 · Ex01 – Show me your DB"
  ctx "Hay que VER la conexión (pgAdmin, DBeaver, etc.) al mismo host/puerto que Ex00."
  ctx "No basta con capturas en el repo: la hoja de evaluación dice 'ask to be shown' y, si falla, PARA aquí."
  ctx_blank
  note "Puerto típico: 5432 (el mismo que publicaste en docker-compose)."
  echo -e "  ${RED}${BOLD}Si la conexión GUI no funciona → la evaluación SE PARA aquí.${RESET}"
  ctx_blank

  subsection "Evidencias en el repo"
  if [[ -d "$SCRIPT_DIR/ex01" ]]; then
    ok "Carpeta ex01/ presente"
  else
    fail "Falta ex01/"
  fi
  if ls "$SCRIPT_DIR/ex01"/*.[pP][nN][gG] "$SCRIPT_DIR/ex01"/imgs/* 2>/dev/null | head -1 >/dev/null; then
    ok "Hay capturas / imgs en ex01 (útil en defensa)"
  else
    info "Sin capturas en repo – el estudiante debe mostrar pgAdmin (u otra GUI) en vivo"
  fi

  subsection "Puerto 5432 (mismo que Ex00)"
  if command -v docker >/dev/null 2>&1; then
    show_cmd "docker ps"
    show_cmd "docker ps --format '{{.Names}} {{.Ports}}' | grep 5432"
    if docker ps 2>/dev/null | grep -E '0\.0\.0\.0:5432|->5432'; then
      ok "Puerto 5432 publicado en docker ps"
    else
      warn "No se ve mapeo 5432 en docker ps – verificar con el evaluado"
    fi
  fi

  echo
  info "Pide al estudiante: abrir pgAdmin / DBeaver /… y conectar a localhost:5432, BD piscineds"
  ask_yes_no "ex01" "Ex01 Show me your DB – ¿conexión GUI al mismo puerto OK?"
  if [[ "${RESULT[ex01]:-}" == "no" ]]; then
    confirm_stop "Ex01: conexión a la BD no funciona" || return 1
  fi
}

# ============================================================================
# 4. EX02 – First table
# ============================================================================
check_ex02() {
  [[ "$STOP_EVAL" == true ]] && return 1
  section "4 · Ex02 – First table"
  ctx "Se ejecuta table.* (sql o py), se crea una tabla y se comprueba en la GUI/psql de Ex01."
  ctx "Columnas = CSV de customer; ≥ 6 tipos SQL distintos; event_time = fecha/hora (TIMESTAMP)."
  ctx_blank
  note "Columnas: event_time, event_type, product_id, price, user_id, user_session"
  ctx_blank

  subsection "Entrega table.*"
  local table_file=""
  for f in "$SCRIPT_DIR/ex02"/table.sql "$SCRIPT_DIR/ex02"/table.py "$SCRIPT_DIR/ex02"/table.*; do
    [[ -f "$f" ]] || continue
    table_file="$f"
    break
  done
  if [[ -n "$table_file" ]]; then
    ok "Encontrado: $table_file"
  else
    fail "No se encontró table.* en ex02/"
  fi

  if [[ -n "$table_file" && "$table_file" == *.sql ]]; then
    subsection "Columnas en el SQL"
    local sqlc
    sqlc=$(cat "$table_file")
    for col in event_time event_type product_id price user_id user_session; do
      if echo "$sqlc" | grep -qiE "\b${col}\b"; then
        ok "Columna $col presente en el script"
      else
        fail "Columna $col no vista en el script"
      fi
    done
    if echo "$sqlc" | grep -qiE 'event_time.*(TIMESTAMP|TIMESTAMPTZ|DATETIME|DATE)'; then
      ok "event_time con tipo fecha/hora (TIMESTAMP/…)"
    elif echo "$sqlc" | grep -qiE '(TIMESTAMP|TIMESTAMPTZ).*event_time'; then
      ok "event_time asociado a TIMESTAMP"
    else
      warn "Revisa a mano que event_time sea DATETIME/TIMESTAMP"
    fi
  fi

  subsection "Comprobación en BD (si está up)"
  local login
  login="$(whoami)"
  if command -v docker >/dev/null 2>&1; then
    local cname
    cname=$(docker ps --format '{{.Names}}' 2>/dev/null | grep -iE 'postgres|piscine' | head -1 || true)
    if [[ -n "$cname" ]]; then
      note "Contenedor: $cname – listando tablas public.*"
      show_cmd "docker exec -it $cname psql -U $login -d piscineds -c '\\dt'"
      docker exec "$cname" psql -U "$login" -d piscineds -c '\dt' 2>/dev/null | sed 's/^/      /' || \
        warn "No se pudo \dt (¿usuario distinto del login?)"
    fi
  fi

  subsection "Ejecutar table.* (hoja: Run table.*)"
  if [[ -z "$table_file" ]]; then
    warn "Sin fichero: no hay nada que lanzar"
  else
    offer_run_choice "¿Cómo ejecutamos table.*?"
    case "$RUN_CHOICE" in
      auto)
        if [[ "$table_file" == *.sql ]]; then
          try_run_sql "$table_file" || true
        else
          try_run_python "$table_file" || true
        fi
        wait_confirm "Revisa en pgAdmin/psql la tabla (\\d y SELECT)"
        ;;
      manual)
        if [[ "$table_file" == *.sql ]]; then
          show_manual_sql "$table_file"
        else
          show_manual_python "$table_file"
        fi
        wait_confirm "Cuando el evaluado haya ejecutado table.* y lo hayáis comprobado"
        ;;
      skip)
        info "Ejecución omitida – valoraréis solo con lo ya existente en la BD"
        ;;
    esac
  fi

  echo
  info "Hoja de evaluación: ≥6 tipos, columnas del CSV, event_time = DATETIME"
  ask_yes_no "ex02" "Ex02 First table – ¿tabla creada, ≥6 tipos, columnas CSV, event_time DATETIME?"
}

# ============================================================================
# 5. EX03 – automatic table  (eval.zip)
# ============================================================================
check_ex03() {
  [[ "$STOP_EVAL" == true ]] && return 1
  section "5 · Ex03 – automatic table"
  ctx "El script debe descubrir CSV y crear una tabla por fichero (nombre = archivo sin .csv)."
  ctx "OBLIGATORIO en defensa: datos de eval.zip (Attachments de Intra), no solo los CSV del subject."
  ctx "Deben existir 5 tablas; la hoja de evaluación insiste en data_2023_feb. Mismos tipos/columnas que Ex02."
  ctx_blank
  note "Nombres típicos: data_2022_oct, data_2022_nov, data_2022_dec, data_2023_*, data_2023_feb"
  ctx_blank

  subsection "Entrega automatic_table.*"
  local auto=""
  for f in "$SCRIPT_DIR/ex03"/automatic_table.py \
           "$SCRIPT_DIR/ex03"/automatic_table.sql \
           "$SCRIPT_DIR/ex03"/automatic_table.*; do
    [[ -f "$f" ]] || continue
    auto="$f"
    break
  done
  if [[ -n "$auto" ]]; then
    ok "Encontrado: $auto"
  else
    fail "No se encontró automatic_table.* en ex03/"
  fi

  subsection "eval.zip"
  if [[ -f "$SCRIPT_DIR/eval.zip" ]] || [[ -f "$SCRIPT_DIR/ex03/eval.zip" ]]; then
    ok "eval.zip presente en el árbol (o el evaluador lo aporta desde Intra)"
  else
    warn "eval.zip no está en el repo – debe descargarse de Attachments en Intra"
    note "https://cdn.intra.42.fr/document/document/…/eval.zip"
  fi

  subsection "Nombres de tablas esperados"
  info "Tras correr el script con eval.zip, verificar en psql/pgAdmin:"
  note "data_2022_oct | data_2022_nov | data_2022_dec | data_2023_* | data_2023_feb"
  if command -v docker >/dev/null 2>&1; then
    local cname login
    login="$(whoami)"
    cname=$(docker ps --format '{{.Names}}' 2>/dev/null | grep -iE 'postgres|piscine' | head -1 || true)
    if [[ -n "$cname" ]]; then
      docker exec "$cname" psql -U "$login" -d piscineds -c \
        "SELECT tablename FROM pg_tables WHERE schemaname='public' AND tablename LIKE 'data_%' ORDER BY 1;" \
        2>/dev/null | sed 's/^/      /' || true
    fi
  fi

  subsection "eval.zip (OBLIGATORIO en la hoja de evaluación)"
  echo
  echo -e "  ${BOLD}La hoja de evaluación dice:${RESET} la evaluación de Ex03 debe hacerse con ${YELLOW}eval.zip${RESET}"
  echo -e "  ${DIM}Attachments de la página de evaluación en Intra (no viene en el subject del alumno).${RESET}"
  echo
  note "Pasos recomendados:"
  echo -e "     ${DIM}1. En Intra → evaluación DATA-SCIENCE-0 → descargar eval.zip${RESET}"
  echo -e "     ${DIM}2. Descomprimir en una carpeta temporal, p. ej.:${RESET}"
  echo -e "        ${DIM}mkdir -p /tmp/ds0_eval && unzip -o eval.zip -d /tmp/ds0_eval${RESET}"
  echo -e "     ${DIM}3. Dentro suele haber CSV (u otra estructura); localiza la carpeta con los .csv${RESET}"
  echo -e "     ${DIM}4. Pasa ESA carpeta a automatic_table.* (o copia los CSV donde el script los busque)${RESET}"
  echo
  local eval_dir=""
  read -r -p "  Ruta a la carpeta YA descomprimida de eval.zip (Enter = /tmp/ds0_eval o solo confirmar después): " eval_dir
  eval_dir="${eval_dir:-/tmp/ds0_eval}"
  if [[ -d "$eval_dir" ]]; then
    ok "Carpeta existe: $eval_dir"
    local ncsv
    ncsv=$(find "$eval_dir" -type f -name '*.csv' 2>/dev/null | wc -l | tr -d ' ')
    info "CSV encontrados bajo esa ruta: $ncsv"
    find "$eval_dir" -type f -name '*.csv' 2>/dev/null | head -10 | sed 's/^/      /'
  else
    warn "Aún no existe $eval_dir – el evaluado debe descargar y descomprimir eval.zip de Intra"
  fi
  wait_confirm "Cuando eval.zip esté descomprimido y sepáis la carpeta de los CSV"

  subsection "Ejecutar automatic_table.*"
  if [[ -z "$auto" ]]; then
    warn "Sin automatic_table.*: no hay nada que lanzar"
  else
    offer_run_choice "¿Cómo ejecutamos automatic_table.*?"
    case "$RUN_CHOICE" in
      auto)
        if [[ "$auto" == *.py ]]; then
          # Intentar con la carpeta de eval si tiene CSV; si no, sin args
          if [[ -d "$eval_dir" ]] && find "$eval_dir" -name '*.csv' 2>/dev/null | grep -q .; then
            try_run_python "$auto" "$eval_dir" || try_run_python "$auto" || true
          else
            warn "Sin CSV en eval_dir – lanzando sin argumentos (busca customer/ por defecto)"
            try_run_python "$auto" || true
          fi
        else
          try_run_sql "$auto" || true
        fi
        wait_confirm "Revisa las 5 tablas data_* (sobre todo data_2023_feb)"
        ;;
      manual)
        if [[ "$auto" == *.py ]]; then
          show_manual_python "$auto" "/ruta/a/carpeta_csv_de_eval"
          note "Ejemplo: python3 automatic_table.py $eval_dir"
        else
          show_manual_sql "$auto"
        fi
        wait_confirm "Cuando haya corrido automatic_table.* con los CSV de eval.zip"
        ;;
      skip)
        info "Ejecución omitida"
        ;;
    esac
  fi

  subsection "Resultado observado en la BD"
  if command -v docker >/dev/null 2>&1; then
    local cname login
    login="$(pg_login)"
    cname=$(find_pg_container)
    if [[ -n "$cname" ]]; then
      info "Tablas data_% actuales:"
      show_cmd "docker exec -it $cname psql -U $login -d piscineds -c \"SELECT tablename FROM pg_tables WHERE schemaname='public' AND tablename LIKE 'data_%' ORDER BY 1;\""
      docker exec "$cname" psql -U "$login" -d piscineds -c \
        "SELECT tablename FROM pg_tables WHERE schemaname='public' AND tablename LIKE 'data_%' ORDER BY 1;" \
        2>/dev/null | sed 's/^/      /' || true
    fi
  fi

  echo
  echo -e "  ${BOLD}Preguntas de valoración (Ex03)${RESET}"
  ask_yes_no "ex03_five" "¿Hay 5 tablas con los nombres esperados (oct, nov, dec, 2023…, data_2023_feb)?"
  ask_yes_no "ex03_types" "¿Mismas columnas que el CSV y event_time DATETIME en las 5?"
  ask_yes_no "ex03" "Ex03 automatic table – veredicto global (5 tablas + tipos/columnas OK)?"
}

# ============================================================================
# 6. EX04 – items table
# ============================================================================
check_ex04() {
  [[ "$STOP_EVAL" == true ]] && return 1
  section "6 · Ex04 – items table"
  ctx "Tabla de productos (item.csv): product_id, category_id, category_code, brand."
  ctx "≥ 3 tipos SQL distintos. Ejecutar item_table.* / items_table.* y ver el resultado en la GUI."
  ctx_blank

  subsection "Entrega"
  local item=""
  for f in "$SCRIPT_DIR/ex04"/items_table.sql \
           "$SCRIPT_DIR/ex04"/items_table.py \
           "$SCRIPT_DIR/ex04"/item_table.sql \
           "$SCRIPT_DIR/ex04"/item_table.py \
           "$SCRIPT_DIR/ex04"/item_table.* \
           "$SCRIPT_DIR/ex04"/items_table.*; do
    [[ -f "$f" ]] || continue
    item="$f"
    break
  done
  if [[ -n "$item" ]]; then
    ok "Encontrado: $item"
  else
    fail "No se encontró item_table.* / items_table.* en ex04/"
  fi

  if [[ -n "$item" ]]; then
    local content
    content=$(cat "$item")
    for col in product_id category_id category_code brand; do
      if echo "$content" | grep -qiE "\b${col}\b"; then
        ok "Columna $col en el script"
      else
        fail "Columna $col no vista"
      fi
    done
  fi

  if command -v docker >/dev/null 2>&1; then
    local cname login
    login="$(whoami)"
    cname=$(docker ps --format '{{.Names}}' 2>/dev/null | grep -iE 'postgres|piscine' | head -1 || true)
    if [[ -n "$cname" ]]; then
      note "\d items (si existe):"
      show_cmd "docker exec -it $cname psql -U $login -d piscineds -c '\\d items'"
      docker exec "$cname" psql -U "$login" -d piscineds -c '\d items' 2>/dev/null | sed 's/^/      /' || \
        warn "Tabla items aún no visible – el evaluado debe ejecutar el script"
    fi
  fi

  subsection "Ejecutar item(s)_table.* (hoja: Run item_table.*)"
  if [[ -z "$item" ]]; then
    warn "Sin fichero: no hay nada que lanzar"
  else
    offer_run_choice "¿Cómo ejecutamos item(s)_table.*?"
    case "$RUN_CHOICE" in
      auto)
        if [[ "$item" == *.sql ]]; then
          try_run_sql "$item" || true
        else
          # Python suele necesitar la ruta del CSV item
          local item_csv=""
          for c in "$SCRIPT_DIR/subject/item/item.csv" "$SCRIPT_DIR/../subject/item/item.csv"; do
            [[ -f "$c" ]] && item_csv="$c" && break
          done
          if [[ -n "$item_csv" ]]; then
            try_run_python "$item" "$item_csv" || try_run_python "$item" || true
          else
            try_run_python "$item" || true
          fi
        fi
        wait_confirm "Revisa la tabla items (\\d items)"
        ;;
      manual)
        if [[ "$item" == *.sql ]]; then
          show_manual_sql "$item"
        else
          show_manual_python "$item" "ruta/a/item.csv"
        fi
        wait_confirm "Cuando el evaluado haya ejecutado el script de items"
        ;;
      skip)
        info "Ejecución omitida"
        ;;
    esac
  fi

  echo
  ask_yes_no "ex04" "Ex04 items table – ¿tabla items con columnas del CSV y ≥3 tipos?"
}

# ============================================================================
# RESUMEN FINAL
# ============================================================================
summary() {
  section "7 · Resumen para Intra"
  ctx "Copia este resumen al comentario de Intra (máx 2048 caracteres) si te ayuda."
  ctx "evaluation.sh no sustituye tu juicio: s/n son ayudas, la nota la marcas tú."
  ctx_blank
  echo -e "  ${BOLD}Checklist hoja de evaluación${RESET}"
  echo -e "  ─────────────────────────────────────"
  printf "  %-12s %s\n" "subject/ CSV" "${RESULT[subject]:-—}"
  printf "  %-12s %s\n" "pgAdmin" "${RESULT[pgadmin]:-—}"
  printf "  %-12s %s\n" "Ex00" "${RESULT[ex00]:-—}"
  printf "  %-12s %s\n" "Ex01" "${RESULT[ex01]:-—}"
  printf "  %-12s %s\n" "Ex02" "${RESULT[ex02]:-—}"
  printf "  %-12s %s\n" "Ex03" "${RESULT[ex03]:-—}"
  printf "  %-12s %s\n" "  5 tablas" "${RESULT[ex03_five]:-—}"
  printf "  %-12s %s\n" "  tipos" "${RESULT[ex03_types]:-—}"
  printf "  %-12s %s\n" "Ex04" "${RESULT[ex04]:-—}"
  echo -e "  ─────────────────────────────────────"
  echo -e "  Comprobaciones auto: ${GREEN}OK≈$PASS_COUNT${RESET}  ${RED}Fail≈$FAIL_COUNT${RESET}  ${YELLOW}Warn≈$WARN_COUNT${RESET}"
  echo
  if [[ "$STOP_EVAL" == true ]]; then
    echo -e "  ${RED}${BOLD}Se marcó parada anticipada (Ex01 / reglas Docker).${RESET}"
  fi
  echo
  if [[ "${RESULT[subject]:-}" == "yes" \
        && "${RESULT[ex00]:-}" == "yes" \
        && "${RESULT[ex01]:-}" == "yes" \
        && "${RESULT[ex02]:-}" == "yes" \
        && "${RESULT[ex03]:-}" == "yes" \
        && "${RESULT[ex03_five]:-}" == "yes" \
        && "${RESULT[ex03_types]:-}" == "yes" \
        && "${RESULT[ex04]:-}" == "yes" \
        && "$STOP_EVAL" != true \
        && "$FAIL_COUNT" -eq 0 ]]; then
    echo -e "  ${GREEN}${BOLD}✅ RESULTADO FINAL: EVALUACIÓN SUPERADA${RESET}"
    echo -e "  ${GREEN}Todos los veredictos registrados son favorables y no hay fallos automáticos.${RESET}"
  else
    echo -e "  ${RED}${BOLD}❌ RESULTADO FINAL: EVALUACIÓN NO SUPERADA${RESET}"
    echo -e "  ${RED}Hay algún veredicto desfavorable, datos subject incompletos, una parada anticipada o fallos automáticos.${RESET}"
  fi
  echo -e "  ${DIM}Este resultado es orientativo; la decisión oficial corresponde al evaluador y a la hoja de evaluación.${RESET}"
  echo
  echo -e "  ${BOLD}Ratings (hoja de evaluación):${RESET} Ok · Outstanding · Empty · Incomplete · Cheat · Crash · Concern · Forbidden"
  echo
  echo -e "  ${DIM}Comentario Intra (máx 2048 chars): resume Yes/No y lo hablado en defensa.${RESET}"
  echo
  echo -e "${GREEN}${BOLD}Fin de la guía de evaluación. ¡Buenas defensas!${RESET}"
  echo
}

# ============================================================================
# MAIN
# ============================================================================
main() {
  header
  preamble
  [[ "$STOP_EVAL" == true ]] && summary && exit 0

  check_structure
  check_subject_data
  check_existing_runtime
  check_pgadmin_runtime
  check_docker_compose_rules || true
  [[ "$STOP_EVAL" == true ]] && summary && exit 0
  check_dockerfile_rules || true
  [[ "$STOP_EVAL" == true ]] && summary && exit 0
  check_makefile
  pause

  check_ex00
  pause
  check_ex01 || true
  [[ "$STOP_EVAL" == true ]] && summary && exit 0
  pause
  check_ex02
  pause
  check_ex03
  pause
  check_ex04
  summary
}

main "$@"
