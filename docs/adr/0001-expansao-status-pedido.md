# ADR-0001 — Expansão do ciclo de status do Pedido de 4 para 6 valores

**Data:** 2026-06-17  
**Status:** Aceito

---

## Contexto

O backend foi inicialmente implementado com 4 status para o Pedido: `P`, `A`, `C`, `X`. Esse conjunto foi suficiente para a Sprint 3 (app_cliente), mas não reflete o fluxo real da operação da panificadora, que possui etapas distintas entre a produção e a entrega ao cliente.

## Decisão

Expandir o ciclo de vida do Pedido para 6 status:

```
P → A → S → E → C    (X cancela apenas de P)
```

Adicionando `S` (Separado) e `E` (Em Entrega) entre a produção e a conclusão.

## Alternativas consideradas

**Manter 4 status:** mais simples, sem necessidade de migração. Descartado porque colapsa duas etapas operacionais distintas — separação física do produto e transporte — em uma única transição `A → C`, tornando impossível saber onde o pedido está no mundo real.

## Consequências

**Positivas:**
- Funcionário e Cliente têm visibilidade granular de onde o pedido está.
- Base para rastreamento de divergências na separação (Fase 2).

**Negativas / custos:**
- Requer migração no banco: o campo `status char(1)` já suporta qualquer caractere, mas os valores `S` e `E` precisam ser reconhecidos pelo backend.
- O `app_prestador` (código existente) usa `const fluxo = {'P': 'A', 'A': 'C'}` — precisa ser atualizado para `{'P': 'A', 'A': 'S', 'S': 'E', 'E': 'C'}`.
- O evento RabbitMQ `pedido.status.atualizado` já é genérico — nenhuma mudança necessária nos consumers existentes.
