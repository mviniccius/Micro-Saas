# Plano de Implementação — app_prestador

**Data:** 2026-06-17  
**Baseado em:** CONTEXT.md + ADR-0001 + Docs/debito-tecnico.md

---

## O que precisa ser feito (em ordem de dependência)

---

### 1. Backend — Migração de status (pré-requisito)

O backend precisa reconhecer `S` e `E` antes de qualquer tela do app_prestador.

**Arquivo:** `Back/service/pedidoService.js`
- Garantir que `PATCH /pedidos/:id/status` aceite `S` e `E` como valores válidos
- Atualizar validação de transições permitidas: `P→A`, `A→S`, `S→E`, `E→C`, `P→X`

**Arquivo:** `Back/db/init.sql`
- Documentar os 6 valores válidos (o campo `char(1)` já suporta, é só documentação)

**Nenhuma migração de dados necessária** — pedidos existentes com `A` e `C` continuam válidos.

---

### 2. Backend — Endpoint de edição de itens (novo)

Não existe endpoint para editar itens de um pedido. Precisa ser criado.

**Nova rota:** `PUT /pedidos/:id/itens`

**Payload esperado:**
```json
{
  "itens": [
    { "id_produto": 1, "quantidade": 180 },
    { "id_produto": 5, "quantidade": 50 }
  ]
}
```

**Regras que o backend deve aplicar:**
1. Rejeitar se `status` não for `P` ou `A`
2. Rejeitar se `itens` estiver vazio (mínimo 1 item)
3. Apagar todos os `itens_pedido` do pedido e reinserir (substituição total)
4. Buscar `preco_unitario` de cada `id_produto` no banco (nunca confiar no app)
5. Recalcular `valor_total_item` e `valor_total` do pedido
6. Publicar evento `pedido.itens.atualizados` no RabbitMQ com `{ id_pedido, itens }`

**Arquivos a criar/alterar:**
- `Back/routers/pedidosRouters.js` — adicionar rota `PUT /:id/itens`
- `Back/controllers/pedidoController.js` — novo método `atualizarItens`
- `Back/service/pedidoService.js` — lógica de substituição + recálculo

---

### 3. app_prestador — Design system

Aplicar o design system "Legacy Artisanal" antes de criar as telas.

**Arquivos a criar/alterar:**
- Criar `app_prestador/lib/theme.dart` — copiar de `app_cliente/lib/theme.dart`
- Alterar `app_prestador/lib/main.dart` — usar `efraimTheme`
- Adicionar `google_fonts` ao `app_prestador/pubspec.yaml`

---

### 4. app_prestador — Telas

#### Tela 1 — LoginScreen (refatorar existente)
- Aplicar design system (Cinzel + Montserrat + Verde/Dourado)
- Comportamento já funciona — só visual

#### Tela 2 — PedidosScreen (refatorar existente)
- Aplicar design system
- Atualizar fluxo de status: `{'P': 'A', 'A': 'S', 'S': 'E', 'E': 'C'}`
- Adicionar navegação para tela de detalhe ao tocar no card
- Manter polling de 10s

#### Tela 3 — PedidoDetalheScreen (nova)
- Exibe todos os itens do pedido com nome do produto, quantidade e valor
- Botões de avançar status / cancelar (regras do CONTEXT.md)
- Botão "Editar Itens" (visível apenas se status `P` ou `A`)

#### Tela 4 — EditarItensPedidoScreen (nova)
- Lista itens existentes com seletor de quantidade (+/-)
- Botão para remover item
- Busca/lista de produtos disponíveis para adicionar
- Botão "Salvar" chama `PUT /pedidos/:id/itens`
- Backend rejeita se tentar salvar com 0 itens

---

### 5. app_prestador — Services (atualizar/criar)

**`pedido_service.dart`** — adicionar:
```dart
Future<void> atualizarItens(int idPedido, List<Map<String, dynamic>> itens)
```

**`produto_service.dart`** — criar (para a tela de adicionar item):
```dart
Future<List<Produto>> listarProdutos()
```

**`auth_service.dart`** — corrigir URL base:
- Trocar `http://localhost:3000` por `http://10.0.2.2:3000` (emulador Android)

---

## Ordem de execução recomendada

```
1. Backend: validar S e E no PATCH /pedidos/:id/status
2. Backend: criar PUT /pedidos/:id/itens
3. app_prestador: aplicar design system (theme.dart + main.dart)
4. app_prestador: refatorar LoginScreen
5. app_prestador: refatorar PedidosScreen (novo fluxo de status)
6. app_prestador: criar PedidoDetalheScreen
7. app_prestador: criar EditarItensPedidoScreen
```

---

## Débitos técnicos gerados por este plano

| ID | Descrição | Prioridade |
|----|-----------|-----------|
| `[AUTH-01]` | JWT + bcrypt antes de produção | Alta |
| `[FIN-01]` | Gestão de faturas e pagamentos | Média |
| `[SEP-01]` | Anotações de separação (Fase 2) | Média |

---

## O que NÃO está neste plano (fora do escopo da sprint)

- Notificação push para o Cliente quando pedido é editado
- Controle de estoque / disponibilidade de produto
- Relatórios de produção
- Distinção de permissão por etapa do fluxo (ex: só separador muda P→S)
