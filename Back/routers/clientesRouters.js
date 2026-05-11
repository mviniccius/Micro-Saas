const { Router } = require("express");
const router = Router();
const clienteController = require("../controllers/clienteController");

/**
 * @swagger
 * /clientes:
 *   get:
 *     summary: Lista todos os clientes
 *     responses:
 *       200:
 *         description: Lista retornada com sucesso
 */
router.get("/", (req, res) => clienteController.buscar(req, res));

/**
 * @swagger
 * /clientes/telefone/{telefone}:
 *   get:
 *     summary: Busca cliente pelo telefone (portal do cliente)
 *     parameters:
 *       - in: path
 *         name: telefone
 *         required: true
 *         schema:
 *           type: string
 *         example: "11999999999"
 *     responses:
 *       200:
 *         description: Cliente encontrado
 *       404:
 *         description: Cliente não encontrado
 */
router.get("/telefone/:telefone", (req, res) => clienteController.buscarPorTelefone(req, res));

/**
 * @swagger
 * /clientes:
 *   post:
 *     summary: Cadastra um novo cliente
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Cliente'
 *     responses:
 *       201:
 *         description: Cliente criado com sucesso
 *       400:
 *         description: Dados obrigatórios ausentes
 */
router.post("/", (req, res) => clienteController.criar(req, res));

/**
 * @swagger
 * /clientes/{id}:
 *   put:
 *     summary: Atualiza um cliente existente
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Cliente'
 *     responses:
 *       200:
 *         description: Cliente atualizado com sucesso
 */
router.put("/:id", (req, res) => clienteController.atualizar(req, res));

module.exports = router;
