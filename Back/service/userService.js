const User = require("../models/user");

//listar usuarios:
async function listarTodosUsuarios1() {
  return await User.find();
}

//criar usuario:
async function criarUsario1({ nome, email }) {
  const user = await User.create({ nome, email });
  return user;
}

module.exports = {
  listarTodosUsuarios1,
  criarUsario1,
};
