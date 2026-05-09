//const Router = require("express").Router;
const { Router } = require("express");
const router = Router();

const userController = require("../controllers/userController");

//get
/**
 * @swagger
 * /users:
 *   get:
 *     summary: Lista todos os usuários
 *     responses:
 *       200:
 *         description: Lista retornada com sucesso
 */
router.get("/", (req, res) => userController.buscar(req, res));

//post
/**
 * @swagger
 * /users:
 *   post:
 *     summary: Cria um novo usuário
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/User'
 *     responses:
 *       201:
 *         description: Usuário criado com sucesso
 */

router.post("/", (req, res) => userController.criar(req, res));

//put
/**
 * @swagger
 * /users/{id}:
 *   put:
 *     summary: Atualiza um usuário existente
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/User'
 *     responses:
 *       200:
 *         description: Usuário atualizado com sucesso
 */ 
router.put("/:id", (req, res) => userController.atualizar(req, res));

//delet
/**
 * @swagger
 * /users/{id}:
 *   delete:
 *     summary: Remove um usuário
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Usuário removido com sucesso
 */
router.delete("/:id", (req, res) => {
  const { id } = req.params;
  const resposta = userController.apagar(id);
  res.send(resposta);
});

module.exports = router;
