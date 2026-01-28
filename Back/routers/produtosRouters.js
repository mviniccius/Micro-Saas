const { Router } = require("express");
const router = Router();

const produtoController = require("../controllers/produtosController")

//get
router.get("/", (req, res) => produtoController.buscar(req, res))

//post
router.post("/", (req, res) => produtoController.criar(req, res))

//put
//router.put("/:id", (reqm res) => produtoController.at)

module.exports = router