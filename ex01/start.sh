#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

echo "==============================================================="
echo "       42 Data Science - pgAdmin" - sternero - 42 Málaga
echo "==============================================================="
echo
echo "Script: $SCRIPT_DIR/start.sh"
echo

echo "1. Comprobando Docker..."
echo

if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: Docker no está instalado."
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker no está funcionando."
    echo "Inicia Docker Desktop y vuelve a intentarlo."
    exit 1
fi

echo "OK: Docker operativo."
echo

echo "Contenedores activos:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo

read -p "¿Continuar con pgAdmin? (s/n): " RESP

if [[ ! "$RESP" =~ ^[sS]$ ]]; then
    echo "Operación cancelada."
    exit 0
fi

