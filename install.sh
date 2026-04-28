#!/bin/bash
#INSTALACION
echo "[+] Instalando KALO-SEC..."

sudo mkdir -p /usr/share/kalo-sec/tools

sudo cp kalo-sec /usr/bin/kalo-sec
sudo cp tools/*.sh /usr/share/kalo-sec/tools/

sudo chmod +x /usr/bin/kalo-sec
sudo chmod -R +x /usr/share/kalo-sec/tools/

echo "[✔] Instalación completada."
echo "[i] Ejecuta ahora: kalo-sec"
