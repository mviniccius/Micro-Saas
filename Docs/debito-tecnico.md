# Débito Técnico

## [AUTH-01] Autenticação JWT e controle de acesso por perfil

**Status:** Pendente  
**Prioridade:** Alta  
**Contexto:** Adiado para facilitar o desenvolvimento das sprints 3 e 4.

### O que precisa ser feito

1. **Rota `POST /auth/login`**
   - Receber `email` e `senha` do body
   - Buscar usuário no banco pelo email
   - Comparar senha com `bcrypt.compare()`
   - Retornar token JWT com `{ id, email, perfil_id }` e expiração de 8h

2. **Atualizar `POST /users`**
   - Passar `perfil_id` ao criar usuário
   - Fazer hash da senha com `bcrypt.hash()` antes de salvar

3. **Aplicar middlewares nas rotas protegidas**
   - `autenticar` — valida o token (já implementado em `middleware/autenticar.js`)
   - `autorizar(perfilId)` — valida o perfil (já implementado em `middleware/autorizar.js`)

4. **Seed dos perfis no banco**
   - `id_perfil = 1` → ADM (acesso total)
   - `id_perfil = 2` → FUNCIONARIO (acesso somente a `/pedidos`)

### Pacotes já instalados
- `jsonwebtoken@9.0.3`
- `bcrypt@6.0.0`

### Arquivos já criados
- `Back/middleware/autenticar.js`
- `Back/middleware/autorizar.js`
- `Back/.env` — contém `JWT_SECRET`

---

## [UI-01] Paleta de cores do app cliente

