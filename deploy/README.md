# Deploy — Grupo Ali (VPS + domínio próprio)

Site estático (HTML+assets). Já blindado: SRI nos scripts, `rel=noopener`, sem backend/segredos. O servidor aplica HTTPS + headers de segurança + firewall + fail2ban.

## 1. Registrar domínio (você faz — envolve pagamento)
- **.com.br** (recomendado p/ Brasil): https://registro.br — ~R$40/ano. Precisa CPF/CNPJ.
- **.com**: Cloudflare Registrar (preço de custo, ~US$10/ano) ou Namecheap.
- Sugestões: `grupoalidetetives.com.br`, `alidetetives.com.br`, `grupoali.com.br`.

## 2. Contratar VPS barata (você faz — pagamento)
Para site estático, o mais barato basta:
| Provedor | Plano | Preço |
|----------|-------|-------|
| **Hetzner** CX22 | 2vCPU/4GB | ~€4/mês ⭐ melhor custo |
| **Contabo** VPS S | 4vCPU/8GB | ~€5/mês |
| **DigitalOcean** | 1vCPU/1GB | US$4/mês |
| **Oracle Cloud Free** | ARM 24GB | **grátis** (se disponível) |
- SO: **Ubuntu 24.04 LTS**.
- Ao criar, **adicione sua chave SSH** (não use só senha).

## 3. Apontar domínio → VPS
No painel do domínio (registro.br/Cloudflare), crie 2 registros **A** para o IP da VPS:
```
@     A   IP_DA_VPS
www   A   IP_DA_VPS
```
Espere propagar (minutos a 1h).

## 4. Subir o site (1 comando)
SSH na VPS e rode:
```bash
curl -fsSL https://raw.githubusercontent.com/beernardoo/grupo-ali-investigacao/main/deploy/setup-vps.sh -o setup.sh
bash setup.sh SEU_DOMINIO SEU_EMAIL
```
O script instala nginx+certbot+ufw+fail2ban, faz o deploy, ativa HTTPS (Let's Encrypt) e os headers.

## 5. Atualizar o site depois
```bash
cd /var/www/grupoali && git pull && systemctl reload nginx
```

## Hardening extra recomendado (manual, opcional)
- Criar usuário sudo e **desabilitar login root/senha** no SSH (`/etc/ssh/sshd_config`: `PermitRootLogin no`, `PasswordAuthentication no`) — só depois de confirmar acesso por chave.
- Trocar porta SSH padrão (22 → ex. 2222) e `ufw allow 2222`.
