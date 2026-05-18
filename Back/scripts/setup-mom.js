require("dotenv").config({ path: require("path").resolve(__dirname, "../.env") });
const amqp = require("amqplib");
const colors = require("colors");

const RABBITMQ_URL = process.env.RABBITMQ_URL || "amqp://admin:admin@localhost:5672";
const EXCHANGE = "padaria_events";

const CONFIGURACAO = [
  {
    fila: "fila_pedido_criado",
    routingKey: "pedido.criado",
    descricao: "Novos pedidos → linha de produção",
  },
  {
    fila: "fila_pedido_status",
    routingKey: "pedido.status_atualizado",
    descricao: "Mudanças de status → notificações",
  },
];

async function setup() {
  let connection;
  try {
    console.log(colors.cyan("\n=== Setup do MOM – RabbitMQ ===\n"));
    console.log(colors.white(`Conectando em: ${RABBITMQ_URL}`));

    connection = await amqp.connect(RABBITMQ_URL);
    const channel = await connection.createChannel();

    await channel.assertExchange(EXCHANGE, "topic", { durable: true });
    console.log(colors.green(`\n✔ Exchange criada: "${EXCHANGE}" (tipo: topic, durable: true)`));

    console.log(colors.cyan("\n--- Filas ---"));
    for (const item of CONFIGURACAO) {
      await channel.assertQueue(item.fila, { durable: true });
      await channel.bindQueue(item.fila, EXCHANGE, item.routingKey);
      console.log(colors.green(`✔ Fila: "${item.fila}"`));
      console.log(colors.white(`   Routing key : ${item.routingKey}`));
      console.log(colors.white(`   Descrição   : ${item.descricao}`));
    }

    console.log(colors.bgGreen("\n✔ Setup concluído! Infraestrutura MOM pronta.\n"));

    await channel.close();
    await connection.close();
    process.exit(0);
  } catch (err) {
    console.error(colors.red("\n✖ Erro no setup:"), err.message);
    console.error(colors.yellow("Verifique se o RabbitMQ está rodando: docker compose up rabbitmq\n"));
    if (connection) await connection.close().catch(() => {});
    process.exit(1);
  }
}

setup();
