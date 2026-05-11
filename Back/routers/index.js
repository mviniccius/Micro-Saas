const routerUser = require("./usersRouters")
const routerProduto = require("./produtosRouters")
const routerCliente = require("./clientesRouters")
const routerPedido = require("./pedidosRouters")

module.exports = (app) => {
  app.use("/users", routerUser)
  app.use("/produtos", routerProduto)
  app.use("/clientes", routerCliente)
  app.use("/pedidos", routerPedido)
}
