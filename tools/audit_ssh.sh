#!/bin/bash

# ==============================================================
#  KALO-SEC - SSH HARDENING EXTREMO (CON AVISOS DE CAMBIOS)
# ==============================================================

RESET="\033[0m"
BLUE="\033[34m"
YELLOW="\033[33m"
GREEN="\033[32m"
RED="\033[31m"
CYAN="\033[36m"

CONFIG="/etc/ssh/sshd_config"
BACKUP="/etc/ssh/sshd_config.kalo-sec-backup"

echo -e "${BLUE}== KALO-SEC: BASTIONADO SSH (ANÁLISIS + CORRECCIÓN + AVISOS) ==${RESET}\n"

# --------------------------------------------------------------
# 0) COMPROBAR SSH
# --------------------------------------------------------------

if [[ ! -f "$CONFIG" ]]; then
    echo -e "${RED}[!] SSH no está instalado en este sistema.${RESET}"
    exit 1
fi

# --------------------------------------------------------------
# 1) BACKUP AUTOMÁTICO
# --------------------------------------------------------------

if [[ ! -f "$BACKUP" ]]; then
    cp "$CONFIG" "$BACKUP"
    echo -e "${YELLOW}[+] Backup creado en:${RESET} $BACKUP"
else
    echo -e "${GREEN}[✔] Backup ya existente.${RESET} ($BACKUP)"
fi

# --------------------------------------------------------------
# 2) FUNCIÓN PARA ANALIZAR + CORREGIR + AVISAR
# --------------------------------------------------------------

apply_fix() {
    PARAM="$1"
    VALUE="$2"
    DESCRIPTION="$3"

    CURRENT=$(grep -E "^\s*$PARAM" "$CONFIG" | awk '{print $2}')

    # Si no existe el parámetro, lo añadimos.
    if [[ -z "$CURRENT" ]]; then
        echo "$PARAM $VALUE" >> "$CONFIG"
        echo -e "${CYAN}[•] $DESCRIPTION:${RESET} No estaba configurado → ${GREEN}configurado a $VALUE${RESET}"
        return
    fi

    # Si el valor es distinto, corregir
    if [[ "$CURRENT" != "$VALUE" ]]; then
        sed -i "s|^\s*$PARAM.*|$PARAM $VALUE|g" "$CONFIG"
        echo -e "${RED}[✘] $DESCRIPTION:${RESET} Estaba en '$CURRENT' → ${GREEN}cambiado a '$VALUE'${RESET}"
    else
        echo -e "${GREEN}[✔] $DESCRIPTION:${RESET} Ya estaba configurado correctamente ($VALUE)"
    fi
}

# --------------------------------------------------------------
# 3) BASTIONADO CRÍTICO
# --------------------------------------------------------------

echo -e "\n${YELLOW}[+] Reforzando opciones críticas de seguridad...${RESET}"

apply_fix "PermitRootLogin" "no" "Bloqueo del acceso SSH como root"
apply_fix "PasswordAuthentication" "no" "Desactivar login con contraseña"
apply_fix "PubkeyAuthentication" "yes" "Autenticación segura por clave"
apply_fix "PermitEmptyPasswords" "no" "Prohibir contraseñas vacías"
apply_fix "ChallengeResponseAuthentication" "no" "Desactivar métodos antiguos"
apply_fix "Protocol" "2" "Uso del protocolo SSH seguro"

# --------------------------------------------------------------
# 4) PROTECCIÓN ANTI-BRUTEFORCE
# --------------------------------------------------------------

echo -e "\n${YELLOW}[+] Activando protecciones anti brute-force...${RESET}"

apply_fix "MaxAuthTries" "3" "Intentos máximos permitidos"
apply_fix "LoginGraceTime" "20" "Tiempo máximo para intentar login"
apply_fix "AllowTcpForwarding" "no" "Bloquear túneles no autorizados"
apply_fix "X11Forwarding" "no" "Bloquear forwarding gráfico"

# --------------------------------------------------------------
# 5) CAMBIO DE PUERTO SEGURO
# --------------------------------------------------------------

echo -e "\n${YELLOW}[+] Configurando puerto SSH seguro aleatorio...${RESET}"

NEWPORT=$(( ( RANDOM % 40000 ) + 1025 ))

apply_fix "Port" "$NEWPORT" "Puerto SSH seguro (evita escáneres automáticos)"

echo -e "${CYAN}[i] Nuevo puerto SSH asignado:${RESET} ${GREEN}$NEWPORT${RESET}"

# --------------------------------------------------------------
# 6) VALIDAR CONFIGURACIÓN
# --------------------------------------------------------------

echo -e "\n${YELLOW}[+] Validando sintaxis...${RESET}"

sshd -t
if [[ $? -ne 0 ]]; then
    echo -e "${RED}[✘] Error en la configuración. Restaurando backup...${RESET}"
    cp "$BACKUP" "$CONFIG"
    exit 1
fi

echo -e "${GREEN}[✔] Configuración válida.${RESET}"

# --------------------------------------------------------------
# 7) REINICIAR SSH
# --------------------------------------------------------------

echo -e "\n${YELLOW}[+] Reiniciando SSH para aplicar cambios...${RESET}"

systemctl restart ssh

if [[ $? -ne 0 ]]; then
    echo -e "${RED}[✘] Error al reiniciar SSH. Restaurando backup...${RESET}"
    cp "$BACKUP" "$CONFIG"
    systemctl restart ssh
    exit 1
fi

# --------------------------------------------------------------
# 8) RESUMEN FINAL
# --------------------------------------------------------------

echo -e "\n${BLUE}== RESUMEN FINAL DEL BASTIONADO SSH ==${RESET}"
echo -e "${GREEN}[✔] Configuración endurecida correctamente.${RESET}"
echo -e "${YELLOW}[i] Backup disponible en:${RESET} $BACKUP"
echo -e "${YELLOW}[i] Nuevo puerto SSH:${RESET} ${GREEN}$NEWPORT${RESET}\n"
