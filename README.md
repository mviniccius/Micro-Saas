# Sistema de Gestao — Panificadora Efraim

Sistema interno de gestao de pedidos desenvolvido como Projeto Integrador da disciplina **Lab. de Desenvolvimento de Aplicacoes Moveis e Distribuidas** — Engenharia de Software, 5 Periodo, PUC Minas (1 Semestre 2026).

O sistema digitaliza o fluxo de pedidos de uma padaria artesanal: funcionarios registram e gerenciam pedidos pelo painel interno, enquanto clientes acompanham o status pelo app movel — sem precisar ligar ou comparecer ao estabelecimento.

---

## Arquitetura

```mermaid
graph TD
    A[Web - Vue.js\nPainel interno do funcionario] -->|HTTP/REST| C
    B[app_cliente - Flutter\nPortal do cliente] -->|HTTP/REST| C
    D[app_prestador - Flutter\nApp do funcionario] -->|HTTP/REST| C

    subgraph API["API - Node.js + Express"]
        C[Rotas / Controllers]
        E[Services / Regras de Negocio]
        C --> E
    end

    E -->|leitura/escrita| F[(PostgreSQL - Supabase)]
    E -->|publica evento| G([RabbitMQ - topic exchange])

    G -->|fila_pedido_criado| H[Worker - Linha de Producao]
    G -->|fila_pedido_status| I[Worker - Notificacoes de Status]

    F & G -.Docker.- J[compose.yaml]
```

---

## Tecnologias

| Camada       | Tecnologia                        | Versao / Detalhe                    |
|--------------|-----------------------------------|--------------------------------------|
| Backend      | Node.js + Express                 | Node 20, Express 5                   |
| Painel web   | Vue.js                            | via Vite                             |
| App cliente  | Flutter                           | SDK 3.12+, roda no Chrome (porta 4200) |
| App prestador| Flutter                           | SDK 3.12+, roda no Chrome (porta 4201) |
| Banco de dados | PostgreSQL                      | hospedado no Supabase (producao) ou local via variavel de ambiente |
| Mensageria   | RabbitMQ 3                        | topic exchange `padaria_events`, imagem `rabbitmq:3-management` |
| Infra        | Docker + Docker Compose           | orquestra API Node.js + RabbitMQ     |
| Documentacao | Swagger / OpenAPI                 | disponivel em `/api-docs`            |

---

## Estrutura do Projeto

```
Micro-Saas/
├── Back/                   # API REST (Node.js + Express)
│   ├── controllers/        # Entrada e saida HTTP
│   ├── service/            # Regras de negocio e queries
│   ├── routers/            # Definicao de rotas (clientes, pedidos, produtos, auth)
│   ├── database/           # Conexao com PostgreSQL (pg Pool)
│   ├── messaging/          # Publisher e Consumer do RabbitMQ
│   ├── scripts/            # Seeds e setup do MOM
│   ├── db/init.sql         # Schema inicial do banco
│   ├── swagger.js          # Configuracao do Swagger
│   └── compose.yaml        # Docker: API Node.js + RabbitMQ
├── app_cliente/            # App Flutter do cliente (portal de acompanhamento)
├── app_prestador/          # App Flutter do funcionario (gestao de pedidos)
├── front/                  # Painel web Vue.js (funcionario, via Vite)
├── docs/
│   └── adr/                # Architecture Decision Records
├── Entrega/                # Documentos de entrega por sprint
│   ├── Sprint 1/
│   ├── Sprint 2/
│   └── Sprint 3/
└── Makefile                # Comandos de orquestracao
```

---

## Como Rodar Localmente

### Pre-requisitos

