//const Router = require("express").Router;
const { Router } = require("express");
const router = Router();

const userController = require("../controllers/userController");

//get
router.get("/user", (req, res) => {
  const resposta = userController.buscar();
  res.send(resposta);
});

//post
router.post("/user", (req, res) => {
  const resposta = userController.criar();
  res.send(resposta);
});

//put
router.put("/user/:id", (req, res) => {
  const { id } = req.params;
  const resposta = userController.atualizar(id);
  res.send(resposta);
});

//delet
router.delete("/user/:id", (req, res) => {
  const { id } = req.params;
  const resposta = userController.apagar(id);
  res.send(resposta);
});

module.exports = router;
