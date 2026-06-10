# 🕵️ Grupo Ali — Investigação Privada (Landing Page)

Site institucional/landing page de página única (one-page) do **Grupo Ali — Investigação Privada**.
Projeto **independente** dos demais (Projeto01, PA Virtual, etc.).

## Stack
- HTML + CSS + JS vanilla (sem build, sem dependências locais)
- GSAP + ScrollTrigger via CDN (animações)
- Fontes Google: Oswald + Inter
- Tema **Dark Premium** preto (#0a0a0a) + dourado (#d4af37)

## Arquivos
- `index.html` — site completo (único arquivo)
- `assets/hero-bg-hd.png` — fundo do hero (câmera/drones/satélite/Terra), 3072px
- `assets/brasao-iso.png` — brasão Grupo Ali isolado (fundo transparente)

## Rodar localmente
```bash
npx http-server . -p 4599 -c-1
# abrir http://localhost:4599/index.html
```

## Seções
Header (nav + CTA) · Hero · Stats (contadores) · Serviços (5 cards) ·
Como Funciona (3 passos) · Credencial (brasão) · Contato (card de vidro:
form → WhatsApp + ícones coloridos) · Footer · WhatsApp flutuante ·
Aviso LGPD + Modais (Política de Privacidade + Configurações de Cookies)

## Dados do negócio
- Telefones: (67) 98119-6787 · (67) 92001-6411
- WhatsApp: https://wa.me/5567981196787
- Instagram: https://www.instagram.com/alidetetivesbr
- Lei 13.432/17 · CBO 3518-05
- Atuação: Campo Grande/MS + nacional · desde 1991

## Pendências / próximos passos
- Endereço real (atual é "Campo Grande / MS" genérico)
- Links reais de X e LinkedIn (hoje "#")
- Opcional: empacotar como PWA (instalável + offline) e deploy (Vercel/Netlify)
