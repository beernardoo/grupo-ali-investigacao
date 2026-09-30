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

## Observações
- Se o firewall (UFW) estiver ativo, libere as portas web: `sudo ufw allow 'Apache Full'`.
- O VirtualHost já inclui headers de segurança (nosniff, X-Frame-Options, CSP, Referrer-Policy, etc.) e bloqueia `.git`/dotfiles.
- Firewall/fail2ban: se ainda não tiver, `sudo apt-get install -y fail2ban` e `sudo systemctl enable --now fail2ban`.
