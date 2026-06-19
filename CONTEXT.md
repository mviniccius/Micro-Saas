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

---

## Financeiro (planejado — Fase 2)

**Fatura**
Agrupamento de Pedidos de um Cliente dentro de um Período de Faturamento. Gerada automaticamente ao fechar o período.

**Período de Faturamento**
Ciclo de cobrança de um Cliente: `DIARIO`, `SEMANAL` ou `MENSAL`. Definido pela Panificadora no cadastro do Cliente — o Cliente visualiza mas não altera.

**Pagamento**
Liquidação total ou parcial de uma Fatura pelo Cliente.

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
- A partir de `S`, divergências são registradas como Anotação de Separação (Fase 2).
- Edições são refletidas automaticamente no app_cliente via polling (sem notificação explícita).
- Toda edição de itens publica o evento `pedido.itens.atualizados` no sistema de mensageria.
- Um Pedido deve ter no mínimo 1 Item de Pedido. Remoção do último item é rejeitada pelo backend — o Funcionário deve cancelar o Pedido explicitamente.

> **Impacto técnico pendente:** o banco de dados e o backend atualmente suportam apenas P, A, C, X. Os status S e E precisam ser adicionados antes da implementação do app_prestador.
