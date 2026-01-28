CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(120) NOT NULL,
  email VARCHAR(120) NOT NULL UNIQUE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);


 CREATE TABLE public.produtos
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    nome_produto character varying(255) NOT NULL,
    preco numeric(10, 2),
    PRIMARY KEY (id)
);