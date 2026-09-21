#!/usr/bin/env bash
# Setup + hardening + deploy do site Grupo Ali numa VPS Ubuntu 22.04/24.04 limpa.
# Uso (como root):  bash setup-vps.sh SEU_DOMINIO SEU_EMAIL
# Ex.:              bash setup-vps.sh grupoalidetetives.com.br makbernardo@gmail.com
set -euo pipefail

DOM="${1:?informe o dominio: bash setup-vps.sh dominio email}"
EMAIL="${2:?informe o email para o certificado SSL}"
REPO="https://github.com/beernardoo/grupo-ali-investigacao.git"
WWW="/var/www/grupoali"

echo "== 1/7 Atualizando sistema =="
export DEBIAN_FRONTEND=noninteractive
apt-get update -y && apt-get upgrade -y

echo "== 2/7 Instalando pacotes =="
apt-get install -y nginx certbot python3-certbot-nginx ufw fail2ban git unattended-upgrades

echo "== 3/7 Firewall (UFW) =="
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw --force enable

echo "== 4/7 fail2ban (protege SSH de brute-force) =="
systemctl enable --now fail2ban
# atualizações de segurança automáticas
dpkg-reconfigure -f noninteractive unattended-upgrades || true

echo "== 5/7 Deploy do site =="
rm -rf "$WWW"
git clone --depth 1 "$REPO" "$WWW"
chown -R www-data:www-data "$WWW"

echo "== 6/7 Nginx =="
sed "s/SEU_DOMINIO/$DOM/g" "$WWW/deploy/nginx-grupoali.conf" > /etc/nginx/sites-available/grupoali
ln -sf /etc/nginx/sites-available/grupoali /etc/nginx/sites-enabled/grupoali
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx

echo "== 7/7 HTTPS (Let's Encrypt) =="
certbot --nginx -d "$DOM" -d "www.$DOM" --non-interactive --agree-tos -m "$EMAIL" --redirect
# ativa HSTS depois do HTTPS ok
sed -i 's@# add_header Strict-Transport-Security@add_header Strict-Transport-Security@' /etc/nginx/sites-available/grupoali
nginx -t && systemctl reload nginx

echo ""
echo "PRONTO! Site no ar em https://$DOM"
echo "Atualizar depois:  cd $WWW && git pull && systemctl reload nginx"
