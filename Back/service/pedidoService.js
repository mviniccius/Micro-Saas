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

    // Busca preços do banco — nunca confiar no cliente para enviar preço
    let totalPedido = 0;
    const itensComPreco = [];

    for (const item of itens) {
      const res = await client.query(
        "SELECT preco FROM produtos WHERE id_produto = $1",
        [item.id_produto]
      );
      if (!res.rows.length) throw new Error(`Produto ${item.id_produto} não encontrado`);
      const preco = parseFloat(res.rows[0].preco);
      const totalItem = item.quantidade * preco;
      totalPedido += totalItem;
      itensComPreco.push({ ...item, preco, totalItem });
    }

    const queryPedido = `INSERT INTO pedidos (id_cliente, valor_total, status) VALUES ($1, $2, 'P') RETURNING id_pedido`;
    const resPedido = await client.query(queryPedido, [id_cliente, totalPedido]);
    const idPedidoGerado = resPedido.rows[0].id_pedido;

    for (const item of itensComPreco) {
      await client.query(
        `INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario, valor_total_item) VALUES ($1, $2, $3, $4, $5)`,
        [idPedidoGerado, item.id_produto, item.quantidade, item.preco, item.totalItem]
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
  const statusValidos = ["P", "A", "S", "E", "C", "X"];
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

  const transicoesPermitidas = { P: ['A', 'X'], A: ['S'], S: ['E'], E: ['C'] };
  const permitidos = transicoesPermitidas[status_anterior.trim()] || [];
  if (!permitidos.includes(novo_status)) {
    throw new Error(`Transição inválida: ${status_anterior.trim()} → ${novo_status}. Permitidas: ${permitidos.join(', ') || 'nenhuma'}`);
  }

  await pool.query(
    "UPDATE pedidos SET status = $1, update_at = NOW() WHERE id_pedido = $2",
    [novo_status, id_pedido]
  );

  await publicarEvento("pedido.status_atualizado", {
    id_pedido: Number(id_pedido),
    status_anterior,
    status_novo: novo_status,
  });

  return { id_pedido: Number(id_pedido), status_anterior, status_novo: novo_status };
}

async function listarItensPedido(id_pedido) {
  const result = await pool.query(`
    SELECT ip.id_itens_pedido, ip.id_produto, pr.nome_produto,
           ip.quantidade, ip.preco_unitario, ip.valor_total_item
    FROM itens_pedido ip
    JOIN produtos pr ON pr.id_produto = ip.id_produto
    WHERE ip.id_pedido = $1
    ORDER BY ip.id_itens_pedido
  `, [id_pedido]);
  return result.rows;
}

async function atualizarItens(id_pedido, itens) {
  if (!itens || itens.length === 0) {
    throw new Error("Pedido deve ter pelo menos 1 item. Para cancelar, use PATCH /status.");
  }

  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const resPedido = await client.query(
      "SELECT status FROM pedidos WHERE id_pedido = $1",
      [id_pedido]
    );
    if (!resPedido.rows.length) throw new Error("Pedido não encontrado");

    const status = resPedido.rows[0].status.trim();
    if (!["P", "A"].includes(status)) {
      throw new Error(`Itens só podem ser editados nos status P ou A. Status atual: ${status}`);
    }

    await client.query("DELETE FROM itens_pedido WHERE id_pedido = $1", [id_pedido]);

    let totalPedido = 0;
    const itensInseridos = [];
    for (const item of itens) {
      const resProd = await client.query(
        "SELECT preco FROM produtos WHERE id_produto = $1",
        [item.id_produto]
      );
      if (!resProd.rows.length) throw new Error(`Produto ${item.id_produto} não encontrado`);
      const preco = parseFloat(resProd.rows[0].preco);
      const totalItem = item.quantidade * preco;
      totalPedido += totalItem;

      await client.query(
        `INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario, valor_total_item)
         VALUES ($1, $2, $3, $4, $5)`,
        [id_pedido, item.id_produto, item.quantidade, preco, totalItem]
      );
      itensInseridos.push({ id_produto: item.id_produto, quantidade: item.quantidade, preco_unitario: preco, valor_total_item: totalItem });
    }

    await client.query(
      "UPDATE pedidos SET valor_total = $1, update_at = NOW() WHERE id_pedido = $2",
      [totalPedido, id_pedido]
    );

    await client.query("COMMIT");

    await publicarEvento("pedido.itens.atualizados", {
      id_pedido: Number(id_pedido),
      itens: itensInseridos,
      valor_total: totalPedido,
    });

    return { sucesso: true, id_pedido: Number(id_pedido), valor_total: totalPedido, itens: itensInseridos };
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}

// Lista de Produção (ADR/CONTEXT): transiciona todos os Pedidos Recebido (P)
// para Em Produção (A) e devolve o total a produzir por Produto, em unidades.
async function gerarListaProducao() {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    // Trava os Pedidos Recebidos no instante do acionamento (evita corrida entre 2 funcionários)
    const resPedidos = await client.query(
      "SELECT id_pedido FROM pedidos WHERE status = 'P' ORDER BY id_pedido FOR UPDATE"
    );
    const ids = resPedidos.rows.map((r) => r.id_pedido);

    if (ids.length === 0) {
      throw new Error("Nenhum pedido recebido para produzir");
    }

    // Consolida as quantidades por Produto somando todos os Pedidos da onda
    const resItens = await client.query(
      `SELECT pr.id_produto, pr.nome_produto, SUM(ip.quantidade)::int AS quantidade
       FROM itens_pedido ip
       JOIN produtos pr ON pr.id_produto = ip.id_produto
       WHERE ip.id_pedido = ANY($1)
       GROUP BY pr.id_produto, pr.nome_produto
       ORDER BY pr.nome_produto`,
      [ids]
    );

    await client.query(
      "UPDATE pedidos SET status = 'A', update_at = NOW() WHERE id_pedido = ANY($1)",
      [ids]
    );

    await client.query("COMMIT");

    await publicarEvento("producao.lista_gerada", {
      pedidos: ids,
      total_pedidos: ids.length,
    });

    return {
      total_pedidos: ids.length,
      itens: resItens.rows.map((r) => ({
        id_produto: r.id_produto,
        nome_produto: r.nome_produto,
        quantidade: Number(r.quantidade),
      })),
    };
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
  atualizarStatusPedido,
  listarItensPedido,
  atualizarItens,
  gerarListaProducao,
};
