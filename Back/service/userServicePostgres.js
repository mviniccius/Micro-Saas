const db = require("../database/postgres")

//GET /user
async function listarTodosUsuarios() {
    const result = await db.query("SELECT id, nome, email, created_at FROM users ORDER BY id DESC")

    return result.rows
}

//POST /user
async function criarUsario({ nome, email }) {
    const result = await db.query("INSERT INTO users (nome, email) VALUES ($1, $1) RETURNING id, nome, email, created_at",
        [nome, email]
    )
    return result.rows[0]
}

module.exports = {
    listarTodosUsuarios,
    criarUsario,
}