const { listarTodosUsuarios, criarUsario } = require("../service/userService");

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
    const { nome, email } = req.body;
    try{      
      if(!nome || !email){
        return res.status(400).json({ message: "Nome e email sao obrigatorios"})
      }
      const user = await criarUsario({ nome, email})
      return res.status(201).json(user);
    }catch(erro){
      console.error("Erro ao criar usuario: ", error)
      return res.status(500).json({ error: "Erro ao criar usuario"})
    }
  }

  atualizar(id) {
    return "Atualizando usuario id: " + id + " !!";
  }

  apagar(id) {
    return "Deletando usuario id: " + id + " !!";
  }
}

module.exports = new userControler();
