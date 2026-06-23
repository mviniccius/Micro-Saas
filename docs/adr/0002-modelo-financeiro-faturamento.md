# ADR-0002 — Modelo financeiro: faturamento, pagamentos e crédito

**Data:** 2026-06-23
**Status:** Aceito

---

## Contexto

O sistema precisa cobrar os Clientes (empresas B2B) pelos Pedidos entregues. Até aqui não existia nenhuma estrutura de cobrança — nem tabela, nem rota. A `FinanceiroView.vue` (portal web) e a aba Financeiro do `app_cliente` tinham apenas UI com dados mockados.

O domínio (ver `CONTEXT.md`) define três conceitos: **Fatura** (agrupamento de Pedidos por período), **Pagamento** (liquidação total ou parcial) e **Período de Faturamento** (`DIARIO`/`SEMANAL`/`MENSAL`). Durante o desenho surgiu um quarto conceito: **Crédito do Cliente** (excedente de pagamento abatido em faturas futuras).

Esta ADR registra as decisões estruturais tomadas para o MVP financeiro.

## Decisão

### 1. Vínculo Pedido → Fatura por coluna `id_fatura` (nullable) no Pedido

Cada Pedido aponta para no máximo uma Fatura. O fechamento agrupa os Pedidos com `status = 'C'` e `id_fatura IS NULL`.

### 2. Fechamento manual primeiro, automático depois

A primeira versão fecha a Fatura por ação humana (rota `POST /faturas/fechar`). O job automático por ciclo entra numa fase futura, reusando a mesma lógica de service.

### 3. Apenas Pedidos entregues (`C`) entram na Fatura

Pedidos em andamento ou cancelados não são cobrados. Entrega atrasada entra na próxima Fatura (continua com `id_fatura NULL`).

### 4. Status da Fatura recalculado pelo backend

`ABERTA → PARCIALMENTE_PAGA → PAGA` é derivado da soma dos Pagamentos vs. `valor_total`. `VENCIDA` é marcado manualmente (sem job de vencimento no MVP).

### 5. Pagamentos parciais e múltiplas formas

Uma Fatura aceita vários Pagamentos. `forma_pagamento ∈ {PIX, DINHEIRO, CREDITO}`.

### 6. Crédito do Cliente rastreado em ledger

Pagamento que excede o saldo devedor gera Crédito. O saldo nunca é uma coluna solta: cada geração e consumo é uma linha em `creditos_cliente` (`tipo ∈ {GERADO, CONSUMIDO}`). O saldo é a soma do ledger. O Crédito é abatido automaticamente no fechamento da próxima Fatura, registrado como um Pagamento de forma `CREDITO`.

### 7. PIX estático no MVP

Sem gateway integrado (Efí/Asaas adiados). O `app_cliente` exibe uma chave PIX copia-e-cola; a confirmação entra como Pagamento manual registrado pelo Funcionário.

## Alternativas consideradas

**Tabela de junção `fatura_pedidos`** (em vez de `id_fatura` no Pedido): permitiria um Pedido em várias Faturas — flexibilidade que o negócio não quer. A coluna `id_fatura` elimina a dupla cobrança por construção e dispensa lógica de intervalo de datas no fechamento. Descartada por complexidade desnecessária.

**Saldo de crédito como coluna `saldo_credito` em `clientes`**: mais simples de ler, mas perde a história de como o saldo se formou. Como é dinheiro guardado do Cliente, optou-se pela rastreabilidade do ledger — o projeto já tem o `[AUDIT-01]` como dor conhecida e não vale criar mais um ponto cego no financeiro.

**Período por calendário contínuo** (início = dia seguinte ao fim da fatura anterior): cria dependência de estado entre faturas. Optou-se por `periodo_inicio = MIN(created_at)` dos Pedidos faturados e `periodo_fim = data do fechamento` — reflete exatamente o que está sendo cobrado, sem estado extra.

**NF-e real**: registrada como débito técnico `[FISCAL-01]`. Exige CNPJ, certificado digital e integração com SEFAZ/intermediário — escopo próprio, fora desta rodada.

## Consequências

**Positivas:**
- Dupla cobrança impossível por construção (`id_fatura NULL`).
- Crédito totalmente auditável (de qual fatura veio, em qual foi gasto).
- Modelo de dados estável quando o gateway PIX entrar: troca-se a tela estática por QR dinâmico + webhook sem mexer no schema.

**Negativas / custos:**
- O período exibido usa `created_at` do Pedido, não a data real de entrega (que dependeria de `[AUDIT-01]`). Aproximação aceita para o MVP.
- Pagamento que excede o saldo é dividido: a parte que quita a Fatura vira Pagamento, o excedente vira Crédito GERADO. O extrato mostra os dois registros em vez de um único valor recebido.
- Três tabelas novas (`faturas`, `pagamentos`, `creditos_cliente`) e uma coluna em `clientes` e outra em `pedidos`.
