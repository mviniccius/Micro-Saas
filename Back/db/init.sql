CREATE TABLE perfis(
  id_perfil INT PRIMARY KEY,
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
  id_cliente INT PRIMARY KEY,
  nome VARCHAR(120),
  telefone VARCHAR(12),
  active boolean,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  update_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE pedidos(
  id_pedido INT PRIMARY KEY,
  id_cliente int,
  valor_total numeric,
  status char,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  update_at TIMESTAMP NOT NULL DEFAULT NOW(),
  FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

CREATE TABLE produtos(
  id_produto INT PRIMARY KEY,
  nome_produto char(50),
  preco numeric,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  update_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE itens_pedido(
  id_itens_pedido INT PRIMARY KEY,
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
