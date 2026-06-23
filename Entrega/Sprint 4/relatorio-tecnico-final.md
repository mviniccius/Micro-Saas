# Relatório Técnico Final — Sprint 4

**Disciplina:** Laboratório de Desenvolvimento de Aplicações Móveis e Distribuídas (LDAMD)  
**Curso:** Engenharia de Software — PUC Minas  
**Aluno:** mViniccius  
**Data:** 22/06/2026  
**Sprint:** 4 — App do Prestador e Integração Completa do Sistema

---

## 1. Introdução

O projeto integrador da disciplina consiste no desenvolvimento de um sistema de gestão de pedidos para uma padaria artesanal chamada **Efraim**. O sistema é de uso interno, destinado a operacionalizar o fluxo que vai da anotação de um pedido pelo cliente até a confirmação de entrega pelo prestador de serviço.

O domínio envolve três atores principais: o **Cliente** (empresa compradora, como uma rede hoteleira), o **Funcionário** (usuário interno da panificadora) e a própria **Padaria**, que gerencia produtos e orquestra o ciclo de produção. Um pedido é composto por um ou mais itens — cada um referenciando um produto com preço vigente no momento da compra — e percorre um ciclo de vida com seis estados possíveis.

O objetivo do projeto integrador é aplicar, em um sistema real e funcional, os principais padrões estudados na disciplina: arquitetura orientada a eventos (EDA), middleware orientado a mensagens (MOM), arquitetura limpa (Clean Architecture) e comunicação via REST. Cada sprint adicionou uma camada de complexidade ao sistema: Sprint 1 estabeleceu o backend REST com banco de dados relacional; Sprint 2 integrou o RabbitMQ como MOM; Sprint 3 construiu o aplicativo Flutter do cliente; e esta Sprint 4 entregou o aplicativo do prestador, completando o fluxo de ponta a ponta.

---

## 2. Arquitetura Implementada

### 2.1. Visão Geral dos Componentes

O sistema é composto por quatro componentes principais, cada um com responsabilidade bem delimitada:

| Componente | Tecnologia | Responsabilidade |
|---|---|---|
| `Back/` | Node.js + Express | API REST, lógica de negócio, publicação de eventos |
| `app_cliente/` | Flutter | Interface do cliente final: catálogo, pedidos, acompanhamento |
| `app_prestador/` | Flutter | Interface do funcionário: gestão de pedidos e status |
| RabbitMQ | AMQP 0-9-1 | Transporte assíncrono de eventos entre produtor e consumidores |
| Supabase | PostgreSQL gerenciado | Persistência relacional dos dados do domínio |

O `front/` (Vue.js) foi scaffolded nas sprints anteriores mas permanece fora do escopo das entregas desta sprint.

### 2.2. Diagrama de Arquitetura

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          CAMADA DE APLICAÇÃO                            │
│                                                                         │
│   ┌──────────────────┐              ┌──────────────────────────────┐    │
│   │   app_cliente    │              │        app_prestador         │    │
│   │    (Flutter)     │              │           (Flutter)          │    │
│   │                  │              │                              │    │
│   │ LoginScreen      │              │ LoginScreen                  │    │
│   │ HomeScreen       │              │ PedidosScreen (polling 10s)  │    │
│   │ CriarPedido      │              │ PedidoDetalheScreen          │    │
│   │ MeusPedidos      │              │ EditarItensPedidoScreen      │    │
│   │  (polling 10s)   │              │                              │    │
│   └────────┬─────────┘              └──────────────┬───────────────┘    │
│            │  HTTP/REST                            │  HTTP/REST          │
└────────────┼───────────────────────────────────────┼─────────────────────┘
             │                                       │
