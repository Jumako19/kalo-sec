#!/bin/bash

echo "[+] Restaurando configuración SSH..."
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin no/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
systemctl restart ssh

echo "[+] Eliminando banner..."
sed -i '/Banner \/etc\/issue.net/d' /etc/ssh/sshd_config
rm -f /etc/issue.net

echo "[+] Deshabilitando Fail2ban..."
systemctl disable --now fail2ban

echo "[+] Desactivando firewall..."
ufw disable

echo "[+] Restauración completada."
