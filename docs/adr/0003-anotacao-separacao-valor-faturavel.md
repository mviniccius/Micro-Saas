# ADR-0003 — Anotação de Separação e valor faturável

**Data:** 2026-06-23
**Status:** Aceito

---

## Contexto

Na realidade da panificadora, o que é **entregue** nem sempre é igual ao que foi **pedido**: por sobra ou falta de produção, o Cliente leva mais ou menos do que pediu — e às vezes leva um Produto que nem estava no Pedido (sobra de produção da casa).

O modelo financeiro (ver ADR-0002) faz a Fatura somar o `valor_total` de cada Pedido, que hoje é calculado em cima do que foi **pedido**. Isso entra em conflito com a regra de negócio: o Cliente deve pagar pelo que **levou**, não pelo que pediu.

O CLAUDE.md já antecipava esse conceito como Fase 2 ("Anotações de Separação"). Esta ADR registra como ele se conecta ao faturamento.

## Decisão

### 1. A Anotação de Separação preserva os dois números

Para cada Produto, a Anotação guarda **quantidade pedida** e **quantidade entregue**. O Pedido original não é sobrescrito — em disputa, há prova do que foi combinado e do que foi entregue.

### 2. A Anotação pode incluir Produtos fora do Pedido

Um Produto entregue que não estava no Pedido aparece na Anotação com quantidade pedida = 0. Granularidade da Anotação é por **Produto**, não por Item de Pedido.

### 3. Registrada na entrega, antes do faturamento

A Anotação é criada na transição `E → C` (confirmação de entrega). Como só Pedidos `C` entram em Fatura (ADR-0002), a Anotação sempre existe antes do fechamento — nunca depois.

### 4. A Fatura cobra o valor faturável

O valor de um Pedido na Fatura passa a ser seu **valor faturável**:
- **Com Anotação:** ∑ (quantidade entregue × preço do Produto)
- **Sem Anotação:** o valor do que foi pedido (comportamento atual)

A Anotação de Separação é a **fonte da verdade do faturamento** depois que o Pedido é entregue.

## Alternativas consideradas

- **Editar o Pedido na entrega** (sobrescrever pedido com entregue): mais simples, reusa a tela de edição, mas perde o registro do que foi pedido. Rejeitada por fragilidade em disputa.
- **Anotação apenas informativa** (Fatura cobra sempre o pedido): não mexe no Financeiro, mas contradiz a regra "leva a mais, paga a mais". Rejeitada.
- **Anotação por Item de Pedido** (não por Produto): impediria registrar Produto fora do Pedido. Rejeitada.

## Consequências

- O cálculo de valor do Pedido e o `fecharFatura` precisam considerar a quantidade entregue quando há Anotação, caindo de volta no pedido quando não há.
- Edição de Itens do Pedido continua restrita a `P` e `A`; ajustes na entrega são Anotação, não edição.
- A automação da conversão unidades → telas/armários na Lista de Produção é uma lacuna à parte ([PROD-01]), sem relação com esta decisão.
- A implementação fica para depois da Lista de Produção (menor e isolada), por mexer no Financeiro já entregue.
