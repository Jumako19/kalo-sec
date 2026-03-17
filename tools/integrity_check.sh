#!/bin/bash
echo "[+] Comprobación rápida de integridad..."

echo "[+] Hash de archivos críticos:"
sha256sum /etc/passwd
sha256sum /etc/shadow
sha256sum /etc/ssh/sshd_config

echo "[+] Archivos modificados en /etc en las últimas 24h:"
find /etc -mtime -1 -type f
