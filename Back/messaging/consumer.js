const { connect, EXCHANGE } = require("./rabbitmq");
const colors = require("colors");

const FILAS = {
  PEDIDO_CRIADO: "fila_pedido_criado",
  STATUS_ATUALIZADO: "fila_pedido_status",
};

const STATUS_LABELS = { P: "Pendente", A: "Em Produção", C: "Concluído", X: "Cancelado" };

async function iniciarConsumidor() {
  try {
    const channel = await connect();

    await channel.assertQueue(FILAS.PEDIDO_CRIADO, { durable: true });
    await channel.bindQueue(FILAS.PEDIDO_CRIADO, EXCHANGE, "pedido.criado");

    channel.consume(FILAS.PEDIDO_CRIADO, (msg) => {
      if (!msg) return;
      const evento = JSON.parse(msg.content.toString());
      console.log(colors.bgGreen("\n[CONSUMIDOR] ✔ Novo pedido recebido pela linha de produção:"));
      console.log(colors.green(`  → Pedido #${evento.id_pedido} | Cliente ID: ${evento.id_cliente} | Total: R$ ${evento.valor_total}`));
      console.log(colors.green(`  → Recebido em: ${evento.timestamp}\n`));
      channel.ack(msg);
    });

    await channel.assertQueue(FILAS.STATUS_ATUALIZADO, { durable: true });
    await channel.bindQueue(FILAS.STATUS_ATUALIZADO, EXCHANGE, "pedido.status_atualizado");

    channel.consume(FILAS.STATUS_ATUALIZADO, (msg) => {
      if (!msg) return;
      const evento = JSON.parse(msg.content.toString());
      const de = STATUS_LABELS[evento.status_anterior] || evento.status_anterior;
      const para = STATUS_LABELS[evento.status_novo] || evento.status_novo;
      console.log(colors.bgYellow("\n[CONSUMIDOR] ✔ Status de pedido atualizado:"));
      console.log(colors.yellow(`  → Pedido #${evento.id_pedido} | ${de} → ${para}`));
      console.log(colors.yellow(`  → Atualizado em: ${evento.timestamp}\n`));
      channel.ack(msg);
    });

    console.log(colors.bgMagenta("[MOM] Consumidor ativo. Aguardando eventos...\n"));
  } catch (err) {
    console.error(colors.red("[MOM] Erro ao iniciar consumidor:"), err.message);
  }
}

module.exports = { iniciarConsumidor };