- [Node.js 20+](https://nodejs.org/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Flutter SDK 3.12+](https://docs.flutter.dev/get-started/install)

### 1. Clonar o repositorio

```bash
git clone https://github.com/mviniccius/Micro-Saas.git
cd Micro-Saas
```

### 2. Configurar variaveis de ambiente

Crie o arquivo `Back/.env` com o conteudo descrito na secao [Variaveis de Ambiente](#variaveis-de-ambiente).

### 3. Backend (API + RabbitMQ via Docker)

```bash
# Sobe a API Node.js e o RabbitMQ em segundo plano
make up

# Ver logs em tempo real
make logs
```

API disponivel em: `http://localhost:3000`
Documentacao Swagger: `http://localhost:3000/api-docs`
Painel RabbitMQ: `http://localhost:15672` (usuario: `admin`, senha: `admin`)

Alternativamente, sem o Makefile:

```bash
cd Back
docker compose up -d
```

### 4. App Cliente (Flutter)

```bash
make flutter
# equivalente a: cd app_cliente && flutter run -d chrome --web-port 4200
```

App disponivel em: `http://localhost:4200`

### 5. App Prestador (Flutter)

```bash
make flutter-prestador
# equivalente a: cd app_prestador && flutter run -d chrome --web-port 4201
```

App disponivel em: `http://localhost:4201`

### 6. Painel Web (Vue.js)

```bash
make front
# equivalente a: cd front && npm run dev
```

### 7. Subir tudo de uma vez

```bash
# Sobe backend + app_cliente + app_prestador em paralelo
make all
```

### 8. Parar tudo

```bash
make stop
```

---

## Variaveis de Ambiente

Crie o arquivo `Back/.env`. Ha duas formas de configurar o banco:

**Opcao A — Supabase (producao):**

```env
DATABASE_URL=postgresql://usuario:senha@host.supabase.co:5432/postgres
RABBITMQ_URL=amqp://admin:admin@rabbitmq:5672
```

**Opcao B — PostgreSQL local:**

```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=123
DB_NAME=padaria
RABBITMQ_URL=amqp://admin:admin@rabbitmq:5672
```

> Quando `DATABASE_URL` estiver definida, ela tem prioridade sobre as variaveis individuais `DB_*`.

Para popular o banco com dados iniciais:

```bash
cd Back
node scripts/seed.js
```

---

## Fluxo do Sistema

O ciclo de vida de um pedido percorre os seguintes estados:

```
P → A → S → E → C
    ↑
(X cancela apenas a partir de P)
```

| Codigo | Status       | Significado                                               |
|--------|--------------|-----------------------------------------------------------|
| `P`    | Recebido     | Pedido criado pelo cliente, aguardando producao           |
| `A`    | Em Producao  | Aceito pelo funcionario, linha de producao ativa          |
| `S`    | Separado     | Producao concluida, aguardando carregamento               |
| `E`    | Em Entrega   | Carga despachada, em transito para o cliente              |
| `C`    | Entregue     | Recebimento confirmado pelo cliente                       |
| `X`    | Cancelado    | Pedido cancelado (permitido somente a partir de `P`)      |

A cada avanco de status, o backend publica um evento `pedido.status_atualizado` no RabbitMQ. O `app_cliente` atualiza a visualizacao via polling a cada 10 segundos, sem intervencao do usuario.

---

## Eventos Assincronos (RabbitMQ)

Exchange: `padaria_events` (tipo: topic)

| Evento                      | Routing Key               | Disparado por                        |
|-----------------------------|---------------------------|--------------------------------------|
| Pedido criado               | `pedido.criado`           | `POST /pedidos`                      |
| Status de pedido atualizado | `pedido.status_atualizado`| `PATCH /pedidos/:id/status`          |
| Itens de pedido atualizados | `pedido.itens.atualizados`| alteracao de itens via app_prestador |

---

## Sprints

- [x] **Sprint 1** — Proposta de dominio, modelagem de dados, API REST com CRUD de clientes, produtos e pedidos, documentacao Swagger e colecao Postman
- [x] **Sprint 2** — Integracao com RabbitMQ: events `pedido.criado` e `pedido.status_atualizado`, padrão topic exchange com filas duraveis, relatorio de integracao
- [x] **Sprint 3** — `app_cliente` Flutter completo: login por telefone, catalogo de produtos, carrinho, criacao de pedido e tela "Meus Pedidos" com polling de status
- [x] **Sprint 4** — `app_prestador` Flutter completo com design system proprio e gerenciamento do fluxo completo de 6 status (P → A → S → E → C / X)