┌────────────▼───────────────────────────────────────▼─────────────────────┐
│                          BACKEND (Node.js + Express)                      │
│                                                                           │
│   Routes → Controllers → Services → PostgreSQL (Supabase)                │
│                                                                           │
│   POST /pedidos          GET  /pedidos/:id                               │
│   GET  /produtos         PATCH /pedidos/:id/status                       │
│   GET  /clientes/...     PUT  /pedidos/:id/itens                         │
│   POST /funcionarios/login                                                │
│                                │                                          │
│                         [Publicação AMQP]                                 │
└────────────────────────────────┼──────────────────────────────────────────┘
                                 │
                    ┌────────────▼─────────────┐
                    │         RabbitMQ          │
                    │   Exchange: padaria_events│
                    │   Tipo: topic             │
                    │                           │
                    │  pedido.criado ──────────►│── fila_pedido_criado
                    │  pedido.status_atualizado►│── fila_pedido_status
                    │  pedido.itens.atualizados►│── fila_pedido_itens
                    └───────────────────────────┘
                                 │
                    ┌────────────▼─────────────┐
                    │   consumer.js (Node.js)   │
                    │   Consumidor interno:     │
                    │   loga eventos e simula   │
                    │   serviços downstream     │
                    └───────────────────────────┘
```

### 2.3. Ciclo de Vida do Pedido

O ciclo de vida do pedido é o elemento central do domínio. Ao longo das sprints, foi expandido de quatro para seis estados:

```
        ┌─────────────────────────────────────────────┐
        │              Ciclo de Vida do Pedido         │
        └─────────────────────────────────────────────┘

   Criado pelo        Aceito pelo       Produção        Carga
     Cliente          Funcionário       concluída      despachada    Entregue
       │                  │                │               │            │
       ▼                  ▼                ▼               ▼            ▼
  ┌─────────┐        ┌─────────┐     ┌─────────┐    ┌─────────┐  ┌─────────┐
  │    P    │──────► │    A    │────►│    S    │───►│    E    │─►│    C    │
  │Recebido │        │Em Prod. │     │Separado │    │Em Entrg.│  │Entregue │
  └─────────┘        └─────────┘     └─────────┘    └─────────┘  └─────────┘
       │
       │ (somente de P)
       ▼
  ┌─────────┐
  │    X    │
  │Cancelado│
  └─────────┘
