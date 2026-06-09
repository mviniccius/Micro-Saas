const pool = require("../database/postgres");

async function login(email, senha) {
  const res = await pool.query(
    `SELECT u.id_usuario, u.nome, u.email, u.senha, u.active, p.nome AS perfil
     FROM usuarios u
     JOIN perfis p ON p.id_perfil = u.perfil_id
     WHERE u.email = $1`,
    [email]
  );

  if (res.rows.length === 0) throw new Error("Credenciais inválidas");

  const usuario = res.rows[0];

  if (!usuario.active) throw new Error("Usuário inativo");

  // Comparação direta (bcrypt será implementado em [AUTH-01])
  if (usuario.senha !== senha) throw new Error("Credenciais inválidas");

  return {
    id_usuario: usuario.id_usuario,
    nome: usuario.nome,
    email: usuario.email,
    perfil: usuario.perfil,
  };
}

module.exports = { login };
