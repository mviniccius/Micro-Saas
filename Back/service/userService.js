const User = require("../models/user");

//listar usuarios:
async function listarTodosUsuarios() {
  return await User.find();
}

//criar usuario:
async function criarUsario({ nome, email }) {
  const user = await User.create({ nome, email });
  return user;
}

module.exports = {
  listarTodosUsuarios,
  criarUsario,
};
