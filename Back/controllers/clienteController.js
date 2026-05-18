const {
  listarTodosClientes,
  buscarClientePorTelefone,
  criarCliente,
  atualizarCliente,
} = require("../service/clienteService");

class ClienteController {
  async buscar(req, res) {
    try {
      const clientes = await listarTodosClientes();
      return res.json(clientes);
    } catch (error) {
      return res.status(500).json({ error: "Erro ao buscar clientes" });
    }
  }

  async buscarPorTelefone(req, res) {
    try {
      const { telefone } = req.params;
      const cliente = await buscarClientePorTelefone(telefone);
      if (!cliente) return res.status(404).json({ message: "Cliente não encontrado" });
      return res.json(cliente);
    } catch (error) {
      return res.status(500).json({ error: "Erro ao buscar cliente" });
    }
  }

  async criar(req, res) {
    try {
      const { nome, telefone } = req.body;
      if (!nome || !telefone) {
        return res.status(400).json({ message: "Nome e telefone são obrigatórios" });
      }
      const cliente = await criarCliente({ nome, telefone });
      return res.status(201).json(cliente);
    } catch (error) {
      return res.status(500).json({ error: "Erro ao criar cliente" });
    }
  }

  async atualizar(req, res) {
    try {
      const { id } = req.params;
      const { nome, telefone } = req.body;
      if (!nome || !telefone) {
        return res.status(400).json({ message: "Nome e telefone são obrigatórios" });
      }
      const cliente = await atualizarCliente({ id, nome, telefone });
      return res.status(200).json(cliente);
    } catch (error) {
      return res.status(500).json({ error: "Erro ao atualizar cliente" });
    }
  }
}

module.exports = new ClienteController();
