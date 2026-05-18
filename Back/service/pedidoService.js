const pool = require("../database/postgres");

async function listarTodosPedidos() {
  const result = await pool.query(`
    SELECT p.id_pedido, p.valor_total, p.status, p.created_at,
           c.nome AS cliente, c.telefone
    FROM pedidos p
    JOIN clientes c ON c.id_cliente = p.id_cliente
    ORDER BY p.created_at DESC
  `);
  return result.rows;
}

async function listarPedidosPorTelefone(telefone) {
  const result = await pool.query(`
    SELECT p.id_pedido, p.valor_total, p.status, p.created_at
    FROM pedidos p
    JOIN clientes c ON c.id_cliente = p.id_cliente
    WHERE c.telefone = $1
    ORDER BY p.created_at DESC
  `, [telefone]);
  return result.rows;
}

async function criarPedidoCompleto(id_cliente, itens) {
  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    const totalPedido = itens.reduce((acumulador, item) => {
      return acumulador + item.quantidade * item.preco;
    }, 0);

    const queryPedido = `INSERT INTO pedidos (id_cliente, valor_total, status) VALUES ($1, $2, 'P') RETURNING id_pedido`;
    const resPedido = await client.query(queryPedido, [id_cliente, totalPedido]);
    const idPedidoGerado = resPedido.rows[0].id_pedido;

    for (const item of itens) {
      const totalItem = item.quantidade * item.preco;
      await client.query(
        `INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario, valor_total_item) VALUES ($1, $2, $3, $4, $5)`,
        [idPedidoGerado, item.id_produto, item.quantidade, item.preco, totalItem]
      );
    }

    await client.query("COMMIT");

    return { sucesso: true, id_pedido: idPedidoGerado, total: totalPedido };
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}

module.exports = {
  listarTodosPedidos,
  listarPedidosPorTelefone,
  criarPedidoCompleto,
};
