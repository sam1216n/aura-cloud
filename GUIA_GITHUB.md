# AURA 5.1.1 — Guia para GitHub

O **GitHub guarda o código-fonte**. O **Cloudflare Worker executa o backend** e usa o D1 para separar os dados por conta. Apenas enviar arquivos ao GitHub **não coloca o site no ar**.

## 1. Subir o código para o GitHub

Crie um repositório vazio, de preferência **privado inicialmente**, por exemplo `aura-cloud`.

### Opção A — via navegador

- Extraia `AURA_5_1_1_GITHUB_PUBLICAVEL.zip` no computador.
- Abra o repositório no GitHub e use **Add file → Upload files**.
- Envie o **conteúdo de `AURA_5_1_1_GITHUB/`**, incluindo a pasta `.github`, e não o ZIP como um único arquivo.
- Confirme o commit na branch `main`.

### Opção B — via Git (mais confiável para manter a pasta `.github`)

Abra um terminal dentro da pasta `AURA_5_1_1_GITHUB/` e rode:

```bash
git init
git add .
git commit -m "AURA 5.1.1 - versão GitHub"
git branch -M main
git remote add origin https://github.com/SEU_USUARIO/aura-cloud.git
git push -u origin main
```

Troque `SEU_USUARIO` pelo usuário do GitHub e faça login normalmente se solicitado.

## 2. Publicar o site na Cloudflare — escolha um caminho

### Mais fácil: instalador Windows

Não precisa configurar Actions: execute o arquivo **`DEPLOY_WINDOWS.bat`** dentro do projeto extraído. Ele localiza o D1 existente, solicita autenticação Cloudflare, testa a chave Gemini e publica o site.

**Não exclua** o Worker `aura-cloud` existente. Ele armazena o segredo `AURA_PASSWORD_PEPPER` usado no login. Se você apagá-lo, poderá perder o acesso às contas locais antigas.

### Publicar diretamente pelo GitHub Actions

Essa opção é recomendada **depois de um primeiro deploy funcional pelo instalador Windows**, porque o GitHub não deve recriar o segredo de senhas dos usuários.

1. No GitHub, abra **Settings → Secrets and variables → Actions → New repository secret**.
2. Cadastre os segredos a seguir:

| Nome | Onde obter | Observação |
| --- | --- | --- |
| `CLOUDFLARE_API_TOKEN` | Cloudflare → API Tokens | Token com permissão de deploy do Worker da sua conta. |
| `CLOUDFLARE_ACCOUNT_ID` | Painel Cloudflare → identificação da conta | ID da mesma conta onde está o AURA. |
| `AURA_D1_DATABASE_ID` | Cloudflare → Workers & Pages → D1 → `aura-cloud-db` | UUID do banco D1 **existente**. |

3. O Worker `aura-cloud` já deve possuir os secrets `GEMINI_API_KEY` e `AURA_PASSWORD_PEPPER` **na Cloudflare**. Nunca copie seus valores para arquivos do GitHub.
4. No GitHub, clique em **Actions → AURA | Publicar Cloudflare → Run workflow**. Ele roda os testes, valida a presença dos segredos e publica somente se todos os pré-requisitos estiverem presentes.
5. Abra seu site: `https://aura-cloud.aura-samuel.workers.dev`.

**Proteção importante:** o workflow de deploy é **manual**, não é executado automaticamente a cada push. O workflow de testes roda nos pushes e pull requests. A vinculação ao D1 é preenchida apenas no runner temporário do Actions.

## 3. Como gerenciar as chaves

- `GEMINI_API_KEY`: valor fica em **Cloudflare → Workers & Pages → aura-cloud → Settings → Variables and Secrets**, nunca no GitHub.
- `AURA_PASSWORD_PEPPER`: manter **o mesmo valor existente**. **Não sobrescrever**, pois isso pode impedir usuários de entrar em contas existentes.
- `CLOUDFLARE_API_TOKEN`: somente nos **segredos criptografados do GitHub Actions**, não nos commits.
- `.dev.vars` é um arquivo local ignorado pelo Git; `.dev.vars.example` é apenas um exemplo sem segredo.

Se uma chave foi publicada em conversa, repositório ou log, revogue-a e gere outra.

## 4. Banco e galeria

- As consultas D1 continuam exigindo `user_id`; cada conta só vê suas próprias conversas, arquivos e imagens, segundo os testes.
- O workflow GitHub associa o banco D1 existente; **não aplica a migração automaticamente**. O instalador Windows pode executar a migração aditiva de `schema.sql` quando necessário.
- O binding R2 `AURA_IMAGES` é **opcional**. Se seu Worker já usa o bucket `aura-cloud-images`, reconfigure esse binding no `wrangler.toml` antes de publicar pelo GitHub para continuar vendo imagens salvas no R2. O deploy GitHub, por padrão, inclui apenas o D1 e o Workers AI.

## 5. Verificações

- `npm run check` — valida JavaScript e executa a suíte automatizada.
- `npm run dev` — servidor local. Requer variáveis locais em `.dev.vars` e configuração do banco de desenvolvimento.
- A geração de imagens mostra **porcentagem estimada**, não progresso real informado pelo provedor.
- Nunca suba senhas, chaves Gemini, token Cloudflare, exportações D1 nem `.dev.vars`.

## Troubleshooting

- **Worker não encontrado** nas Actions: instale primeiro via `DEPLOY_WINDOWS.bat`.
- **Faltou `AURA_PASSWORD_PEPPER`**: não crie um valor novo em um Worker com contas existentes. Recupere o segredo antigo ou confirme as consequências para o login.
- **D1 ausente**: configure `AURA_D1_DATABASE_ID` com o UUID do banco certo.
- **Falha de autenticação Cloudflare**: confira o token, a conta e permissões.
- **Gemini indisponível**: vá ao site, Configurações → Testar conexão com Gemini. Chave Gemini fica na Cloudflare, não no GitHub.

Documentação Cloudflare: https://developers.cloudflare.com/workers/ci-cd/external-cicd/github-actions/
