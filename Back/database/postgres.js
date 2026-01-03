const { Pool } = require("pg");

const pool = new Pool({
  host: process.env.DB_HOST || "database",
  port: Number(process.env.DB_PORT || 5432),
  user: process.env.DB_USER || "postgres",
  password: process.env.DB_PASSWORD || "123",
  database: process.env.DB_NAME || "padaria",
});

pool.query("select 1")
  .then(() => console.log("Postgres conectado com sucesso"))
  .catch(err => console.error("Erro ao conectar no Postgres", err));


module.exports = pool;
