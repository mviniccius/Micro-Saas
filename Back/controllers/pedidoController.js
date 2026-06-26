const {
  listarTodosPedidos,
  listarPedidosPorTelefone,
  criarPedidoCompleto,
  atualizarStatusPedido,
  listarItensPedido,
  atualizarItens,
  gerarListaProducao,
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

  async atualizarStatus(req, res) {
    try {
      const { id } = req.params;
      const { status } = req.body;
      if (!status) {
        return res.status(400).json({ message: "Campo 'status' é obrigatório. Valores: P, A, C, X" });
      }
      const resultado = await atualizarStatusPedido(id, status);
      return res.json(resultado);
    } catch (error) {
      if (error.message === "Pedido não encontrado") {
        return res.status(404).json({ error: error.message });
      }
      if (error.message.startsWith("Status inválido")) {
        return res.status(400).json({ error: error.message });
      }
      if (error.message.startsWith("Transição inválida")) {
        return res.status(422).json({ error: error.message });
      }
      return res.status(500).json({ error: "Erro ao atualizar status do pedido" });
    }
  }

  async gerarListaProducao(req, res) {
    try {
      const lista = await gerarListaProducao();
      return res.status(201).json(lista);
    } catch (error) {
      if (error.message.startsWith("Nenhum pedido recebido")) {
        return res.status(422).json({ error: error.message });
      }
      return res.status(500).json({ error: "Erro ao gerar lista de produção" });
    }
  }

  async buscarItens(req, res) {
    try {
      const { id } = req.params;
      const itens = await listarItensPedido(id);
      return res.json(itens);
    } catch (error) {
      if (error.message === "Pedido não encontrado") {
        return res.status(404).json({ error: error.message });
      }
      return res.status(500).json({ error: "Erro ao buscar itens do pedido" });
    }
  }

  async atualizarItens(req, res) {
    try {
      const { id } = req.params;
      const { itens } = req.body;
      const resultado = await atualizarItens(id, itens);
      return res.json(resultado);
    } catch (error) {
      if (error.message === "Pedido não encontrado") {
        return res.status(404).json({ error: error.message });
      }
      if (error.message.startsWith("Itens só podem ser editados") || error.message.startsWith("Pedido deve ter")) {
        return res.status(422).json({ error: error.message });
      }
      if (error.message.startsWith("Produto")) {
        return res.status(400).json({ error: error.message });
      }
      return res.status(500).json({ error: "Erro ao atualizar itens do pedido" });
    }
  }
}

module.exports = new PedidoController();
