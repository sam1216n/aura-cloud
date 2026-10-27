# AURA 5.1.1 — Versão GitHub (sem chaves privadas)

**Este repositório contém o projeto completo.** Para subir ao GitHub e publicar na Cloudflare com segurança, leia **[GUIA_GITHUB.md](GUIA_GITHUB.md)**.

> O GitHub hospeda o código; o site roda na Cloudflare. O fluxo de deploy pelo GitHub é manual e protege o Worker, os dados D1 e os segredos existentes.

---

# AURA 5.0.4 — Login local + Gemini validado

Projeto completo Cloudflare Workers + D1, em português, com cadastro por usuário e senha, histórico privado por conta, chat com Gemini via streaming, geração de projetos ZIP e opções de imagem.

## Instalação no Windows (um arquivo)

1. Acesse https://aistudio.google.com/apikey e crie **uma chave Gemini NOVA**. **Não reutilize a chave compartilhada em conversas**; revogue a antiga. O formato novo da chave pode ser diferente dos modelos antigos, e isso é normal.
2. Extraia o ZIP numa pasta nova (não rode o arquivo .bat dentro do ZIP).
3. Execute `DEPLOY_WINDOWS.bat` e siga as instruções da janela.
4. O instalador entra na sua conta Cloudflare e vincula o D1 `aura-cloud-db` já existente. Não apaga tabelas, conversas, usuários ou arquivos existentes.
5. Quando solicitado, digite a **nova chave da API Gemini**. A digitação fica oculta. O instalador enviará a chave **por stdin** a um verificador local, sem armazená-la em arquivos ou incluí-la no ZIP.
6. O verificador consulta os modelos liberados pela chave e faz uma **requisição real de streaming de texto** à API. Se houver sucesso, o modelo aprovado passa a ser o padrão da sua instalação. Se o Google rejeitar a chamada, o deploy para com um diagnóstico. Não tente simplesmente ignorar a falha.
7. Após a publicação, abra https://aura-cloud.aura-samuel.workers.dev e faça login ou crie uma conta. Em **Configurações → Testar conexão com Gemini** há um segundo teste, agora executado de dentro do Worker Cloudflare. Essa ação usa uma pequena quantidade de tokens e conta como uma ação do limite AURA.

## Por que as versões anteriores falhavam?

A presença do segredo `GEMINI_API_KEY` no Worker não confirma que a chave funciona. O Google pode bloquear uma chave exposta, negar geração no nível do projeto, impor cotas ou permitir listar modelos mas recusar inferência. E um modelo configurado manualmente pode não estar liberado. A verificação desta versão testa o **mesmo endpoint de streaming utilizado pelo chat** e escolhe apenas um modelo que comprovadamente retornou texto no teste local.

## Mensagens de diagnóstico

- `invalid_key`/`blocked`: obtenha uma chave nova no AI Studio e confira a página de status do projeto.
- `permission`: confirme permissões da conta de serviço, região elegível e estado do faturamento do projeto Google (não é problema do D1).
- `quota`: verifique a cota e o plano do projeto no AI Studio. Gerar uma nova chave no **mesmo projeto** normalmente não contorna uma restrição de projeto.
- `network`: teste a conexão do seu computador com o Google. Sem contato com a API, não é possível afirmar que a chave está correta.
- `request`/`model`: o Google rejeitou a solicitação ou não liberou o modelo selecionado.

## Segurança e separação das contas

- Login por usuário e senha; senhas são armazenadas com hash com salt e pepper. O segredo `AURA_PASSWORD_PEPPER` fica no Cloudflare Worker, não no ZIP.
- Todas as consultas de conversas e recursos particulares usam `user_id`.
- O Gemini só recebe mensagens da conta autenticada. A chave é utilizada exclusivamente pelo Worker no backend.
- Os segredos não ficam em `public/`, nos scripts de exemplo nem no repositório.
- Se você **excluiu o Worker anterior**, os segredos vinculados podem ter sido perdidos. Neste caso o instalador cria uma nova chave de proteção de senha. Contas locais antigas protegidas por um pepper perdido não poderão autenticar com a senha anterior, embora os registros sigam no D1. Não é possível recuperar o pepper só a partir do banco.
- R2 é opcional para o chat e é vinculado somente se disponível. Uma galeria antes vinculada ao R2 precisará de acesso ao bucket antigo para visualizar imagens anteriores.

## Desenvolvimento

Node.js >= 20. Execute `npm install` e `npm test`. Para iniciar localmente: `npm run dev` (configure `.dev.vars` local sem publicar essa chave).

## Limites de garantia

Os testes automatizados verificam autenticação, isolamento, códigos de diagnóstico e simulações das respostas Gemini. A credencial real e as permissões do projeto são externas: o instalador e o botão de diagnóstico realizam os testes reais no ambiente do usuário/Worker. Não é possível garantir acesso à API se o Google negar credenciais, cota, elegibilidade, região ou projeto.

Documentação: https://ai.google.dev/gemini-api/docs/api-key ; https://ai.google.dev/gemini-api/docs/troubleshooting


## Atualização 5.1
- Progresso visual durante geração de imagem.
- Cards de imagem com cantos arredondados e melhor apresentação.
- Pré-visualização de arquivos gerados com copiar/baixar por arquivo.
- Botão de copiar código em blocos de resposta.
- Geração de arquivos mais confiável com fallback de modelo.


## AURA 5.1.1 — Recursos novos
- Visualização ampliada de imagens em uma janela interna, com tecla ESC para fechar.
- Exportação para PNG ou JPG no chat, galeria e visualizador de imagens.
- Prévia HTML de projetos gerados, com suporte a CSS e JavaScript locais vinculados por caminhos relativos (quando possível). A prévia é executada em iframe isolado por sandbox sem permissão de mesma origem e sem acesso à rede ou cookies. Projetos com bibliotecas externas podem aparecer incompletos.
- Cada bloco de código da resposta tem ação de copiar e as respostas completas também.
- O progresso de geração de imagem mostra uma **porcentagem visual estimada**, não um percentual real do provedor (ele não transmite progresso em porcentagem).
- Não altere nem apague o banco D1; a migração é aditiva. O sistema continua a separar cada recurso por usuário.
- Apenas faça deploy com DEPLOY_WINDOWS.bat na pasta extraída. Nunca armazene a chave Gemini dentro dos arquivos do site.
