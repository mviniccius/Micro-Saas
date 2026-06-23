-- Migration 002 — Financeiro (ADR-0002)
-- Aplicar em banco já existente (ex: Supabase). Idempotente: usa IF NOT EXISTS.

-- Ciclo de faturamento do cliente
ALTER TABLE clientes
  ADD COLUMN IF NOT EXISTS ciclo_faturamento VARCHAR(10) NOT NULL DEFAULT 'MENSAL';

-- Vínculo pedido → fatura
ALTER TABLE pedidos
  ADD COLUMN IF NOT EXISTS id_fatura int;

CREATE TABLE IF NOT EXISTS faturas(
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

-- FK pedidos → faturas (criada só se ainda não existir)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'fk_pedido_fatura'
  ) THEN
    ALTER TABLE pedidos
      ADD CONSTRAINT fk_pedido_fatura FOREIGN KEY (id_fatura) REFERENCES faturas(id_fatura);
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS pagamentos(
  id_pagamento SERIAL PRIMARY KEY,
  id_fatura int NOT NULL,
  valor numeric NOT NULL,
  forma_pagamento VARCHAR(10) NOT NULL, -- PIX, DINHEIRO, CREDITO
  data_pagamento TIMESTAMP NOT NULL DEFAULT NOW(),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  FOREIGN KEY (id_fatura) REFERENCES faturas(id_fatura)
);

CREATE TABLE IF NOT EXISTS creditos_cliente(
  id_credito SERIAL PRIMARY KEY,
  id_cliente int NOT NULL,
  valor numeric NOT NULL,
  tipo VARCHAR(10) NOT NULL, -- GERADO, CONSUMIDO
  id_fatura_origem int,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
  FOREIGN KEY (id_fatura_origem) REFERENCES faturas(id_fatura)
);
