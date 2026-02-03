const pool = require("../database/postgres");

async function criarPedidoCompleto(id_usuario, itens) {
  const client = await pool.connect();

  try {
    // PASSO 1: Iniciar a Transação
    await client.query("BEGIN");

    // PASSO 2: Calcular o valor total do pedido
    const totalPedido = itens.reduce((acumulador, item) => {
      return acumulador + item.quantidade * item.preco;
    }, 0);

    // PASSO 3: Inserir o pedido na tabela 'pedidos' e recuperar o ID
    const queryPedido = `INSERT INTO pedidos (id_cliente, valor_total) VALUES ($1, $2) RETURNING id`;
    const valuesPedido = [id_usuario, totalPedido];
    const resPedido = await client.query(queryPedido, valuesPedido);

    const idPedidoGerado = resPedido.rows[0].id;

    // PASSO 4: Inserir cada item na tabela 'itens_pedido'
    for (const item of itens) {
      const totalItem = item.quantidade * item.preco;
      const queryItem = `INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario, valor_total_item) VALUES ($1, $2, $3, $4, $5)`;
      const valuesItem = [
        idPedidoGerado, // $1
        item.id_produto, // $2
        item.quantidade, // $3
        item.preco, // $4
        totalItem, // $5
      ];
      await client.query(queryItem, valuesItem);
    }

    // PASSO 5: Confirmar a Transação (Sucesso!)
    await client.query("COMMIT");

    return {
      sucesso: true,
      id_pedido: idPedidoGerado,
      total: totalPedido,
    };
  } catch (error) {
    // PASSO 6: Desfazer tudo se algo der errado
    await client.query("ROLLBACK");
    console.error("Erro ao criar pedido:", error);
    throw error;
  } finally {
    // PASSO 7: Liberar o cliente volta para o pool
    client.release();
  }
}

module.exports = {
  criarPedidoCompleto,
};
