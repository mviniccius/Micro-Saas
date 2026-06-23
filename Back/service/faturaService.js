const pool = require("../database/postgres");
const { publicarEvento } = require("../messaging/publisher");

const FORMAS_PAGAMENTO = ["PIX", "DINHEIRO"]; // CREDITO é interno (abatimento automático)

// Calcula o status da fatura a partir do quanto já foi pago (ADR-0002, decisão 4)
function calcularStatus(valorTotal, valorPago) {
  if (valorPago <= 0) return "ABERTA";
  if (valorPago >= valorTotal) return "PAGA";
  return "PARCIALMENTE_PAGA";
}

// Saldo de crédito = soma do ledger (GERADO entra, CONSUMIDO sai).
// Aceita pool ou client (para uso dentro de transação).
async function getSaldoCredito(querier, id_cliente) {
  const res = await querier.query(
    `SELECT COALESCE(SUM(CASE WHEN tipo = 'GERADO' THEN valor ELSE -valor END), 0) AS saldo
     FROM creditos_cliente WHERE id_cliente = $1`,
    [id_cliente]
  );
  return parseFloat(res.rows[0].saldo);
}

// Fecha uma fatura: agrupa os pedidos entregues ainda não faturados do cliente,
// vincula-os à nova fatura e abate o crédito disponível automaticamente.
async function fecharFatura(id_cliente) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const resPedidos = await client.query(
      `SELECT id_pedido, valor_total, created_at
       FROM pedidos
       WHERE id_cliente = $1 AND status = 'C' AND id_fatura IS NULL
       ORDER BY created_at`,
      [id_cliente]
    );

    if (!resPedidos.rows.length) {
      throw new Error("Nenhum pedido entregue disponível para faturar");
    }

    const pedidos = resPedidos.rows;
    const valorTotal = pedidos.reduce((soma, p) => soma + parseFloat(p.valor_total), 0);
    const periodoInicio = pedidos[0].created_at; // MIN(created_at) — pedidos já vêm ordenados

    const resFatura = await client.query(
      `INSERT INTO faturas (id_cliente, periodo_inicio, periodo_fim, valor_total, status)
       VALUES ($1, $2, CURRENT_DATE, $3, 'ABERTA')
       RETURNING id_fatura`,
      [id_cliente, periodoInicio, valorTotal]
    );
    const idFatura = resFatura.rows[0].id_fatura;

    const ids = pedidos.map((p) => p.id_pedido);
    await client.query(
      `UPDATE pedidos SET id_fatura = $1, update_at = NOW() WHERE id_pedido = ANY($2)`,
      [idFatura, ids]
    );

    // Abatimento automático de crédito (ADR-0002, decisão 6)
    let creditoAbatido = 0;
    const saldoCredito = await getSaldoCredito(client, id_cliente);
    if (saldoCredito > 0) {
      creditoAbatido = Math.min(saldoCredito, valorTotal);
      await client.query(
        `INSERT INTO pagamentos (id_fatura, valor, forma_pagamento) VALUES ($1, $2, 'CREDITO')`,
        [idFatura, creditoAbatido]
      );
      await client.query(
        `INSERT INTO creditos_cliente (id_cliente, valor, tipo, id_fatura_origem)
         VALUES ($1, $2, 'CONSUMIDO', $3)`,
        [id_cliente, creditoAbatido, idFatura]
      );
    }

    const status = calcularStatus(valorTotal, creditoAbatido);
    if (status !== "ABERTA") {
      await client.query(
        `UPDATE faturas SET status = $1, update_at = NOW() WHERE id_fatura = $2`,
        [status, idFatura]
      );
    }

    await client.query("COMMIT");

    await publicarEvento("fatura.criada", {
      id_fatura: idFatura,
      id_cliente,
      valor_total: valorTotal,
      credito_abatido: creditoAbatido,
      status,
    });

    return {
      id_fatura: idFatura,
      id_cliente,
      valor_total: valorTotal,
      credito_abatido: creditoAbatido,
      saldo_devedor: valorTotal - creditoAbatido,
      status,
      pedidos_faturados: ids.length,
    };
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}

