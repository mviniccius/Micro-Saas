const {
  listarTodosUsuarios,
  criarUsario,
  atualizarUsuario,
} = require("../service/userServicePostgres");

class userControler {
  async buscar(req, res) {
    try {
      const user = await listarTodosUsuarios();
      return res.json(user);
    } catch (error) {
      console.error("Erro ao buscar usuarios", error);
      return res.status(500).json({ error: "Erro ao buscar usuarios " });
    }
  }

  async criar(req, res) {
    try {
      const { nome, email } = req.body;
      if (!nome || !email) {
        return res
          .status(400)
          .json({ message: "Nome e email sao obrigatorios" });
      }
      const user = await criarUsario({ nome, email });
      return res.status(201).json(user);
    } catch (error) {
      console.error("Erro ao criar usuario: ", error);

      if (error.code === "23505") {
        return res.status(409).json({ message: "Email ja cadastrado" });
      }

      return res.status(500).json({ error: "Erro ao criar usuario" });
    }
  }

  async atualizar(req, res) {
    const { id } = req.params;
    const { nome, email } = req.body;

    try {
      if (!nome || !email) {
        return res
          .status(400)
          .json({ message: "Nome e email sao obrigatorios!" });
      }
      const user = await atualizarUsuario({ id, nome, email });
      return res.status(201).json(user);
    } catch (error) {
      console.error("Erro ao atualizar usuario" + error);
      
      return res.status(500).json({ error:"Erro ao atualizar usuario"}) 
    }
  }

  apagar(id) {
    return "Deletando usuario id: " + id + " !!";
  }
}

module.exports = new userControler();
