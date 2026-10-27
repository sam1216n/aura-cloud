# AURA 5.1.1

- Interface de geração refinada com indicador visual estimado.
- Visualizador de imagens com zoom adaptativo e download PNG/JPG.
- Galeria com ações rápidas, imagens arredondadas, responsividade aprimorada.
- Prévia de projetos HTML em iframe isolado; CSS/JS locais inline quando possível.
- Cópia rápida do código e da resposta inteira.
- Visualização e exportação de arquivos individuais e ZIP preservadas.
- Cache offline da interface atualizado para 5.1.1.
- Segurança multiusuário e banco D1 preservados.

# AURA 5.0.4 — 26/10/2026

- Verificação de chave Gemini com **streamGenerateContent real**, não apenas presença da chave ou models.list.
- Suporte às chaves de autenticação atuais do Google: não rejeita credenciais só pelo prefixo.
- Seleção automática do modelo de texto conforme respostas reais autorizadas pela chave.
- Mensagens de diagnóstico distintas para chave inválida/bloqueada, projeto sem permissão, cota e rede.
- Botão **Testar conexão com Gemini** em Configurações, com teste realizado dentro do Cloudflare Worker autenticado.
- Lista de modelos filtrada para conversação e organizada por preferência; interface atualizada e cache renovado.
- Windows: aceita Worker novo (após exclusão) ou existente, preserva D1 e protege segredos.
- 23 testes Node locais cobrindo autenticação, isolamento multiusuário, ZIP e novo pré-teste Gemini.
- Nenhuma chave privada adicionada ao ZIP.


## Atualização 5.1
- Progresso visual durante geração de imagem.
- Cards de imagem com cantos arredondados e melhor apresentação.
- Pré-visualização de arquivos gerados com copiar/baixar por arquivo.
- Botão de copiar código em blocos de resposta.
- Geração de arquivos mais confiável com fallback de modelo.
