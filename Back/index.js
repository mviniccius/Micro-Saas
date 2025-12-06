const express = require("express");
const app = express();

const colors = require("colors");

const port = 3000;

app.get("/home", (req, res) => {
  res.send("Olá mundo!");
});

app.listen(3000, () => {
  console.log(`Servidor rodando na porta ${port}`);
});
