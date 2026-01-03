//const Router = require("express").Router;
const { Router } = require("express");
const router = Router();

const userController = require("../controllers/userController");

//get
router.get("/", (req, res) =>  userController.buscar(req, res));

//post
router.post("/", (req, res) => userController.criar(req, res));

//put
router.put("/:id", (req, res) => {
  const { id } = req.params;
  const resposta = userController.atualizar(id);
  res.send(resposta);
});

//delet
router.delete("/:id", (req, res) => {
  const { id } = req.params;
  const resposta = userController.apagar(id);
  res.send(resposta);
});

module.exports = router;
