const swaggerJsdoc = require("swagger-jsdoc");

const options = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "API Gestão Padaria",
      version: "1.0.0",
    },
    components: {
      schemas: {
        User: {
          type: "object",
          properties: {
            nome:  { type: "string", example: "João Dono" },
            email: { type: "string", example: "joao@padaria.com" },
            senha: { type: "string", example: "123456" },
          },
        },
        Cliente: {
          type: "object",
          properties: {
            nome:     { type: "string", example: "Maria Silva" },
            telefone: { type: "string", example: "11999999999" },
          },
        },
        Produto: {
          type: "object",
          properties: {
            nome:  { type: "string", example: "Bolo de Chocolate" },
            preco: { type: "number", example: 45.90 },
          },
        },
        Pedido: {
          type: "object",
          properties: {
            id_cliente: { type: "integer", example: 1 },
            itens: {
              type: "array",
              items: {
                type: "object",
                properties: {
                  id_produto: { type: "integer", example: 1 },
                  quantidade: { type: "integer", example: 2 },
                  preco:      { type: "number",  example: 45.90 },
                },
              },
            },
          },
        },
      },
    },
  },
  apis: ["./routers/*.js"],
};

module.exports = swaggerJsdoc(options);
