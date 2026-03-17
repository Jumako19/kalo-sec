#!/bin/bash

echo "=== Información del sistema ==="
uname -a

echo "=== Usuarios del sistema ==="
cut -d: -f1 /etc/passwd

echo "=== Servicios activos ==="
systemctl list-units --type=service --state=running

echo "=== Puertos en escucha ==="
ss -tulnp

echo "=== Últimos inicios de sesión ==="
last | head

echo "=== Procesos sospechosos ==="
ps aux | grep -Ei "(nc|netcat|crypt|python|reverse|minerd)" | grep -v grep
