# CONTEXT.md — Panificadora Efraim

Glossário canônico do domínio. Não contém decisões de implementação.

---

## Entidades

**Cliente**
Empresa compradora (ex: rede hoteleira) que realiza Pedidos via app_cliente ou portal web. Identificado por telefone.

**Funcionário**
Usuário interno da panificadora. Possui um Perfil que determina o que pode fazer no app_prestador.

**Perfil**
Papel de um Funcionário. Valores possíveis: `ADM`, `FUNCIONARIO`.

**Pedido**
Solicitação de compra feita por um Cliente contendo um ou mais Itens de Pedido. Possui um Status que avança ao longo do ciclo de produção.

**Item de Pedido**
Linha de um Pedido: produto + quantidade + preço unitário no momento da compra.

**Produto**
Bem produzido pela panificadora disponível para pedido. Possui preço vigente.

**Anotação de Separação**
Registro da divergência entre o que foi pedido e o que foi efetivamente entregue, por **Produto**. Mantém **os dois números**: quantidade pedida e quantidade entregue. Pode incluir Produtos que **não estavam no Pedido original** (quantidade pedida = 0) — ex.: sobra de produção que o Cliente leva na hora. Criada no momento da entrega (transição `E → C`), antes de o Pedido entrar em uma Fatura. Quando um Pedido possui Anotação de Separação, seu **valor faturável** passa a ser a soma de (quantidade entregue × preço) — é a fonte da verdade do faturamento. Sem Anotação, o valor faturável é o que foi pedido. Origem das divergências: sobra ou falta na produção.

**Lista de Produção**
Projeção **efêmera** (sem histórico arquivado) gerada quando o Funcionário aciona "Gerar Lista de Produção". A ação transiciona **todos** os Pedidos em `Recebido (P)` no instante do acionamento para `Em Produção (A)` e devolve, em uma única lista, o **total de cada Produto a produzir** — a soma das quantidades de todos os Pedidos da onda, expresso em **unidades**. A conversão das unidades para capacidade de produção (telas/armários) é feita pelo ADM fora do sistema; sua automação é uma lacuna conhecida.

---

## Financeiro (planejado — Fase 2)

**Fatura**
Agrupamento de Pedidos com status `C` (Entregue) de um Cliente dentro de um Período de Faturamento. Criada manualmente pelo Funcionário via botão "Fechar Fatura"; futuramente por job automático. Pedidos em andamento ou cancelados não entram na Fatura — ficam para o próximo período.

Um Pedido entra em **no máximo uma Fatura**. Pedidos entregues após o fechamento (entrega atrasada) entram na próxima Fatura. O valor de cada Pedido na Fatura é seu **valor faturável**: a quantidade efetivamente entregue quando há Anotação de Separação, ou o que foi pedido quando não há.

Ciclo de vida da Fatura:
```
ABERTA → PARCIALMENTE_PAGA → PAGA
   ↓
VENCIDA
```

| Status             | Significado                                                    |
|--------------------|----------------------------------------------------------------|
| `ABERTA`           | Fatura fechada, aguardando pagamento                          |
| `PARCIALMENTE_PAGA`| Um ou mais Pagamentos registrados, mas valor total não quitado|
| `PAGA`             | Soma dos Pagamentos cobre o valor total da Fatura             |
| `VENCIDA`          | Prazo de pagamento expirado sem quitação total                |

**Período de Faturamento**
Ciclo de cobrança de um Cliente: `DIARIO`, `SEMANAL` ou `MENSAL`. Definido pela Panificadora no cadastro do Cliente — o Cliente visualiza mas não altera.

**Pagamento**
Liquidação total ou parcial de uma Fatura pelo Cliente. Formas aceitas: `PIX`, `DINHEIRO`, `CREDITO`. Múltiplos Pagamentos podem ser registrados contra a mesma Fatura. O backend recalcula o status da Fatura a cada Pagamento comparando a soma dos Pagamentos com o valor total.

**Crédito do Cliente**
Saldo a favor do Cliente, gerado quando um Pagamento excede o saldo devedor de uma Fatura. O excedente fica disponível e é abatido **automaticamente** no fechamento da próxima Fatura, registrado como um Pagamento com forma `CREDITO`. O Crédito é rastreado em um razão (ledger): cada geração e cada consumo é uma movimentação vinculada à Fatura de origem. O Cliente visualiza seu saldo na aba de assinaturas.

> O campo `ciclo_faturamento` precisa ser adicionado à tabela `clientes` quando o Financeiro for implementado.

---

## Ciclo de vida do Pedido

O Status de um Pedido segue o fluxo abaixo. Transições só avançam — não há retrocesso.

```
P → A → S → E → C
         ↑
    (X cancela apenas de P)
```

| Código | Nome          | Significado                                      |
|--------|---------------|--------------------------------------------------|
| `P`    | Recebido      | Pedido criado pelo Cliente, aguardando produção  |
| `A`    | Em Produção   | Aceito pelo Funcionário, linha de produção ativa |
| `S`    | Separado      | Produção concluída, aguardando carregamento      |
| `E`    | Em Entrega    | Carga despachada, em trânsito para o Cliente     |
| `C`    | Entregue      | Recebimento confirmado                           |
| `X`    | Cancelado     | Pedido cancelado (somente a partir de `P`)       |

**Regras de transição:**
- Qualquer Funcionário (independente do Perfil) pode avançar o status de qualquer Pedido.
- Cancelamento (`→ X`) só é permitido a partir de `P`.
- Não existe retrocesso de status.

**Edição de Itens de Pedido:**
- Permitida somente nos status `P` e `A`.
- Operações permitidas: alterar quantidade, remover item, adicionar novo item.
- O recálculo de `preco_unitario`, `valor_total_item` e `valor_total` do Pedido é sempre feito pelo backend com o preço vigente do Produto no banco.
- Depois de `A`, o Pedido não é mais editável; ajustes de quantidade na entrega são registrados como Anotação de Separação (na transição `E → C`), preservando o que foi pedido.
- Edições são refletidas automaticamente no app_cliente via polling (sem notificação explícita).
- Toda edição de itens publica o evento `pedido.itens.atualizados` no sistema de mensageria.
- Um Pedido deve ter no mínimo 1 Item de Pedido. Remoção do último item é rejeitada pelo backend — o Funcionário deve cancelar o Pedido explicitamente.

> **Impacto técnico pendente:** o banco de dados e o backend atualmente suportam apenas P, A, C, X. Os status S e E precisam ser adicionados antes da implementação do app_prestador.
