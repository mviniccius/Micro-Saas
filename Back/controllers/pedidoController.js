const {
  listarTodosPedidos,
  listarPedidosPorTelefone,
  criarPedidoCompleto,
} = require("../service/pedidoService");

class PedidoController {
  async buscar(req, res) {
    try {
      const pedidos = await listarTodosPedidos();
      return res.json(pedidos);
    } catch (error) {
      return res.status(500).json({ error: "Erro ao buscar pedidos" });
    }
  }

  async buscarPorTelefone(req, res) {
    try {
      const { telefone } = req.params;
      const pedidos = await listarPedidosPorTelefone(telefone);
      return res.json(pedidos);
    } catch (error) {
      return res.status(500).json({ error: "Erro ao buscar pedidos" });
    }
  }

  async criar(req, res) {
    try {
      const { id_cliente, itens } = req.body;
      if (!id_cliente || !itens || itens.length === 0) {
        return res.status(400).json({ message: "id_cliente e itens são obrigatórios" });
      }
      const pedido = await criarPedidoCompleto(id_cliente, itens);
      return res.status(201).json(pedido);
    } catch (error) {
      return res.status(500).json({ error: "Erro ao criar pedido" });
    }
  }
}

module.exports = new PedidoController();
