require("dotenv").config();
const express = require("express");
const colors = require("colors");
const router = require("./routers");
const swaggerUi = require("swagger-ui-express");
const swaggerSpec = require("./swagger");

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));

router(app);

app.get("/home", (req, res) => res.send("Estou rodando"));

app.listen(port, () => {
  console.log(colors.bgBlue(`Servidor rodando na porta ${port}`));
});
