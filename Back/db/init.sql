CREATE TABLE perfis(
  id_perfil SERIAL PRIMARY KEY,
  nome VARCHAR(120)
);

CREATE TABLE usuarios (
  id_usuario SERIAL PRIMARY KEY,
  nome VARCHAR(120),
  email VARCHAR(120),
  senha VARCHAR(50),
  active boolean,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  update_at TIMESTAMP NOT NULL DEFAULT NOW(),
  perfil_id INT,
  FOREIGN KEY (perfil_id) REFERENCES perfis(id_perfil)
);


CREATE TABLE clientes(
  id_cliente SERIAL PRIMARY KEY,
  nome VARCHAR(120),
  telefone VARCHAR(12),
  active boolean,
  ciclo_faturamento VARCHAR(10) NOT NULL DEFAULT 'MENSAL', -- DIARIO, SEMANAL, MENSAL
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  update_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE pedidos(
  id_pedido SERIAL PRIMARY KEY,
  id_cliente int,
  valor_total numeric,
  status char,
  id_fatura int, -- NULL enquanto o pedido não foi faturado; FK definida após a tabela faturas
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  update_at TIMESTAMP NOT NULL DEFAULT NOW(),
  FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

CREATE TABLE produtos(
  id_produto SERIAL PRIMARY KEY,
  nome_produto VARCHAR(50),
  preco numeric,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  update_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE itens_pedido(
  id_itens_pedido SERIAL PRIMARY KEY,
  id_pedido int,
  id_produto int,
  quantidade int,
  preco_unitario numeric,
  valor_total_item numeric,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  update_at TIMESTAMP NOT NULL DEFAULT NOW(),
  FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
  FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
);

-- ── Financeiro (ADR-0002) ──────────────────────────────────────────────

CREATE TABLE faturas(
  id_fatura SERIAL PRIMARY KEY,
  id_cliente int NOT NULL,
  periodo_inicio DATE,
  periodo_fim DATE,
  valor_total numeric NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'ABERTA', -- ABERTA, PARCIALMENTE_PAGA, PAGA, VENCIDA
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  update_at TIMESTAMP NOT NULL DEFAULT NOW(),
  FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

-- Vínculo pedido → fatura (FK só pode ser criada depois da tabela faturas existir)
ALTER TABLE pedidos
  ADD CONSTRAINT fk_pedido_fatura FOREIGN KEY (id_fatura) REFERENCES faturas(id_fatura);

CREATE TABLE pagamentos(
  id_pagamento SERIAL PRIMARY KEY,
  id_fatura int NOT NULL,
  valor numeric NOT NULL,
  forma_pagamento VARCHAR(10) NOT NULL, -- PIX, DINHEIRO, CREDITO
  data_pagamento TIMESTAMP NOT NULL DEFAULT NOW(),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  FOREIGN KEY (id_fatura) REFERENCES faturas(id_fatura)
);

-- Razão (ledger) de crédito do cliente: o saldo é a soma das movimentações
CREATE TABLE creditos_cliente(
  id_credito SERIAL PRIMARY KEY,
  id_cliente int NOT NULL,
  valor numeric NOT NULL, -- sempre positivo; o sinal é dado por 'tipo'
  tipo VARCHAR(10) NOT NULL, -- GERADO (entra), CONSUMIDO (sai)
  id_fatura_origem int, -- fatura que gerou ou consumiu o crédito
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
  FOREIGN KEY (id_fatura_origem) REFERENCES faturas(id_fatura)
);
