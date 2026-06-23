const {
  fecharFatura,
  registrarPagamento,
  listarFaturasPorCliente,
} = require("../service/faturaService");

class FaturaController {
  async listarPorCliente(req, res) {
    try {
      const { id_cliente } = req.params;
      const dados = await listarFaturasPorCliente(id_cliente);
      return res.json(dados);
    } catch (error) {
      if (error.message === "Cliente não encontrado") {
        return res.status(404).json({ error: error.message });
      }
      return res.status(500).json({ error: "Erro ao buscar faturas do cliente" });
    }
  }

  async fechar(req, res) {
    try {
      const { id_cliente } = req.body;
      if (!id_cliente) {
        return res.status(400).json({ message: "id_cliente é obrigatório" });
      }
      const fatura = await fecharFatura(id_cliente);
      return res.status(201).json(fatura);
    } catch (error) {
      if (error.message.startsWith("Nenhum pedido entregue")) {
        return res.status(422).json({ error: error.message });
      }
      return res.status(500).json({ error: "Erro ao fechar fatura" });
    }
  }

  async pagar(req, res) {
    try {
      const { id } = req.params;
      const { valor, forma_pagamento } = req.body;
      if (valor == null || !forma_pagamento) {
        return res.status(400).json({ message: "valor e forma_pagamento são obrigatórios" });
      }
      const resultado = await registrarPagamento(id, valor, forma_pagamento);
      return res.status(201).json(resultado);
    } catch (error) {
      if (error.message === "Fatura não encontrada") {
        return res.status(404).json({ error: error.message });
      }
      if (
        error.message === "Fatura já está paga" ||
        error.message.startsWith("Forma de pagamento inválida") ||
        error.message.startsWith("Valor do pagamento")
      ) {
        return res.status(422).json({ error: error.message });
      }
      return res.status(500).json({ error: "Erro ao registrar pagamento" });
    }
  }
}

module.exports = new FaturaController();
