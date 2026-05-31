# Documentação dos Eventos – Sprint 2

## Tecnologia MOM utilizada
**RabbitMQ 3** com exchange do tipo **topic** chamada `padaria_events`.

---

## Tabela de Eventos

| # | Nome do Evento | Routing Key | Exchange | Fila Consumidora | Produtor | Consumidor | Descrição |
|---|---|---|---|---|---|---|---|
| 1 | Pedido Criado | `pedido.criado` | `padaria_events` | `fila_pedido_criado` | `pedidoService.criarPedidoCompleto` | `consumer.js` | Disparado após a criação bem-sucedida de um pedido e seus itens no banco de dados. Notifica a linha de produção. |
| 2 | Status de Pedido Atualizado | `pedido.status_atualizado` | `padaria_events` | `fila_pedido_status` | `pedidoService.atualizarStatusPedido` | `consumer.js` | Disparado sempre que o status de um pedido é alterado via `PATCH /pedidos/:id/status`. Notifica os interessados sobre a mudança de estado. |

---

## Payloads JSON de Exemplo

### Evento: `pedido.criado`

**Endpoint disparador:** `POST /pedidos`

```json
{
  "id_pedido": 7,
  "id_cliente": 2,
  "valor_total": 45.90,
  "status": "P",
  "timestamp": "2026-05-18T14:32:00.000Z"
}
```

### Evento: `pedido.status_atualizado`

**Endpoint disparador:** `PATCH /pedidos/7/status`

```json
{
  "id_pedido": 7,
  "status_anterior": "P",
  "status_novo": "A",
  "timestamp": "2026-05-18T14:35:00.000Z"
}
```

---

## Valores de Status

| Código | Descrição |
|--------|-----------|
| `P` | Pendente (estado inicial) |
| `A` | Em Produção (aceito pela linha) |
| `C` | Concluído |
| `X` | Cancelado |

---

## Fluxo de Eventos

```
Cliente HTTP                Backend (Express)            RabbitMQ                   Consumidor (consumer.js)
     |                            |                           |                              |
     |-- POST /pedidos ---------->|                           |                              |
     |                   [INSERT pedido + itens]              |                              |
     |                            |-- publish pedido.criado ->|                              |
     |<-- 201 Created ------------|                           |-- fila_pedido_criado ------->|
     |                            |                           |                   [LOG: novo pedido na produção]
     |                            |                           |                              |
     |-- PATCH /pedidos/7/status->|                           |                              |
     |                   [UPDATE pedidos SET status]          |                              |
     |                            |-- publish pedido.status ->|                              |
     |<-- 200 OK -----------------|                           |-- fila_pedido_status ------->|
     |                            |                           |                   [LOG: status atualizado]
```
