#!/bin/bash

echo "[+] Actualizando sistema..."
apt update && apt upgrade -y

echo "[+] Configurando firewall UFW..."
apt install ufw -y
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
yes | ufw enable

echo "[+] Instalando Fail2ban..."
apt install fail2ban -y
systemctl enable --now fail2ban

echo "[+] Activando AIDE (integridad)..."
apt install aide -y
aideinit
cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db

echo "[+] Deshabilitando servicios innecesarios..."
systemctl disable bluetooth.service 2>/dev/null
systemctl disable cups.service 2>/dev/null

echo "[+] Aplicando umask segura..."
echo "umask 027" >> /etc/profile

echo "[+] Configurando SSH seguro..."
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
echo "MaxAuthTries 3" >> /etc/ssh/sshd_config
echo "ClientAliveInterval 300" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 2" >> /etc/ssh/sshd_config

echo "[+] Activando ASLR..."
echo "kernel.randomize_va_space = 2" >> /etc/sysctl.conf
sysctl -p

echo "[+] Instalando rkhunter..."
apt install rkhunter -y
rkhunter --update

echo "[+] Creando banner legal..."
echo "ACCESO RESTRINGIDO. Toda actividad será registrada." > /etc/issue.net
echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config

echo "[+] Reiniciando SSH..."
systemctl restart ssh

echo "[+] Bastionado completado."
