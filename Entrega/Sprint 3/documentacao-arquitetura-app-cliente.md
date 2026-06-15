# Documentação de Arquitetura – App Cliente (Sprint 3)

**Disciplina:** Lab. de Desenvolvimento de Aplicações Móveis e Distribuídas  
**Aluno:** mViniccius  
**Data:** 15/06/2026  
**Sprint:** 3 – Aplicativo Flutter para o Cliente

---

## 1. Visão Geral

O `app_cliente` é um aplicativo Flutter destinado ao usuário final do sistema de delivery de padaria. Ele permite que o cliente se identifique, visualize o catálogo de produtos, monte e confirme pedidos, e acompanhe o status dos seus pedidos em tempo real (via polling assíncrono).

---

## 2. Arquitetura em Camadas (Clean Architecture)

O app segue a separação de responsabilidades em três camadas principais:

```
app_cliente/
└── lib/
    ├── main.dart                        ← Ponto de entrada, inicializa o MaterialApp
    │
    ├── presentation/
    │   └── screens/                     ← Camada de Apresentação (UI)
    │       ├── login_screen.dart
    │       ├── home_screen.dart
    │       ├── criar_pedido_screen.dart
    │       └── meus_pedidos_screen.dart
    │
    └── data/
        ├── models/                      ← Camada de Dados – Modelos
        │   ├── cliente_model.dart
        │   ├── produto_model.dart
        │   └── pedido_model.dart
        └── services/                    ← Camada de Dados – Serviços (HTTP)
            ├── cliente_service.dart
            ├── produto_service.dart
            └── pedido_service.dart
```

### Diagrama de dependências

```
┌──────────────────────────────────────────────────┐
│               PRESENTATION LAYER                 │
│  LoginScreen → HomeScreen → CriarPedidoScreen    │
│                          → MeusPedidosScreen     │
└─────────────────────┬────────────────────────────┘
                      │ usa (injeção direta)
┌─────────────────────▼────────────────────────────┐
│                  DATA LAYER                      │
│                                                  │
│  Services (HTTP/REST)     Models (Dart classes)  │
│  ClienteService     ◄──►  Cliente                │
│  ProdutoService     ◄──►  Produto                │
│  PedidoService      ◄──►  Pedido, ItemPedido     │
└─────────────────────┬────────────────────────────┘
                      │ HTTP (dart:http)
┌─────────────────────▼────────────────────────────┐
│               BACKEND REST                       │
│         Node.js / Express – localhost:3000       │
│  GET  /clientes/telefone/:tel                    │
│  POST /clientes                                  │
│  GET  /produtos                                  │
│  POST /pedidos                                   │
│  GET  /pedidos/telefone/:tel                     │
└──────────────────────────────────────────────────┘
```

---

## 3. Telas implementadas

### 3.1 LoginScreen (`login_screen.dart`)

**Responsabilidade:** identificar o cliente pelo nome e telefone.

**Fluxo:**
1. Usuário preenche nome e telefone.
2. O app chama `ClienteService.buscarPorTelefone()` (GET `/clientes/telefone/:tel`).
3. Se o cliente já existe, reutiliza o registro. Se não, chama `ClienteService.criarCliente()` (POST `/clientes`).
4. Navega para `HomeScreen`, passando o objeto `Cliente` como parâmetro.

**Decisão de design:** não há senha — o telefone é o identificador único do cliente, o que simplifica o fluxo para um sistema interno de uso rápido no balcão.

---

### 3.2 HomeScreen (`home_screen.dart`)

**Responsabilidade:** exibir o catálogo de produtos e permitir montar o carrinho.

**Fluxo:**
1. Ao entrar, carrega produtos via `ProdutoService.listarProdutos()` (GET `/produtos`).
2. Cada produto é exibido em um `_ProdutoCard` com controles de quantidade (−, campo numérico, +).
3. Quando o total de itens > 0, aparece um botão flutuante "Ver pedido (N itens)".
4. Ao confirmar, navega para `CriarPedidoScreen` com a lista de itens selecionados.
5. Ao retornar de `CriarPedidoScreen`, o carrinho é zerado automaticamente.

**Acesso à tela "Meus Pedidos":** via ícone no `AppBar` (canto superior direito).

---

### 3.3 CriarPedidoScreen (`criar_pedido_screen.dart`)

