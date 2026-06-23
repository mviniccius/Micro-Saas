require("dotenv").config({ path: require("path").resolve(__dirname, "../.env") });
const { Pool } = require("pg");
const colors = require("colors");

// Mesma estratégia de conexão do app (database/postgres.js):
// usa DATABASE_URL (ex: Supabase) quando presente, senão cai no Postgres local.
const pool = process.env.DATABASE_URL
  ? new Pool({
      connectionString: process.env.DATABASE_URL,
      ssl: { rejectUnauthorized: false },
    })
  : new Pool({
      host: process.env.DB_HOST || "localhost",
      port: Number(process.env.DB_PORT || 5432),
      user: process.env.DB_USER || "postgres",
      password: process.env.DB_PASSWORD || "123",
      database: process.env.DB_NAME || "padaria",
    });

async function seed() {
  const client = await pool.connect();
  try {
    console.log(colors.cyan("\n=== Seed do Banco de Dados ===\n"));

    await client.query("BEGIN");

    // Produtos
    const produtos = [
      { nome: "Bolo de Chocolate", preco: 45.90 },
      { nome: "Bolo de Morango", preco: 52.00 },
      { nome: "Torta de Limão", preco: 38.50 },
      { nome: "Pão de Queijo (dúzia)", preco: 18.00 },
      { nome: "Coxinha (dúzia)", preco: 22.00 },
    ];

    console.log(colors.white("Inserindo produtos..."));
    const produtoIds = {};
    for (const p of produtos) {
      const res = await client.query(
        "INSERT INTO produtos (nome_produto, preco) VALUES ($1, $2) RETURNING id_produto",
        [p.nome, p.preco]
      );
      produtoIds[p.nome] = res.rows[0].id_produto;
      console.log(colors.green(`  ✔ [id=${res.rows[0].id_produto}] ${p.nome} — R$ ${p.preco}`));
    }

    // Clientes (com ciclo de faturamento — ADR-0002)
    const clientes = [
      { nome: "João da Silva", telefone: "31999990001", ciclo: "SEMANAL" },
      { nome: "Maria Oliveira", telefone: "31999990002", ciclo: "MENSAL" },
      { nome: "Carlos Souza", telefone: "31999990003", ciclo: "DIARIO" },
    ];

    console.log(colors.white("\nInserindo clientes..."));
    const clienteIds = {};
    for (const c of clientes) {
      const res = await client.query(
        "INSERT INTO clientes (nome, telefone, active, ciclo_faturamento) VALUES ($1, $2, true, $3) RETURNING id_cliente",
        [c.nome, c.telefone, c.ciclo]
      );
      clienteIds[c.nome] = res.rows[0].id_cliente;
      console.log(colors.green(`  ✔ [id=${res.rows[0].id_cliente}] ${c.nome} — ${c.telefone} (${c.ciclo})`));
    }

    // Usuários
    const usuarios = [
      { nome: "Ana Paula", email: "ana@padaria.com" },
      { nome: "Carlos Atendente", email: "carlos@padaria.com" },
    ];

    console.log(colors.white("\nInserindo usuários..."));
    for (const u of usuarios) {
      const res = await client.query(
        "INSERT INTO usuarios (nome, email) VALUES ($1, $2) RETURNING id_usuario",
        [u.nome, u.email]
      );
      console.log(colors.green(`  ✔ [id=${res.rows[0].id_usuario}] ${u.nome} — ${u.email}`));
    }

    // ── Dados financeiros de exemplo (ADR-0002) ───────────────────────────
    // Cria um pedido entregue ('C') com seus itens e devolve o id e o valor.
    async function criarPedidoEntregue(idCliente, itens) {
      const valorTotal = itens.reduce(
        (soma, it) => soma + produtos.find((p) => p.nome === it.produto).preco * it.qtd,
        0
      );
      const resPedido = await client.query(
        "INSERT INTO pedidos (id_cliente, valor_total, status) VALUES ($1, $2, 'C') RETURNING id_pedido",
        [idCliente, valorTotal]
      );
      const idPedido = resPedido.rows[0].id_pedido;
      for (const it of itens) {
        const precoUnit = produtos.find((p) => p.nome === it.produto).preco;
        await client.query(
          `INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario, valor_total_item)
           VALUES ($1, $2, $3, $4, $5)`,
          [idPedido, produtoIds[it.produto], it.qtd, precoUnit, precoUnit * it.qtd]
        );
      }
      return { idPedido, valorTotal };
    }

    console.log(colors.white("\nInserindo dados financeiros de exemplo..."));

    // João: pedidos entregues AINDA NÃO faturados → para testar POST /faturas/fechar
    const joao = clienteIds["João da Silva"];
    await criarPedidoEntregue(joao, [
      { produto: "Bolo de Chocolate", qtd: 2 },
      { produto: "Pão de Queijo (dúzia)", qtd: 1 },
    ]);
    await criarPedidoEntregue(joao, [{ produto: "Coxinha (dúzia)", qtd: 3 }]);
    console.log(colors.green(`  ✔ João (id=${joao}) — 2 pedidos entregues prontos para faturar`));

    // Maria: fatura já fechada e PARCIALMENTE PAGA → a aba Financeiro mostra dados ricos
    const maria = clienteIds["Maria Oliveira"];
    const pedidoMaria1 = await criarPedidoEntregue(maria, [
      { produto: "Bolo de Morango", qtd: 1 },
      { produto: "Torta de Limão", qtd: 2 },
    ]);
    const pedidoMaria2 = await criarPedidoEntregue(maria, [{ produto: "Bolo de Chocolate", qtd: 1 }]);
    const valorFatura = pedidoMaria1.valorTotal + pedidoMaria2.valorTotal;

    const resFatura = await client.query(
      `INSERT INTO faturas (id_cliente, periodo_inicio, periodo_fim, valor_total, status)
       VALUES ($1, CURRENT_DATE - INTERVAL '15 days', CURRENT_DATE, $2, 'PARCIALMENTE_PAGA')
       RETURNING id_fatura`,
      [maria, valorFatura]
    );
    const idFaturaMaria = resFatura.rows[0].id_fatura;

    // Vincula os pedidos da Maria à fatura (invariante: 1 pedido → no máximo 1 fatura)
    await client.query(
      "UPDATE pedidos SET id_fatura = $1 WHERE id_pedido = ANY($2)",
      [idFaturaMaria, [pedidoMaria1.idPedido, pedidoMaria2.idPedido]]
    );

    // Pagamento parcial em PIX (metade da fatura)
    const valorPago = Math.round((valorFatura / 2) * 100) / 100;
    await client.query(
      "INSERT INTO pagamentos (id_fatura, valor, forma_pagamento) VALUES ($1, $2, 'PIX')",
      [idFaturaMaria, valorPago]
    );
    console.log(
      colors.green(
        `  ✔ Maria (id=${maria}) — fatura #${idFaturaMaria} PARCIALMENTE_PAGA (R$ ${valorPago.toFixed(2)} de R$ ${valorFatura.toFixed(2)})`
      )
    );

    await client.query("COMMIT");
    console.log(colors.bgGreen("\n✔ Seed concluído!\n"));
  } catch (err) {
    await client.query("ROLLBACK");
    console.error(colors.red("\n✖ Erro no seed:"), err.message);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
}

seed();
