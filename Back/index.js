require("dotenv").config();
const express = require("express");
const colors = require("colors");
const router = require("./routers");

const app = express();
const port = 3000;

const swaggerSpec = require("./swagger");
const swaggerUi = require("swagger-ui-express");

app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));

app.use(express.json())

router(app);

app.get("/home", (req, res) => {
  res.send("Estou rodando");
});

app.listen(port, () => {
  console.log(colors.bgBlue(`Servidor rodando na porta ${port}`));
});
