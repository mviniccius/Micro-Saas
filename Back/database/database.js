const sqlite3 = require("sqlite3").verbose();
const path = require("path");
const cor = require("colors");

class Database {
  constructor() {
    this.dbPath = path.join(__dirname, "banco.db");
    this.db = null;
  }

  async init() {
    this.db = new sqlite3.Database(this.dbPath);
    await this.createTables();
    console.log(cor.green("Database inicializado"));
  }

  async createTables() {
    const usuarios = `
        CREATE TABLE IF NOT EXISTS usuarios(
        id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
        nome VARCHAR(120),
        email VARCHAR(120),
        senha VARCHAR(50),
        active BOOLEAN,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
        )`;

    const clientes = `CREATE TABLE IF NOT EXISTS clientes(
        id_cliente INTEGER PRIMARY KEY AUTOINCREMENT,
        nome VARCHAR(120),
        telefone VARCHAR(12),
        active boolean,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
        )`;

    const pedidos = `CREATE TABLE IF NOT EXISTS pedidos(
        id_pedido INTEGER PRIMARY KEY AUTOINCREMENT,
        id_cliente INT,
        valor_total NUMERIC,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
        )`;

    const produtos = `CREATE TABLE IF NOT EXISTS produtos(
        id_produto INTEGER PRIMARY KEY AUTOINCREMENT,
        nome_produto VARCHAR(50),
        preco NUMERIC,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
        )`;

    const itens_pedido = `CREATE TABLE IF NOT EXISTS itens_pedido(
        id_itens_pedido INTEGER PRIMARY KEY AUTOINCREMENT,
        id_pedido INTEGER,
        id_produto INTEGER,
        quantidade INTEGER,
        preco_unitario NUMERIC,
        valor_total_item NUMERIC,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
        FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
        )`;

    return Promise.all([
      this.run(usuarios),
      this.run(clientes),
      this.run(pedidos),
      this.run(produtos),
      this.run(itens_pedido),
    ]);
  }

  //Metodos auxiliares
  run(sql, params = []) {
    return new Promise((resolve, reject) => {
      this.db.run(sql, params, function (err) {
        if (err) reject(err);
        else resolve({ id: this.lastID, changes: this.changes });
      });
    });
  }

  get(sql, params = []) {
    return new Promise((resolve, reject) => {
      this.db.get(sql, params, (err, row) => {
        if (err) reject(err);
        else resolve(row);
      });
    });
  }
  all(sql, params = []) {
    return new Promise((resolve, reject) => {
      this.db.all(sql, params, (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
  }
}

module.exports = new Database();