**Responsabilidade:** exibir o resumo do pedido e confirmar o envio.

**Fluxo:**
1. Recebe os itens selecionados de `HomeScreen`.
2. Lista cada item com nome, preço unitário, quantidade e subtotal.
3. Exibe o total geral na barra inferior.
4. Ao confirmar, chama `PedidoService.criarPedido()` (POST `/pedidos`) com `id_cliente` e lista de itens.
5. O backend valida o preço no banco (o app não envia preço, apenas `id_produto` e `quantidade` — medida de segurança).
6. Ao sucesso, retorna para `HomeScreen` com o carrinho zerado.

---

### 3.4 MeusPedidosScreen (`meus_pedidos_screen.dart`)

**Responsabilidade:** listar os pedidos do cliente com seus status atuais e atualizar automaticamente.

**Fluxo:**
1. Ao entrar, busca pedidos via `PedidoService.buscarPedidosPorTelefone()` (GET `/pedidos/telefone/:tel`).
2. Inicia um `Timer.periodic` com intervalo de **10 segundos** que re-executa a busca automaticamente (polling assíncrono).
3. O timer é cancelado no `dispose()` para evitar memory leak.
4. O usuário também pode atualizar manualmente via ícone de refresh no `AppBar` ou via `RefreshIndicator` (pull-to-refresh).

**Status exibidos:**

| Código | Rótulo      | Cor       |
|--------|-------------|-----------|
| `P`    | Pendente    | Laranja   |
| `A`    | Em Produção | Azul      |
| `C`    | Concluído   | Verde     |
| `X`    | Cancelado   | Vermelho  |

**Implementação do polling:**
```dart
_timer = Timer.periodic(
  const Duration(seconds: 10),
  (_) => _buscarPedidos(),
);
```

---

## 4. Modelos de dados

### Cliente
```dart
class Cliente {
  final int idCliente;
  final String nome;
  final String telefone;
  final bool active;
}
```

### Produto
```dart
class Produto {
  final int idProduto;
  final String nomeProduto;
  final double preco;
}
```

### Pedido e ItemPedido
```dart
class Pedido {
  final int idPedido;
  final int idCliente;
  final double valorTotal;
  final String status;      // 'P', 'A', 'C', 'X'
  final List<ItemPedido> itens;
}

class ItemPedido {
  final int idProduto;
  final int quantidade;
  final double precoUnitario;
  final double valorTotalItem;
}
```

---

## 5. Integração com o Backend REST

Todos os serviços usam o pacote `http` do Flutter. A URL base é `http://localhost:3000`.

| Serviço           | Método | Endpoint                        | Uso                              |
|-------------------|--------|---------------------------------|----------------------------------|
| ClienteService    | GET    | `/clientes/telefone/:telefone`  | Busca cliente existente          |
| ClienteService    | POST   | `/clientes`                     | Cadastra novo cliente            |
| ProdutoService    | GET    | `/produtos`                     | Lista todos os produtos          |
| PedidoService     | POST   | `/pedidos`                      | Cria novo pedido                 |
| PedidoService     | GET    | `/pedidos/telefone/:telefone`   | Lista pedidos do cliente         |

---

## 6. Atualização assíncrona de estado

O requisito de atualização assíncrona foi implementado via **polling com intervalo fixo de 10 segundos** na `MeusPedidosScreen`. Quando o prestador atualiza o status de um pedido no backend, o app do cliente reflete a mudança automaticamente na próxima ciclo do timer — sem necessidade de ação manual do usuário.

Essa abordagem foi escolhida em vez de WebSocket pelo equilíbrio entre simplicidade de implementação e eficácia para o volume de operações de um sistema interno de padaria.

---

## 7. Fluxo de navegação

```
LoginScreen
    │
    └──► HomeScreen (com objeto Cliente)
              │
              ├──► CriarPedidoScreen (com itens selecionados)
              │         │
              │         └──► (retorna para HomeScreen ao confirmar)
              │
              └──► MeusPedidosScreen (polling 10s automático)
```

---

## 8. Código-fonte

Disponível em: [repositório Git do projeto]

Instruções de execução:
```bash
cd app_cliente
flutter pub get
flutter run
```

> O backend deve estar em execução na porta 3000 (`make dev` ou `docker compose up` na pasta `Back/`).
