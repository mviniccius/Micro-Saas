const db = require("../database/postgres");

async function listarTodosClientes() {
  const result = await db.query("SELECT * FROM clientes WHERE active = true ORDER BY id_cliente ASC");
  return result.rows;
}

async function buscarClientePorTelefone(telefone) {
  const result = await db.query("SELECT * FROM clientes WHERE telefone = $1", [telefone]);
  return result.rows[0];
}

async function criarCliente({ nome, telefone }) {
  const result = await db.query(
    "INSERT INTO clientes (nome, telefone, active) VALUES ($1, $2, true) RETURNING id_cliente, nome, telefone",
    [nome, telefone]
  );
  return result.rows[0];
}

async function atualizarCliente({ id, nome, telefone }) {
  const result = await db.query(
    "UPDATE clientes SET nome = $1, telefone = $2 WHERE id_cliente = $3 RETURNING id_cliente, nome, telefone",
    [nome, telefone, id]
  );
  return result.rows[0];
}

module.exports = {
  listarTodosClientes,
  buscarClientePorTelefone,
  criarCliente,
  atualizarCliente,
};
