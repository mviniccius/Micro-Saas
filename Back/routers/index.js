const routerUser = require("./usersRouters")

module.exports = (app) => {
 app.use("/users", routerUser)
}