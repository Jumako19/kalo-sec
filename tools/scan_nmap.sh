#!/bin/bash

# ==============================================================
#  KALO-SEC - Escaneo Localhost Limpio con Detección de OS
# ==============================================================

RESET="\033[0m"
BLUE="\033[34m"
YELLOW="\033[33m"
GREEN="\033[32m"

echo -e "${BLUE}== ESCANEO NMAP DEL LOCALHOST (CLEAN + OS DETECTION) ==${RESET}\n"

TARGET="127.0.0.1"

echo -e "${YELLOW}[+] Iniciando escaneo nmap...${RESET}"

sudo nmap \
    -p- \
    -sS \
    -O \
    -Pn \
    --open \
    --reason \
    -T4 \
    $TARGET

echo -e "\n${GREEN}[✔] Escaneo completado (modo limpio).${RESET}\n"
