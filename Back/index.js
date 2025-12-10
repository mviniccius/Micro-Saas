const express = require("express");
const app = express();
const router = require("./routers/index");

router(app);

const colors = require("colors");

const port = 3000;

app.get("/home", (req, res) => {
  res.send("Olá mundo ei asassaas !");
});

app.listen(3000, () => {
  console.log(colors.bgBlue(`Servidor rodando na porta ${port}`));
});