```

As transições são unidirecionais. Cancelamento (`X`) só é permitido a partir do estado inicial `P`. A edição de itens é permitida apenas nos estados `P` e `A`.

---

## 3. Decisões de Design

### 3.1. Node.js + Express no Backend

A escolha de Node.js com Express foi motivada pela leveza do framework e pela natureza I/O-bound da aplicação. Um servidor de pedidos realiza predominantemente operações de leitura e escrita em banco de dados e publicação de mensagens — cenário no qual o modelo de event loop não-bloqueante do Node.js é eficiente. O Express, por sua vez, oferece controle explícito sobre rotas, middlewares e tratamento de erros, sem abstrações desnecessárias que dificultariam a compreensão do fluxo por um time pequeno.

A organização em `routes → controllers → services` respeita a separação de responsabilidades: a rota apenas mapeia o verbo HTTP e delega ao controller; o controller extrai parâmetros da requisição e chama o service; o service contém toda a lógica de negócio e acessa o banco diretamente via driver `pg`.

### 3.2. RabbitMQ como MOM

O RabbitMQ foi escolhido como middleware de mensagens por três razões principais:

1. **Maturidade e estabilidade:** O RabbitMQ implementa o protocolo AMQP 0-9-1, amplamente adotado em produção, com garantias de entrega configuráveis e suporte a filas duráveis.
2. **Topic exchange:** O modelo de roteamento por routing key (ex: `pedido.criado`, `pedido.status_atualizado`) permite que múltiplos consumidores sejam adicionados no futuro sem alteração no produtor — princípio fundamental do padrão publish/subscribe.
3. **Interface de gerenciamento:** A imagem `rabbitmq:3-management` expõe um painel web em `localhost:15672`, útil para visualizar filas e confirmar a entrega de mensagens durante o desenvolvimento e a avaliação.

Mensagens são configuradas com `persistent: true` e filas com `durable: true`, garantindo sobrevivência a reinicializações do broker.

### 3.3. Polling no Flutter em vez de WebSocket

A atualização de status nos aplicativos Flutter foi implementada via **polling assíncrono com intervalo fixo de 10 segundos** (usando `Timer.periodic`). A alternativa natural seria WebSocket, que empurraria atualizações em tempo real sem o custo de requisições redundantes.

A escolha pelo polling foi deliberada e justificada pelo contexto do sistema:

- **Volume de operações reduzido:** Um sistema interno de padaria não processa centenas de pedidos simultâneos. O custo de 6 requisições por minuto por tela aberta é negligenciável.
- **Simplicidade de implementação:** WebSocket exigiria um servidor com suporte a upgrade de protocolo, gerenciamento de conexões persistentes, lógica de reconexão e tratamento de falhas — complexidade desproporcional ao benefício no contexto do projeto.
- **Adequação ao ciclo acadêmico:** O polling demonstra com clareza o conceito de sincronização assíncrona sem exigir infraestrutura adicional.
- **Cancelamento no `dispose()`:** O timer é sempre cancelado quando a tela é destruída, eliminando o risco de memory leak.

### 3.4. Supabase como PostgreSQL Gerenciado

O banco de dados é um PostgreSQL hospedado no Supabase. A motivação foi pragmática: o Supabase elimina a necessidade de provisionar e administrar um servidor de banco de dados, oferece uma string de conexão imediata e um painel visual para consultas ad hoc — essencial para um projeto com equipe reduzida.

A camada de acesso a dados no backend usa o driver `pg` diretamente, sem ORM. Isso preserva o controle total sobre as queries SQL e torna explícitas as operações no banco — uma escolha educacional deliberada.

### 3.5. Clean Architecture nos Aplicativos Flutter

Ambos os aplicativos Flutter adotam uma separação em duas camadas principais:

- **Presentation Layer** (`lib/presentation/screens/`): telas e widgets. Responsável apenas por renderizar dados e capturar interações do usuário.
- **Data Layer** (`lib/data/`): models (classes Dart que representam entidades do domínio) e services (classes responsáveis pelas chamadas HTTP ao backend).

Essa separação evita que lógica de negócio fique acoplada a widgets específicos, facilita a substituição da fonte de dados (ex: trocar HTTP por um mock local para testes) e torna o código mais legível para novos integrantes.

---

## 4. Padrões Estudados na Disciplina

### 4.1. EDA — Arquitetura Orientada a Eventos

A Arquitetura Orientada a Eventos (EDA) trata operações de negócio como eventos que são publicados por produtores e consumidos de forma assíncrona por um ou mais consumidores, sem que produtor e consumidor se conheçam diretamente (HOHPE; WOOLF, 2003).

No projeto, o backend atua como produtor de eventos em dois pontos do fluxo:

1. Após a criação bem-sucedida de um pedido (`POST /pedidos`), publica o evento `pedido.criado`.
2. Após a atualização de status (`PATCH /pedidos/:id/status`), publica `pedido.status_atualizado`.
3. Após a edição de itens (`PUT /pedidos/:id/itens`), publica `pedido.itens.atualizados`.

O consumer (`consumer.js`) processa esses eventos de forma desacoplada — ele não é chamado diretamente por nenhum controller ou service. Essa separação é a materialização do princípio EDA: o backend de pedidos não precisa saber quem vai reagir ao evento de criação — pode ser a linha de produção, o app do prestador, um serviço de notificação, ou todos ao mesmo tempo.

### 4.2. MOM — Middleware Orientado a Mensagens

O MOM é a infraestrutura que viabiliza a EDA. O RabbitMQ atua como o broker intermediário, recebendo mensagens dos produtores, armazenando-as nas filas e entregando-as aos consumidores no ritmo que estes conseguem processar (HOHPE; WOOLF, 2003).

O padrão implementado é o **Topic Exchange**: o exchange `padaria_events` roteia mensagens com base em routing keys hierárquicas (`pedido.criado`, `pedido.status_atualizado`). Isso permite vincular consumidores seletivos — por exemplo, um consumidor que escuta apenas `pedido.*` para logar todos os eventos de pedido, e outro que escuta especificamente `pedido.criado` para notificar a linha de produção.

### 4.3. Clean Architecture

A Clean Architecture (MARTIN, 2019) estabelece que o código deve ser organizado em camadas com dependências apontando sempre para dentro — em direção às regras de negócio, nunca em direção a detalhes de infraestrutura.

No backend, a separação `routes → controllers → services` aplica esse princípio: o service não importa nada do Express (não conhece `req` nem `res`); ele recebe dados primitivos e retorna resultados. O controller traduz a requisição HTTP em chamada ao service. A rota apenas registra o mapeamento.

Nos apps Flutter, a divisão `presentation/data` segue o mesmo raciocínio: as telas não fazem chamadas HTTP diretamente — delegam para os services da camada de dados, que são substituíveis por mocks sem alterar uma linha das telas.

### 4.4. REST — Representational State Transfer

A API do backend segue os princípios REST: recursos são identificados por URIs (`/pedidos`, `/pedidos/:id/status`, `/pedidos/:id/itens`), operações são expressas pelos verbos HTTP (`GET`, `POST`, `PATCH`, `PUT`) e as respostas carregam códigos de status HTTP semânticos (`201 Created`, `200 OK`, `400 Bad Request`, `404 Not Found`).

A separação entre `PATCH /pedidos/:id/status` (atualiza apenas o status) e `PUT /pedidos/:id/itens` (substitui integralmente os itens) reflete a distinção REST entre atualização parcial e substituição de recurso — PATCH para mudança de estado, PUT para substituição do conjunto de itens.

Os aplicativos Flutter consomem a API exclusivamente via HTTP utilizando o pacote `http` do Dart, sem SDKs proprietários, tornando a integração portável e compreensível.

---

## 5. Fluxo Completo de Ponta a Ponta

Esta seção descreve o caminho técnico completo, desde a criação de um pedido pelo cliente até a visualização da atualização de status.

### 5.1. Criação de Pedido (app_cliente → Backend → RabbitMQ)

```
app_cliente (Flutter)                  Backend (Express)              RabbitMQ
       │                                       │                          │
       │  POST /pedidos                        │                          │
       │  { id_cliente, itens: [              │                          │
       │    { id_produto, quantidade }] }      │                          │
       │──────────────────────────────────────►│                          │
       │                               Inicia transação SQL              │
       │                               INSERT INTO pedidos               │
       │                               INSERT INTO itens_pedido          │
       │                               (preço buscado do banco)          │
       │                               COMMIT                            │
       │                                       │                          │
       │                                       │  publish(pedido.criado) │
       │                                       │─────────────────────────►│
       │◄──────────────────────────────────────│                          │
       │  201 Created { id_pedido, status: P } │                          │
       │                                       │               consumer.js│
       │                                       │◄─────────── fila_pedido_criado
       │                                       │          [LOG: novo pedido]
