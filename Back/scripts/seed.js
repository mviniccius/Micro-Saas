require("dotenv").config({ path: require("path").resolve(__dirname, "../.env") });
const { Pool } = require("pg");
const colors = require("colors");

const pool = new Pool({
  host: process.env.DB_HOST || "localhost",
  port: Number(process.env.DB_PORT || 5432),
  user: process.env.DB_USER || "postgres",
  password: process.env.DB_PASSWORD || "123",
  database: process.env.DB_NAME || "padaria",
});

async function seed() {
  const client = await pool.connect();
  try {
    console.log(colors.cyan("\n=== Seed do Banco de Dados ===\n"));

    await client.query("BEGIN");

    // Produtos
    const produtos = [
      { nome: "Bolo de Chocolate", preco: 45.90 },
      { nome: "Bolo de Morango", preco: 52.00 },
      { nome: "Torta de Limão", preco: 38.50 },
      { nome: "Pão de Queijo (dúzia)", preco: 18.00 },
      { nome: "Coxinha (dúzia)", preco: 22.00 },
    ];

    console.log(colors.white("Inserindo produtos..."));
    for (const p of produtos) {
      const res = await client.query(
        "INSERT INTO produtos (nome_produto, preco) VALUES ($1, $2) RETURNING id_produto",
        [p.nome, p.preco]
      );
      console.log(colors.green(`  ✔ [id=${res.rows[0].id_produto}] ${p.nome} — R$ ${p.preco}`));
    }

    // Clientes
    const clientes = [
      { nome: "João da Silva", telefone: "31999990001" },
      { nome: "Maria Oliveira", telefone: "31999990002" },
      { nome: "Carlos Souza", telefone: "31999990003" },
    ];

    console.log(colors.white("\nInserindo clientes..."));
    for (const c of clientes) {
      const res = await client.query(
        "INSERT INTO clientes (nome, telefone, active) VALUES ($1, $2, true) RETURNING id_cliente",
        [c.nome, c.telefone]
      );
      console.log(colors.green(`  ✔ [id=${res.rows[0].id_cliente}] ${c.nome} — ${c.telefone}`));
    }

    // Usuários
    const usuarios = [
      { nome: "Ana Paula", email: "ana@padaria.com" },
      { nome: "Carlos Atendente", email: "carlos@padaria.com" },
    ];

    console.log(colors.white("\nInserindo usuários..."));
    for (const u of usuarios) {
      const res = await client.query(
        "INSERT INTO usuarios (nome, email) VALUES ($1, $2) RETURNING id_usuario",
        [u.nome, u.email]
      );
      console.log(colors.green(`  ✔ [id=${res.rows[0].id_usuario}] ${u.nome} — ${u.email}`));
    }

    await client.query("COMMIT");
    console.log(colors.bgGreen("\n✔ Seed concluído!\n"));
  } catch (err) {
    await client.query("ROLLBACK");
    console.error(colors.red("\n✖ Erro no seed:"), err.message);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
}

seed();
