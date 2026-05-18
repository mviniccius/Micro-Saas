const pool = require("../database/postgres");
const { publicarEvento } = require("../messaging/publisher");

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

    await publicarEvento("pedido.criado", {
      id_pedido: idPedidoGerado,
      id_cliente,
      valor_total: totalPedido,
      status: "P",
    });

    return { sucesso: true, id_pedido: idPedidoGerado, total: totalPedido };
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}

async function atualizarStatusPedido(id_pedido, novo_status) {
  const statusValidos = ["P", "A", "C", "X"];
  if (!statusValidos.includes(novo_status)) {
    throw new Error(`Status inválido. Use: ${statusValidos.join(", ")}`);
  }

  const resAtual = await pool.query(
    "SELECT status FROM pedidos WHERE id_pedido = $1",
    [id_pedido]
  );

  if (!resAtual.rows.length) {
    throw new Error("Pedido não encontrado");
  }

  const status_anterior = resAtual.rows[0].status;

  await pool.query(
    "UPDATE pedidos SET status = $1, updated_at = NOW() WHERE id_pedido = $2",
    [novo_status, id_pedido]
  );

  await publicarEvento("pedido.status_atualizado", {
    id_pedido: Number(id_pedido),
    status_anterior,
    status_novo: novo_status,
  });

  return { id_pedido: Number(id_pedido), status_anterior, status_novo: novo_status };
}

module.exports = {
  listarTodosPedidos,
  listarPedidosPorTelefone,
  criarPedidoCompleto,
  atualizarStatusPedido,
};
