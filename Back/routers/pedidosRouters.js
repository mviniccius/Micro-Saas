const { Router } = require("express");
const router = Router();
const pedidoController = require("../controllers/pedidoController");

/**
 * @swagger
 * /pedidos:
 *   get:
 *     tags:
 *       - Pedidos
 *     summary: Lista todos os pedidos com dados do cliente
 *     responses:
 *       200:
 *         description: Lista retornada com sucesso
 */
router.get("/", (req, res) => pedidoController.buscar(req, res));

/**
 * @swagger
 * /pedidos/telefone/{telefone}:
 *   get:
 *     tags:
 *       - Pedidos
 *     summary: Lista pedidos de um cliente pelo telefone
 *     parameters:
 *       - in: path
 *         name: telefone
 *         required: true
 *         schema:
 *           type: string
 *         example: "11999999999"
 *     responses:
 *       200:
 *         description: Pedidos retornados com sucesso
 */
router.get("/telefone/:telefone", (req, res) => pedidoController.buscarPorTelefone(req, res));

/**
 * @swagger
 * /pedidos:
 *   post:
 *     tags:
 *       - Pedidos
 *     summary: Cria um novo pedido com itens
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Pedido'
 *     responses:
 *       201:
 *         description: Pedido criado com sucesso
 *       400:
 *         description: Dados obrigatórios ausentes
 */
router.post("/", (req, res) => pedidoController.criar(req, res));

module.exports = router;
