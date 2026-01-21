const db = require("../database/postgres")

//GET /user
async function listarTodosUsuarios() {
    const result = await db.query("SELECT * FROM users ORDER BY id ASC")

    return result.rows
}

//POST /user
async function criarUsario({ nome, email }) {
    const result = await db.query("INSERT INTO users (nome, email) VALUES ($1, $2) RETURNING id, nome, email",
        [nome, email]
    )
    return result.rows[0]
}
async function atualizarUsuario({ id }) {
    const result = await db.query("UPDATE users SET nome = $1, email = $2  WHERE id = $3 RETURNING id, nome, email", [nome, email, id])
        return result.rows[0]
}

module.exports = {
    listarTodosUsuarios,
    criarUsario,
    atualizarUsuario,
}