**Status:** Concluído — Sprint 3/4**  
**Prioridade:** Baixa  
**Contexto:** Design system "Legacy Artisanal" aplicado: Verde Efraim (#173426), Dourado Legado (#79591D), Creme Trigo (#fcf9f8). Fontes Cinzel (headlines) + Montserrat (body). Aplicado em app_cliente, front/ e pendente no app_prestador.

---

## [AUDIT-01] Rastreabilidade de alterações de status e itens

**Status:** Pendente  
**Prioridade:** Média  
**Contexto:** Nenhuma mudança de status ou de itens registra quem fez a alteração. A tabela pedidos só guarda update_at (quando), não quem alterou.

### O que precisa ser feito

1. **Banco de dados — opção recomendada: tabela de histórico**
   - Criar tabela historico_pedido: id, id_pedido (FK), tipo (STATUS | ITENS), id_usuario (FK), payload JSON, created_at
   - Alternativa mais simples: coluna alterado_por na tabela pedidos (perde histórico)

2. **Backend**
   - Receber id_usuario no PATCH /pedidos/:id/status e no PUT /pedidos/:id/itens
   - Inserir linha em historico_pedido a cada transição ou edição de itens

3. **app_prestador**
   - Enviar id_usuario autenticado no header ou body das requisições de alteração

### Dependências
- Requer [AUTH-01] implementado (sem JWT não há id_usuario confiável)

---

## [FIN-01] Gestão financeira e faturamento

**Status:** Em andamento — backend e app_cliente concluídos (ver `docs/adr/0002-modelo-financeiro-faturamento.md`)  
**Prioridade:** Média  
**Contexto:** Modelo financeiro definido no ADR-0002. Backend e visão do cliente já implementados; falta o fechamento automático por ciclo e as telas do app_prestador.

### Conceitos implementados (ADR-0002)
- **Fatura:** agrupamento de Pedidos de um Cliente por Período de Faturamento (ciclo de vida `ABERTA` → `PARCIALMENTE_PAGA` → `PAGA`, mais `VENCIDA` manual)
- **Período de Faturamento:** ciclo `DIARIO`, `SEMANAL` ou `MENSAL` — definido pela Panificadora por Cliente
- **Pagamento:** liquidação (total ou parcial) de uma Fatura — `PIX`, `DINHEIRO` ou `CREDITO` (interno)
- **Crédito do Cliente:** ledger `creditos_cliente` (`GERADO`/`CONSUMIDO`) para sobras de pagamento

### Concluído
- [x] Banco: `ciclo_faturamento` em `clientes`; tabelas `faturas`, `pagamentos`, `creditos_cliente`; FK `id_fatura` em `pedidos` (init.sql + migration `002-financeiro.sql`)
- [x] Backend: `service/faturaService.js`, `controllers/faturaController.js`, `routers/faturasRouters.js`
  - `GET /faturas/cliente/:id_cliente` — resumo financeiro (faturas + saldo de crédito + histórico)
  - `POST /faturas/fechar` — fecha fatura agrupando pedidos entregues não faturados
  - `POST /faturas/:id/pagamento` — registra pagamento (parcial/total, com geração de crédito no excesso)
- [x] app_cliente: aba Financeiro conectada à API real (sem mock)

### Pendente
1. **Fechamento automático por ciclo** — job periódico para fechar faturas e abrir novas conforme `ciclo_faturamento` (hoje o fechamento é manual via `POST /faturas/fechar`)
2. **app_prestador**
   - Tela de consulta de faturas por cliente
   - Tela de registro de pagamento no recebimento (PIX/DINHEIRO)
3. **front/ (portal B2B)**
   - FinanceiroView já tem UI mockada — conectar à API real
4. **PIX dinâmico** — hoje a chave PIX é estática (MVP); integrar gateway (Efí ou Asaas) para cobrança com QR/identificador por fatura

---

## [FISCAL-01] Emissão de NF-e real

**Status:** Pendente  
**Prioridade:** Baixa  
**Contexto:** Decidido no ADR-0002 adiar a emissão fiscal real. O sistema controla faturas e pagamentos internamente, mas não emite documento fiscal eletrônico.

### O que precisa ser feito

1. **Integração com SEFAZ / provedor de NF-e**
   - Avaliar provedor (ex.: Focus NF-e, NFe.io, eNotas) vs. integração direta com a SEFAZ
   - Certificado digital A1/A3 da empresa

2. **Banco de dados**
   - Vincular documento fiscal à `fatura` (ou ao `pedido`): chave de acesso, número, série, status, XML/DANFE

3. **Backend**
   - Endpoint para emitir NF-e a partir de uma fatura
   - Tratamento de rejeições/contingência da SEFAZ

### Dependências
- Requer [FIN-01] estável (a fatura é a base do documento fiscal)

---

## [PROD-01] Conversão de unidades para telas/armários na Lista de Produção

**Status:** Pendente — depende de regras do ADM  
**Prioridade:** Baixa  
**Contexto:** A Lista de Produção (MVP) mostra o total a produzir em **unidades** por Produto. O ADM, na prática, converte esse total em **capacidade de produção** (telas/armários) manualmente. Falta levantar com ele a regra de conversão antes de automatizar.

### O que precisa ser feito (após levantamento)

1. **Levantar com o ADM**
   - A conversão é um fator fixo por Produto (ex.: 30 pães/tela)? Varia?
   - O que é "tela" e o que é "armário" — e como se relacionam (1 armário = N telas)?

2. **Banco / Backend**
   - Provável: atributo de rendimento por tela/armário no Produto
   - Lista de Produção passa a exibir unidades **e** telas/armários

---

## [SEP-01] Anotações de Separação

**Status:** Pendente — desenhado (ver `CONTEXT.md` e `docs/adr/0003-anotacao-separacao-valor-faturavel.md`)  
**Prioridade:** Média  
**Contexto:** Registra a divergência entre o que foi pedido e o que foi entregue, por Produto, na entrega (`E → C`). Mantém os dois números e pode incluir Produtos fora do Pedido. **Impacto no Financeiro:** a Fatura passa a cobrar o valor entregue (valor faturável). Implementar **após** a Lista de Produção, por mexer no Financeiro já entregue (ADR-0002).

### O que precisa ser feito

1. **Banco de dados**
   - Criar tabela `anotacoes_separacao` — `id_pedido` (FK), `id_produto` (FK), `quantidade_pedida`, `quantidade_entregue`, `created_at`
   - `quantidade_pedida = 0` para Produto entregue que não estava no Pedido

2. **Backend**
   - `POST /pedidos/:id/separacao` — registra a Anotação na confirmação de entrega (`E → C`)
   - `fecharFatura` e o cálculo de valor do Pedido passam a usar o **valor faturável** (∑ quantidade entregue × preço) quando há Anotação

3. **app_prestador**
   - Tela de confirmação de entrega: lista itens do Pedido com quantidade entregue editável + permite adicionar Produto do catálogo (sobra)