```

O preço unitário **nunca é enviado pelo app** — o backend busca o preço vigente no banco para cada `id_produto`. Essa decisão protege contra manipulação de preços no lado cliente.

### 5.2. Visualização pelo Prestador (polling no app_prestador)

Após a criação do pedido, o `app_prestador` visualiza o pedido novo na próxima iteração do seu timer de polling:

```
app_prestador (Flutter)                Backend (Express)         Supabase (PostgreSQL)
       │                                       │                          │
       │  [Timer.periodic, 10s]                │                          │
       │  GET /pedidos                         │                          │
       │──────────────────────────────────────►│                          │
       │                                       │  SELECT p.*, ip.*        │
       │                                       │  FROM pedidos p           │
       │                                       │  JOIN itens_pedido ip    │
       │                                       │─────────────────────────►│
       │                                       │◄─────────────────────────│
       │◄──────────────────────────────────────│                          │
       │  200 OK [ { id_pedido, status: P,    │                          │
       │             itens: [...] }, ... ]     │                          │
       │                                       │                          │
       │  [UI renderiza card do pedido]        │                          │
```

### 5.3. Avanço de Status pelo Prestador

O funcionário acessa `PedidoDetalheScreen` e pressiona o botão de avançar status:

```
app_prestador (Flutter)                Backend (Express)              RabbitMQ
       │                                       │                          │
       │  PATCH /pedidos/7/status              │                          │
       │  { status: "A" }                      │                          │
       │──────────────────────────────────────►│                          │
       │                               Valida transição P→A              │
       │                               UPDATE pedidos SET status = 'A'   │
       │                               WHERE id = 7                      │
       │                                       │                          │
       │                                       │  publish(                │
       │                                       │   pedido.status_atualizado)
       │                                       │─────────────────────────►│
       │◄──────────────────────────────────────│                          │
       │  200 OK { id_pedido: 7, status: A }  │                          │
       │                                       │               consumer.js│
       │                                       │◄─────────── fila_pedido_status
       │  [UI atualiza card: "Em Produção"]    │          [LOG: P→A]
