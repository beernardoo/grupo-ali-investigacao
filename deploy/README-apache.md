# Deploy no Apache (VPS do Mariano)

O site é **estático** (HTML/CSS/JS). Roda direto no Apache — não precisa de PHP, Node nem banco.
Estes passos **não mexem nos outros sites** do Apache: só adicionam um VirtualHost novo.

Pré-requisito: o DNS já precisa apontar pra VPS. Confira:
```bash
dig +short grupoalidetetives.com.br    # tem que retornar 157.173.196.193
```

## Passo a passo (Ubuntu/Debian, como root ou com sudo)

```bash
# 1. Módulos + git + certbot do Apache
sudo apt-get update
sudo apt-get install -y git certbot python3-certbot-apache
sudo a2enmod headers rewrite ssl

# 2. Baixar o site
sudo rm -rf /var/www/grupoali
sudo git clone --depth 1 https://github.com/beernardoo/grupo-ali-investigacao.git /var/www/grupoali
sudo chown -R www-data:www-data /var/www/grupoali

# 3. VirtualHost
sudo curl -fsSL https://raw.githubusercontent.com/beernardoo/grupo-ali-investigacao/main/deploy/apache-grupoali.conf -o /etc/apache2/sites-available/grupoali.conf
sudo a2ensite grupoali
sudo apache2ctl configtest && sudo systemctl reload apache2

# 4. HTTPS (Let's Encrypt) + redirect automático
sudo certbot --apache -d grupoalidetetives.com.br -d www.grupoalidetetives.com.br --agree-tos -m makbernardo@gmail.com --redirect
```

Pronto: site no ar em **https://grupoalidetetives.com.br**.

## Atualizar o site depois
```bash
cd /var/www/grupoali && sudo git pull && sudo systemctl reload apache2
```

## Ativar HSTS (opcional, depois do HTTPS ok)
No arquivo `/etc/apache2/sites-available/grupoali.conf` descomente a linha `Strict-Transport-Security` e rode:
```bash
sudo apache2ctl configtest && sudo systemctl reload apache2
```

## Esconder a versão do Apache (ServerTokens — GLOBAL)
`ServerTokens` é diretiva global (não vai dentro do VirtualHost). Ajuste uma vez só, no servidor:
```bash
sudo sed -i 's/^ServerTokens .*/ServerTokens Prod/' /etc/apache2/conf-available/security.conf
sudo sed -i 's/^ServerSignature .*/ServerSignature Off/' /etc/apache2/conf-available/security.conf
sudo apache2ctl configtest && sudo systemctl reload apache2
```

## Atrás do Cloudflare — IP real + fail2ban (IMPORTANTE)
Com a origem atrás do Cloudflare, o Apache vê o IP do CF como "visitante" e o fail2ban
pode banir as faixas do próprio Cloudflare (causa de HTTP 521 intermitente). Corrija:
```bash
# 1) IP real do visitante via mod_remoteip
sudo a2enmod remoteip
sudo cp /var/www/grupoali/deploy/cloudflare-remoteip.conf /etc/apache2/conf-available/cloudflare-remoteip.conf
sudo a2enconf cloudflare-remoteip
sudo apache2ctl configtest && sudo systemctl reload apache2

# 2) fail2ban ignorando as faixas do Cloudflare (no arquivo que define a jail, não só [DEFAULT])
#    adicione as 15 faixas IPv4 + 7 IPv6 do CF em ignoreip e reinicie:
sudo systemctl restart fail2ban
```
> As faixas oficiais do Cloudflare estão listadas em `cloudflare-remoteip.conf`.

## Observações
- Se o firewall (UFW) estiver ativo, libere as portas web: `sudo ufw allow 'Apache Full'`.
- O VirtualHost já inclui headers de segurança (nosniff, X-Frame-Options, CSP, Referrer-Policy, etc.) e bloqueia `.git`/dotfiles.
- Firewall/fail2ban: se ainda não tiver, `sudo apt-get install -y fail2ban` e `sudo systemctl enable --now fail2ban`.
