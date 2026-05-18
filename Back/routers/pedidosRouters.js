const { Router } = require("express");
const router = Router();
const pedidoController = require("../controllers/pedidoController");

/**
 * @swagger
 * /pedidos:
 *   get:
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

/**
 * @swagger
 * /pedidos/{id}/status:
 *   patch:
 *     summary: Atualiza o status de um pedido e publica evento no MOM
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         example: 1
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               status:
 *                 type: string
 *                 enum: [P, A, C, X]
 *                 description: "P=Pendente, A=Em Produção, C=Concluído, X=Cancelado"
 *             example:
 *               status: "A"
 *     responses:
 *       200:
 *         description: Status atualizado com sucesso
 *       400:
 *         description: Status inválido ou ausente
 *       404:
 *         description: Pedido não encontrado
 */
router.patch("/:id/status", (req, res) => pedidoController.atualizarStatus(req, res));

module.exports = router;
