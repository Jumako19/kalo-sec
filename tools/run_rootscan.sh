#!/bin/bash
echo "[+] Ejecutando RKHunter..."
sudo rkhunter --update
sudo rkhunter --check --sk
