const express = require("express");
const router = express.Router();
const authService = require("../service/authService");

router.post("/login", async (req, res) => {
  try {
    const { email, senha } = req.body;
    if (!email || !senha) {
      return res.status(400).json({ erro: "Email e senha são obrigatórios" });
    }
    const usuario = await authService.login(email, senha);
    res.json({ sucesso: true, usuario });
  } catch (err) {
    res.status(401).json({ erro: err.message });
  }
});

module.exports = router;
