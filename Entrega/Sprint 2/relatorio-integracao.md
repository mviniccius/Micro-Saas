# Relatório de Integração – Sprint 2

**Disciplina:** Lab. de Desenvolvimento de Aplicações Móveis e Distribuídas  
**Aluno:** mViniccius  
**Data:** 18/05/2026  
**Sprint:** 2 – Integração com Middleware Orientado a Mensagens

---

## 1. Ferramenta MOM escolhida: RabbitMQ

Foi escolhido o **RabbitMQ 3** com a imagem oficial `rabbitmq:3-management` via Docker. A justificativa da escolha se baseia em três fatores:

- **Maturidade:** RabbitMQ é amplamente utilizado em produção e possui suporte robusto ao protocolo AMQP 0-9-1.
- **Painel de gerenciamento:** A imagem `management` fornece uma UI web em `localhost:15672`, facilitando a observação de filas, exchanges e mensagens em tempo real — essencial para evidenciar o funcionamento nesta sprint.
- **Compatibilidade com o padrão topic exchange:** Permite o roteamento por routing key (ex: `pedido.criado`, `pedido.status_atualizado`), viabilizando a expansão para múltiplos consumidores independentes sem alterar o produtor.

---

## 2. Padrão utilizado: Topic Exchange + Filas Duráveis

O sistema utiliza um **exchange do tipo topic** chamado `padaria_events`. Producers publicam mensagens com routing keys descritivas (ex: `pedido.criado`). Consumers criam filas duráveis e as vinculam ao exchange via binding.

Esse padrão segue o princípio de **publish/subscribe desacoplado**: o backend (producer) não conhece os consumers — ele apenas publica o evento. Isso permite, futuramente, adicionar novos consumidores (ex: app Flutter do prestador, serviço de notificações) sem nenhuma alteração no código do backend.

---

## 3. Eventos implementados

Dois eventos são publicados em momentos distintos do fluxo de negócio:

**`pedido.criado`** — publicado em `pedidoService.criarPedidoCompleto` após o `COMMIT` da transação no banco. O consumer `fila_pedido_criado` simula a notificação da linha de produção.

**`pedido.status_atualizado`** — publicado em `pedidoService.atualizarStatusPedido` após o `UPDATE` no banco. O consumer `fila_pedido_status` simula a notificação aos interessados na mudança de estado (ex: o cliente aguardando confirmação).

---

## 4. Desafios encontrados e soluções adotadas

**Desafio 1 – Race condition na inicialização dos containers**  
O container `app` (Node.js) subia antes do RabbitMQ estar pronto para aceitar conexões, causando falha imediata. A solução adotada foi implementar lógica de **retry com backoff fixo** no módulo `rabbitmq.js`: o sistema tenta reconectar até 10 vezes com intervalo de 5 segundos entre cada tentativa, o que cobre o tempo de inicialização típico do RabbitMQ.

**Desafio 2 – Garantia de não-perda de mensagens**  
Para garantir que mensagens não sejam perdidas em caso de restart do RabbitMQ, foram configurados: exchange com `durable: true`, filas com `durable: true` e mensagens com `persistent: true`. Com isso, as mensagens sobrevivem a reinicializações do broker.

**Desafio 3 – Isolamento entre producer e consumer**  
Para demonstrar assincronicidade real, o consumer roda como parte do processo principal (`index.js`), mas opera de forma completamente independente: ele nunca é chamado diretamente pelo controller ou service — a comunicação ocorre exclusivamente via RabbitMQ, sem chamada de função direta entre os componentes.

---

## 5. Conclusão

A integração com o RabbitMQ estabeleceu a base da Arquitetura Orientada a Eventos (EDA) do sistema. O backend passou a agir como **produtor de eventos** em dois pontos do fluxo de negócio, enquanto o consumer simula os serviços downstream (linha de produção e notificações). Essa arquitetura prepara o sistema para as sprints seguintes, onde os aplicativos Flutter se integrarão como consumidores dos eventos via polling ou WebSocket sobre o mesmo backend.
