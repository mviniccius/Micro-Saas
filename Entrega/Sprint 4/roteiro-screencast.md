# Roteiro do Screencast – Sprint 4

**Duração estimada:** 4–5 minutos  

---

## O que preparar antes de gravar

- Backend rodando (`make dev` ou `docker compose up` na pasta `Back/`)
- RabbitMQ rodando e acessível (verifique o painel em `http://localhost:15672` antes de gravar)
- `flutter run` no `app_cliente` (emulador Android ou iOS) — já logado com um cliente de teste
- `flutter run` no `app_prestador` (segundo emulador ou dispositivo físico) — já logado com o funcionário de teste
- Pelo menos 3 produtos cadastrados no banco
- Janela do terminal visível ao lado dos emuladores, ou minimizada mas pronta para uso
- Organize a tela: emulador do cliente à esquerda, emulador do prestador à direita
- Carrinho do app_cliente em branco (pedido anterior já encerrado ou cancelado)
- PedidosScreen do app_prestador visível e sem pedidos pendentes do cliente de teste

---

## Parte 1 — Apresentação (30s)

Mostre os dois emuladores lado a lado na tela. Fale:

> "Esta é a entrega da Sprint 4 do Projeto Integrador. Vou demonstrar os dois apps rodando simultaneamente: o app do cliente à esquerda e o app do prestador — o funcionário da panificadora — à direita. O objetivo é mostrar o fluxo completo de um pedido, desde a criação pelo cliente até a entrega, com comunicação assíncrona via MOM."

---

## Parte 2 — Cliente monta e confirma o pedido (1 min)

**No emulador do app_cliente (esquerda):**

1. Mostre a `HomeScreen` com o catálogo de produtos carregado.
2. Adicione 2 unidades de um produto (ex: "Pão Francês") usando o botão **+**.
3. Adicione 1 unidade de outro produto (ex: "Bolo de Chocolate").
4. Mostre o botão flutuante "Ver pedido (3 itens)" na parte inferior.
5. Toque em "Ver pedido" para abrir a `CriarPedidoScreen`.
6. Mostre os itens, preços e o total geral.
7. Toque em **Confirmar Pedido**.
8. Mostre a mensagem de sucesso e o retorno para a `HomeScreen`.

Comente enquanto realiza os passos:

> "O cliente monta o pedido a partir do catálogo de produtos. Ao confirmar, o app envia apenas o id do produto e a quantidade — o preço é calculado pelo backend, evitando qualquer manipulação do lado do cliente."

Após a confirmação:

> "No momento em que o pedido é persistido no banco, o backend publica um evento no RabbitMQ — o Message Oriented Middleware do sistema. Vamos ver o que acontece no lado do prestador."

---

## Parte 3 — Prestador recebe o pedido via polling (45s)

**Mude o foco para o emulador do app_prestador (direita). Aguarde em silencio por ate 10 segundos.**

1. Mostre a `PedidosScreen` do app_prestador antes do pedido aparecer (lista vazia ou sem o novo pedido).
2. Aguarde o polling de 10 segundos completar.
3. O novo pedido aparece na lista com o status **"Recebido"**.

Comente assim que o pedido aparecer:

> "Sem nenhuma acao manual, o pedido apareceu na lista do prestador. A PedidosScreen faz polling a cada 10 segundos no backend, que por sua vez processa o evento publicado no RabbitMQ. Esta e a prova da comunicacao assincrona entre os dois aplicativos."

---

## Parte 4 — Prestador avanca o status: Recebido para Em Producao (45s)

**No emulador do app_prestador:**

1. Toque no pedido para abrir a `PedidoDetalheScreen`.
2. Mostre os dados do pedido: cliente, itens, quantidades e status atual ("Recebido").
3. Toque no botao para avancar o status (ex: botao "Iniciar Producao" ou equivalente).
4. Confirme a acao se houver dialogo de confirmacao.
5. Mostre o status atualizado para **"Em Producao"** na propria tela de detalhe.

Comente:

> "O prestador aceitou o pedido e iniciou a producao. Internamente, o backend atualiza o status no banco e publica um novo evento no RabbitMQ notificando a mudanca. Vamos ver o reflexo no app do cliente."

---

## Parte 5 — Cliente ve a atualizacao automaticamente (30s)

**Mude o foco para o emulador do app_cliente (esquerda).**

1. Toque no icone de recibos na `HomeScreen` para abrir a `MeusPedidosScreen`.
2. Mostre o pedido com o status **"Recebido"** (laranja) — estado antes da atualizacao.
3. Aguarde o polling de 10 segundos.
4. O badge muda automaticamente para **"Em Producao"** (azul) sem nenhuma acao do usuario.

Comente:

> "O app do cliente atualizou o status sem nenhuma intervencao. O polling de 10 segundos consultou o backend e refletiu a mudanca feita pelo prestador. O cliente acompanha o pedido em tempo quase real."

---

## Parte 6 — Prestador avanca mais dois status (1 min)

**Volte para o emulador do app_prestador:**

**Transicao Separado:**

1. Acesse novamente a `PedidoDetalheScreen` do pedido.
2. Avance o status de "Em Producao" para **"Separado"**.
3. Mostre o status atualizado na tela.

Comente brevemente:

> "A producao foi concluida. O prestador marca o pedido como separado — pronto para sair para entrega."

**Transicao Em Entrega:**

1. Avance o status de "Separado" para **"Em Entrega"**.
2. Mostre o status atualizado.

Comente:

> "Cada avanco de status e um evento publicado no RabbitMQ. O ciclo completo e: Recebido, Em Producao, Separado, Em Entrega e Entregue."

**Opcional — mostre rapidamente a MeusPedidosScreen do cliente refletindo o ultimo status avancado, ou mencione que o mecanismo e identico ao demonstrado na Parte 5.**

---

## Parte 7 — Encerramento (30s)

Mostre os dois emuladores novamente lado a lado. Fale:

> "Isso conclui a demonstracao da Sprint 4. Foram implementados dois aplicativos Flutter com Design System proprio, integracao com backend Node.js via REST, e arquitetura orientada a eventos com RabbitMQ como Message Oriented Middleware. O backend segue a Clean Architecture com separacao em camadas de rotas, servicos e acesso a dados. O ciclo de status do pedido cobre cinco transicoes distintas, com cancelamento disponivel apenas no status inicial. Obrigado."

---

## Dicas de gravacao

- Use **OBS Studio** para capturar os dois emuladores simultaneamente em uma unica cena.
- Configure uma cena com dois "Window Capture" lado a lado (cliente esquerda, prestador direita).
- Tenha o terminal com os logs do backend visivel em uma terceira area ou minimizado — pode ser util mostrar brevemente o log de evento publicado no RabbitMQ durante a Parte 2.
- Para a transicao das Partes 3 e 5, deixe o cronometro visivel para o espectador perceber os 10 segundos de polling (o app OBS tem um plugin de cronometro, ou use o relogio do proprio OS).
- Grave em resolucao minima de 1080p para que os dois emuladores fiquem legiveis.
- Ensaie o fluxo uma vez antes de gravar para garantir que o polling ja tenha sincronizado os dados de teste.
