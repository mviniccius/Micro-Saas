const routerUser = require("./usersRouters")
const routerProduto = require("./produtosRouters")
const routerCliente = require("./clientesRouters")
const routerPedido = require("./pedidosRouters")
const routerAuth = require("./authRouters")
const routerFatura = require("./faturasRouters")

module.exports = (app) => {
  app.use("/auth", routerAuth)
  app.use("/users", routerUser)
  app.use("/produtos", routerProduto)
  app.use("/clientes", routerCliente)
  app.use("/pedidos", routerPedido)
  app.use("/faturas", routerFatura)
}