// Registra um pagamento. Se o valor exceder o saldo devedor, o excedente
// vira crédito do cliente (ADR-0002, decisão 6).
async function registrarPagamento(id_fatura, valor, forma_pagamento) {
  if (!FORMAS_PAGAMENTO.includes(forma_pagamento)) {
    throw new Error(`Forma de pagamento inválida. Use: ${FORMAS_PAGAMENTO.join(", ")}`);
  }
  const valorPagamento = parseFloat(valor);
  if (!valorPagamento || valorPagamento <= 0) {
    throw new Error("Valor do pagamento deve ser maior que zero");
  }

  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const resFatura = await client.query(
      `SELECT id_cliente, valor_total, status FROM faturas WHERE id_fatura = $1`,
      [id_fatura]
    );
    if (!resFatura.rows.length) throw new Error("Fatura não encontrada");

    const fatura = resFatura.rows[0];
    if (fatura.status === "PAGA") throw new Error("Fatura já está paga");

    const valorTotal = parseFloat(fatura.valor_total);

    const resPago = await client.query(
      `SELECT COALESCE(SUM(valor), 0) AS pago FROM pagamentos WHERE id_fatura = $1`,
      [id_fatura]
    );
    const pagoAtual = parseFloat(resPago.rows[0].pago);
    const saldoDevedor = valorTotal - pagoAtual;

    let creditoGerado = 0;
    let valorQuitacao = valorPagamento;

    if (valorPagamento > saldoDevedor) {
      // paga o que falta e o excedente vira crédito
      valorQuitacao = saldoDevedor;
      creditoGerado = valorPagamento - saldoDevedor;
    }

    await client.query(
      `INSERT INTO pagamentos (id_fatura, valor, forma_pagamento) VALUES ($1, $2, $3)`,
      [id_fatura, valorQuitacao, forma_pagamento]
    );

    if (creditoGerado > 0) {
      await client.query(
        `INSERT INTO creditos_cliente (id_cliente, valor, tipo, id_fatura_origem)
         VALUES ($1, $2, 'GERADO', $3)`,
        [fatura.id_cliente, creditoGerado, id_fatura]
      );
    }

    const pagoFinal = pagoAtual + valorQuitacao;
    const status = calcularStatus(valorTotal, pagoFinal);
    await client.query(
      `UPDATE faturas SET status = $1, update_at = NOW() WHERE id_fatura = $2`,
      [status, id_fatura]
    );

    await client.query("COMMIT");

    await publicarEvento("fatura.pagamento_registrado", {
      id_fatura: Number(id_fatura),
      id_cliente: fatura.id_cliente,
      valor: valorQuitacao,
      forma_pagamento,
      credito_gerado: creditoGerado,
      status,
    });

    return {
      id_fatura: Number(id_fatura),
      valor_pago: pagoFinal,
      saldo_devedor: valorTotal - pagoFinal,
      credito_gerado: creditoGerado,
      status,
    };
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}

// Payload rico para a aba Financeira do cliente: ciclo, saldo de crédito,
// faturas com valor pago/saldo e os pagamentos de cada uma.
async function listarFaturasPorCliente(id_cliente) {
  const resCliente = await pool.query(
    `SELECT id_cliente, nome, ciclo_faturamento FROM clientes WHERE id_cliente = $1`,
    [id_cliente]
  );
  if (!resCliente.rows.length) throw new Error("Cliente não encontrado");
  const cliente = resCliente.rows[0];

  const resFaturas = await pool.query(
    `SELECT f.id_fatura, f.periodo_inicio, f.periodo_fim, f.valor_total, f.status,
            COALESCE(SUM(pg.valor), 0) AS valor_pago
     FROM faturas f
     LEFT JOIN pagamentos pg ON pg.id_fatura = f.id_fatura
     WHERE f.id_cliente = $1
     GROUP BY f.id_fatura
     ORDER BY f.created_at DESC`,
    [id_cliente]
  );

  const resPagamentos = await pool.query(
    `SELECT pg.id_pagamento, pg.id_fatura, pg.valor, pg.forma_pagamento, pg.data_pagamento
     FROM pagamentos pg
     JOIN faturas f ON f.id_fatura = pg.id_fatura
     WHERE f.id_cliente = $1
     ORDER BY pg.data_pagamento DESC`,
    [id_cliente]
  );

  const pagamentosPorFatura = {};
  for (const p of resPagamentos.rows) {
    (pagamentosPorFatura[p.id_fatura] ||= []).push(p);
  }

  let totalEmAberto = 0;
  const faturas = resFaturas.rows.map((f) => {
    const valorTotal = parseFloat(f.valor_total);
    const valorPago = parseFloat(f.valor_pago);
    const saldoDevedor = valorTotal - valorPago;
    if (f.status !== "PAGA") totalEmAberto += saldoDevedor;
    return {
      id_fatura: f.id_fatura,
      periodo_inicio: f.periodo_inicio,
      periodo_fim: f.periodo_fim,
      valor_total: valorTotal,
      valor_pago: valorPago,
      saldo_devedor: saldoDevedor,
      status: f.status,
      pagamentos: pagamentosPorFatura[f.id_fatura] || [],
    };
  });

  return {
    id_cliente: cliente.id_cliente,
    nome: cliente.nome,
    ciclo_faturamento: cliente.ciclo_faturamento,
    saldo_credito: await getSaldoCredito(pool, id_cliente),
    total_em_aberto: totalEmAberto,
    faturas,
  };
}

module.exports = {
  fecharFatura,
  registrarPagamento,
  listarFaturasPorCliente,
};
