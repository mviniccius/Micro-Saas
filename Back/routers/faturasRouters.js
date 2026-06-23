const { Router } = require("express");
const router = Router();
const faturaController = require("../controllers/faturaController");

/**
 * @swagger
 * /faturas/cliente/{id_cliente}:
 *   get:
 *     tags:
 *       - Faturas
 *     summary: Lista as faturas de um cliente com pagamentos, saldo de crédito e total em aberto
 *     parameters:
 *       - in: path
 *         name: id_cliente
 *         required: true
 *         schema:
 *           type: integer
 *         example: 1
 *     responses:
 *       200:
 *         description: Dados financeiros do cliente
 *       404:
 *         description: Cliente não encontrado
 */
router.get("/cliente/:id_cliente", (req, res) => faturaController.listarPorCliente(req, res));

/**
 * @swagger
 * /faturas/fechar:
 *   post:
 *     tags:
 *       - Faturas
 *     summary: Fecha uma fatura agrupando os pedidos entregues (status C) ainda não faturados do cliente
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               id_cliente:
 *                 type: integer
 *             example:
 *               id_cliente: 1
 *     responses:
 *       201:
 *         description: Fatura criada
 *       400:
 *         description: id_cliente ausente
 *       422:
 *         description: Nenhum pedido entregue disponível para faturar
 */
router.post("/fechar", (req, res) => faturaController.fechar(req, res));

/**
 * @swagger
 * /faturas/{id}/pagamento:
 *   post:
 *     tags:
 *       - Faturas
 *     summary: Registra um pagamento na fatura (excedente vira crédito do cliente)
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
 *               valor:
 *                 type: number
 *               forma_pagamento:
 *                 type: string
 *                 enum: [PIX, DINHEIRO]
 *             example:
 *               valor: 250.00
 *               forma_pagamento: "PIX"
 *     responses:
 *       201:
 *         description: Pagamento registrado
 *       404:
 *         description: Fatura não encontrada
 *       422:
 *         description: Pagamento inválido ou fatura já paga
 */
router.post("/:id/pagamento", (req, res) => faturaController.pagar(req, res));

module.exports = router;
