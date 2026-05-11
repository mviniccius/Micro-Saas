const db = require("../database/postgres");

async function listarTodosProdutos() {
  const result = await db.query("SELECT * FROM produtos");
  return result.rows;
}

async function criarProduto(nomeProduto, preco) {
  const result = await db.query(
    "INSERT INTO produtos (nome_produto, preco) VALUES ($1, $2) RETURNING id_produto, nome_produto, preco",
    [nomeProduto, preco]
  );
  return result.rows[0];
}

async function atualizarProduto({ id, nomeProduto, preco }) {
  const result = await db.query(
    "UPDATE produtos SET nome_produto = $1, preco = $2 WHERE id_produto = $3 RETURNING id_produto, nome_produto, preco",
    [nomeProduto, preco, id]
  );
  return result.rows[0];
}

module.exports = {
  listarTodosProdutos,
  criarProduto,
  atualizarProduto,
}
