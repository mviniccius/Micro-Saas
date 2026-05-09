const swaggerJsdoc = require("swagger-jsdoc");

const options = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "API Gestão Padaria",
      version: "1.0.0",
    },
  },
  apis: ["./routers/*.js"],
};

module.exports = swaggerJsdoc(options);