```

### 5.4. Cliente Vê a Atualização (polling no app_cliente)

Sem nenhuma ação adicional, o `app_cliente` reflete o novo status na próxima iteração do seu timer:

```
app_cliente (Flutter)                  Backend (Express)         Supabase (PostgreSQL)
       │                                       │                          │
       │  [Timer.periodic, 10s]                │                          │
       │  GET /pedidos/telefone/11999999999    │                          │
       │──────────────────────────────────────►│                          │
       │                                       │  SELECT ... WHERE        │
       │                                       │  c.telefone = '...'      │
       │                                       │─────────────────────────►│
       │                                       │◄─────────────────────────│
       │◄──────────────────────────────────────│                          │
       │  200 OK [ { id_pedido: 7,            │                          │
       │             status: "A", ... } ]      │                          │
       │                                       │                          │
       │  [Card muda: Laranja → Azul           │                          │
       │   "Em Produção"]                      │                          │
```

### 5.5. Edição de Itens pelo Prestador

Quando necessário (status `P` ou `A`), o funcionário pode editar os itens do pedido:

```
app_prestador (Flutter)                Backend (Express)              RabbitMQ
       │                                       │                          │
       │  PUT /pedidos/7/itens                 │                          │
       │  { itens: [                           │                          │
       │    { id_produto: 1, quantidade: 180 },│                          │
       │    { id_produto: 5, quantidade: 50 }] }│                         │
       │──────────────────────────────────────►│                          │
       │                               Valida status P ou A              │
       │                               DELETE FROM itens_pedido           │
       │                               WHERE id_pedido = 7               │
       │                               INSERT INTO itens_pedido (lote)   │
       │                               Recalcula valor_total             │
       │                               UPDATE pedidos SET valor_total    │
       │                                       │                          │
       │                                       │  publish(                │
       │                                       │   pedido.itens.atualizados)
       │                                       │─────────────────────────►│
       │◄──────────────────────────────────────│                          │
       │  200 OK { id_pedido: 7, itens: [...]}│                          │
