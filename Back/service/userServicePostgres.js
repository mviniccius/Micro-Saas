const db = require("../database/postgres")

async function listarTodosUsuarios() {
    const result = await db.query("SELECT * FROM usuarios ORDER BY id_usuario ASC")
    return result.rows
}

async function criarUsario({ nome, email }) {
    const result = await db.query(
        "INSERT INTO usuarios (nome, email) VALUES ($1, $2) RETURNING id_usuario, nome, email",
        [nome, email]
    )
    return result.rows[0]
}

async function atualizarUsuario({ id, nome, email }) {
    const result = await db.query(
        "UPDATE usuarios SET nome = $1, email = $2 WHERE id_usuario = $3 RETURNING id_usuario, nome, email",
        [nome, email, id]
    )
    return result.rows[0]
}

module.exports = {
    listarTodosUsuarios,
    criarUsario,
    atualizarUsuario,
}
