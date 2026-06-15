# Roteiro do Screencast – Sprint 3

**Duração estimada:** 3–5 minutos  
**O que preparar antes de gravar:**
- Backend rodando (`make dev` ou `docker compose up` na pasta `Back/`)
- `flutter run` no `app_cliente` (emulador Android ou iOS)
- Pelo menos 2 produtos cadastrados no banco
- Tela limpa, sem janelas desnecessárias abertas

---

## Parte 1 — Apresentação (30s)

Fale em voz alta (ou adicione legenda):

> "Esta é a entrega da Sprint 3 do Projeto Integrador. Vou demonstrar o app Flutter do cliente, que se integra ao backend REST desenvolvido nas sprints anteriores."

---

## Parte 2 — Tela de Login (30–45s)

1. Mostre o app aberto na `LoginScreen`.
2. Preencha com um nome (ex: "João Silva") e um telefone (ex: "31999999999").
3. Toque em **Entrar**.
4. Enquanto carrega, comente:
   > "O app verifica se o cliente já existe no banco pelo telefone. Se não existir, cadastra automaticamente."
5. A `HomeScreen` abre com "Olá, João Silva!" no topo.

---

## Parte 3 — Catálogo e Carrinho (1 min)

1. Mostre a lista de produtos carregados do backend.
2. Adicione 2 unidades de um produto usando o botão **+**.
3. Adicione 1 unidade de outro produto.
4. Mostre o botão flutuante "Ver pedido (3 itens)" aparecendo na parte inferior.
5. Comente:
   > "Os produtos são buscados da API REST. O carrinho é gerenciado localmente no estado do widget."

---

## Parte 4 — Resumo e Confirmação do Pedido (45s)

1. Toque em "Ver pedido".
2. Mostre a `CriarPedidoScreen` com os itens, preços unitários, subtotais e total geral.
3. Toque em **Confirmar Pedido**.
4. Mostre a mensagem de sucesso.
5. Comente:
   > "O app envia apenas id_produto e quantidade. O backend busca o preço no banco — isso evita que o cliente manipule o valor do pedido."
6. O app retorna para a `HomeScreen` com o carrinho zerado.

---

## Parte 5 — Meus Pedidos e Polling Assíncrono (1 min)

1. Toque no ícone de recibos no canto superior direito da `HomeScreen`.
2. Mostre a `MeusPedidosScreen` com o pedido criado (status "Pendente" em laranja).
3. Comente:
   > "Esta tela atualiza automaticamente a cada 10 segundos via polling. Não é necessária nenhuma ação do usuário."
4. **Demonstre a atualização:**
   - Abra o painel admin do backend (Supabase ou direto no banco) em outra janela.
   - Altere o status do pedido para `A` (Em Produção).
   - Aguarde até 10 segundos na tela do app.
   - O badge muda de "Pendente" (laranja) para "Em Produção" (azul) automaticamente.
5. Comente:
   > "Quando o prestador atualiza o pedido, o cliente vê a mudança sem precisar fazer nada."

---

## Parte 6 — Encerramento (15s)

> "Foram implementadas 4 telas no app cliente, integração com 5 endpoints REST, e atualização assíncrona de estado via polling. O código segue a Clean Architecture com separação em camadas de apresentação, modelos e serviços."

---

## Dicas de gravação

- Use **OBS Studio** (gratuito) para gravar a tela com o emulador visível.
- Mantenha a janela do emulador centralizada e em tamanho adequado.
- Se quiser mostrar terminal e app lado a lado, use a divisão de tela do seu OS.
- Para alterar o status do pedido durante a gravação, tenha o Supabase ou um cliente HTTP (Postman/Insomnia) já aberto.
