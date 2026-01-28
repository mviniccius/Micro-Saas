const routerUser = require("./usersRouters")
const routerProduto = require("./produtosRouters")

module.exports = (app) => {
 app.use("/users", routerUser)
 app.use("/produto", routerProduto)
}