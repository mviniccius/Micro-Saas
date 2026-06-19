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

**Status:** Pendente  
**Prioridade:** Média  
**Contexto:** Adiado para depois da implementação core do app_prestador.

### Conceitos a implementar
- **Fatura:** agrupamento de Pedidos de um Cliente por Período de Faturamento
- **Período de Faturamento:** ciclo `DIARIO`, `SEMANAL` ou `MENSAL` — definido pela Panificadora por Cliente
- **Pagamento:** liquidação de uma Fatura

### O que precisa ser feito

1. **Banco de dados**
   - Adicionar `ciclo_faturamento ENUM('DIARIO','SEMANAL','MENSAL')` na tabela `clientes`
   - Criar tabela `faturas` — `id_fatura`, `id_cliente`, `periodo_inicio`, `periodo_fim`, `valor_total`, `status` (`ABERTA`, `PAGA`, `VENCIDA`)
   - Criar tabela `pagamentos` — `id_pagamento`, `id_fatura`, `valor`, `data_pagamento`, `forma_pagamento`

2. **Backend**
   - `GET /faturas/:id_cliente` — lista faturas do cliente
   - `POST /faturas/:id/pagamento` — registra pagamento
   - Job periódico para fechar faturas e abrir novas por ciclo

3. **app_prestador**
   - Tela de consulta de faturas por cliente
   - Tela de registro de pagamento no recebimento

4. **front/ (portal B2B)**
   - FinanceiroView já tem UI mockada — conectar à API real

---

## [SEP-01] Anotações de Separação

**Status:** Pendente  
**Prioridade:** Média  
**Contexto:** Fase 2 do sistema. Separador registra divergências na entrega.

### O que precisa ser feito

1. **Banco de dados**
   - Criar tabela `anotacoes_separacao` — `id_pedido` (FK), `id_produto` (FK), `quantidade_pedida`, `quantidade_entregue`, `motivo`, `created_at`

2. **Backend**
   - `POST /pedidos/:id/separacao` — registra divergências por item

3. **app_prestador**
   - Tela de separação: lista itens do pedido, permite informar quantidade real entregue

