const express = require("express");
const colors = require("colors");
const router = require("./routers");
const conectarDB = require("./database/mongo");

const app = express();
const port = 3000;

app.use(express.json())

router(app);

app.get("/home", (req, res) => {
  res.send("Olá mundo ei asassaas !");
});

conectarDB().then(() => {
  app.listen(port, () => {
    console.log(colors.bgBlue(`Servidor rodando na porta ${port}`));
  });
});
