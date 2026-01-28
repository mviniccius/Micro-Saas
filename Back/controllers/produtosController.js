const {
  listarTodosProdutos,
  criarProduto,
  atualizarProduto,
} = require("../service/produtosServices");

class produtoControler {
  async buscar(req, res) {
    try {
      const produto = await listarTodosProdutos();
      return res.json(produto);
    } catch (error) {
      console.error("Erro ao buscar produto", error);
      return res.status(500).json({ error: "Erro ao buscar produto" });
    }
  }

  async criar(req, res) {
    try {
      const { nome, preco } = req.body;
      if (!nome || preco) {
        return res
          .status(400)
          .json({ message: "Nome e email sao obrigatorios" });
      }
      const produto = await criarProduto({ nome, preco });
      return res.status(201).json(produto);
    } catch (error) {
      console.error("Erro ao criar produto: ", error);

      return res.status(500).json({ error: "Erro ao criar produto" });
    }
  }
}

module.exports = new produtoControler();