```

---

## 6. Dificuldades Encontradas e Soluções Adotadas

### 6.1. Expansão do Ciclo de Vida para Seis Estados

O maior desafio de backend desta sprint foi a expansão do ciclo de vida do pedido. Nas sprints anteriores, o sistema suportava apenas quatro estados (`P`, `A`, `C`, `X`). O app_prestador exigia os estados `S` (Separado) e `E` (Em Entrega) para representar as etapas físicas de separação de carga e transporte.

A solução envolveu atualizar a validação de transições no `pedidoService.js` para reconhecer as duas novas transições (`A→S` e `S→E`), além de atualizar os mapas de estado nos dois apps Flutter — tanto os botões de avançar status no `app_prestador` quanto as cores e rótulos no `app_cliente`. O fato de o campo `status` no banco ser `char(1)` tornou a migração de schema desnecessária — os valores `S` e `E` já eram armazenáveis, bastando atualizar a lógica de aplicação.

### 6.2. Endpoint de Edição de Itens: Substituição Total vs. Atualização Parcial

A implementação do `PUT /pedidos/:id/itens` levantou a questão de como tratar a edição de itens de forma consistente. A abordagem adotada foi a **substituição total**: ao receber a lista de itens, o backend apaga todos os `itens_pedido` existentes do pedido e reinserção o lote completo enviado pelo app.

Essa estratégia simplifica a lógica de sincronização — não é necessário comparar item a item para decidir o que foi adicionado, alterado ou removido. O custo é uma operação de DELETE + INSERT a cada edição, aceitável dado o volume de dados (dezenas de itens no máximo por pedido).

O backend também rejeita requisições com lista de itens vazia, garantindo que um pedido jamais fique sem itens — a alternativa nesse caso é o cancelamento explícito.

### 6.3. Recálculo de Preços no Backend

Havia o risco de inconsistência de preços caso o app enviasse os valores ao criar ou editar itens. A solução adotada desde a Sprint 3 é que o app **nunca envia preço** — envia apenas `id_produto` e `quantidade`. O backend busca o preço vigente no banco para cada produto no momento da operação e calcula `preco_unitario`, `valor_total_item` e `valor_total`. Isso garante que o preço refletido no pedido é sempre o preço oficial cadastrado na panificadora.

### 6.4. Migração para Supabase

Na Sprint 1, o banco de dados rodava em um container PostgreSQL local via Docker Compose. A migração para o Supabase exigiu atualizar a string de conexão no backend e lidar com o comportamento de SSL exigido pelo Supabase em conexões remotas. O driver `pg` foi configurado com `ssl: { rejectUnauthorized: false }` para permitir a conexão sem certificado cliente — solução adequada para o contexto de desenvolvimento.

O Supabase também trouxe um benefício inesperado: o painel visual de tabelas e o SQL Editor facilitaram a inspeção e correção de dados durante o desenvolvimento, substituindo a necessidade de um cliente PostgreSQL local.

### 6.5. Gerenciamento de Estado no Flutter

O `app_prestador` apresentou desafios de gerenciamento de estado superiores ao `app_cliente` por operar com múltiplas telas que compartilham o mesmo recurso (o pedido). Ao retornar da `EditarItensPedidoScreen` para a `PedidoDetalheScreen`, era necessário garantir que os dados exibidos refletissem a edição recém-confirmada e não os dados em cache da chamada anterior.

A solução adotada foi forçar o recarregamento dos dados ao retornar de telas filhas, usando o valor de retorno da navegação (`Navigator.pop` com dados) e relançando a chamada ao service em `initState` quando a tela é reconstruída. Essa abordagem, embora simples, foi suficiente para o escopo do projeto — gerenciadores de estado como Provider ou Bloc seriam mais adequados em um sistema com maior volume de estados compartilhados.

### 6.6. Race Condition na Inicialização dos Containers

Problema identificado na Sprint 2 e mantido na Sprint 4: o container Node.js subia antes do RabbitMQ estar pronto para aceitar conexões, causando falha de conexão AMQP. A solução foi implementar lógica de **retry com backoff fixo** no módulo `rabbitmq.js`: até 10 tentativas com intervalo de 5 segundos. Isso cobre o tempo típico de inicialização do RabbitMQ sem exigir orquestração explícita de dependências no `docker-compose.yml`.

---

## 7. Conclusão

Ao longo das quatro sprints, o sistema foi construído de forma incremental, com cada sprint adicionando uma camada de funcionalidade sobre a anterior. O resultado é um sistema funcional de ponta a ponta: um cliente cria um pedido no seu app Flutter, o pedido persiste no PostgreSQL hospedado no Supabase, um evento é publicado no RabbitMQ, e o funcionário visualiza e gerencia o pedido no seu próprio app — com atualizações automáticas em ambas as direções via polling assíncrono.

O aprendizado mais significativo desta jornada foi a compreensão prática da diferença entre **acoplamento e coesão**. É tentador, especialmente no início, colocar toda a lógica em um só lugar — uma rota que faz tudo, uma tela que acessa o banco diretamente. A Clean Architecture e a EDA ensinam que o sistema ganha em manutenibilidade quando cada componente conhece apenas o mínimo necessário sobre os demais. O backend não sabe quantos apps consomem seus eventos; o app_cliente não sabe como o backend armazena os dados; o RabbitMQ não sabe qual é a regra de negócio por trás de cada mensagem.

O projeto também evidenciou as trocas inerentes a qualquer decisão de design: polling é mais simples que WebSocket mas consome mais banda; substituição total de itens é mais simples que diff incremental mas gera mais operações no banco; Supabase é mais rápido de configurar mas introduz dependência de rede em desenvolvimento. Não existem decisões certas em abstrato — apenas decisões adequadas ao contexto.

O sistema está arquitetado para receber novas funcionalidades nas fases seguintes: autenticação com JWT, gestão financeira com faturas e períodos de faturamento, e anotações de separação. A separação de camadas implementada garante que essas adições possam ser feitas sem reescrever o que já existe.

---

## 8. Referências Bibliográficas

HOHPE, Gregor; WOOLF, Bobby. **Enterprise Integration Patterns: designing, building, and deploying messaging solutions.** Boston: Addison-Wesley, 2003.

MARTIN, Robert C. **Arquitetura limpa: o guia do artesão para estrutura e design de software.** Rio de Janeiro: Alta Books, 2019.

RICHARDSON, Chris. **Microservices patterns: with examples in Java.** Shelter Island: Manning, 2018.
