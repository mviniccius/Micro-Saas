const amqp = require("amqplib");
const colors = require("colors");

const RABBITMQ_URL = process.env.RABBITMQ_URL || "amqp://admin:admin@localhost:5672";
const EXCHANGE = "padaria_events";
const RETRY_DELAY_MS = 5000;
const MAX_RETRIES = 10;

let channel = null;

async function connect(tentativa = 1) {
  try {
    const connection = await amqp.connect(RABBITMQ_URL);
    channel = await connection.createChannel();
    await channel.assertExchange(EXCHANGE, "topic", { durable: true });

    connection.on("error", () => {
      channel = null;
    });
    connection.on("close", () => {
      channel = null;
    });

    console.log(colors.bgMagenta("[MOM] RabbitMQ conectado com sucesso"));
    return channel;
  } catch (err) {
    if (tentativa <= MAX_RETRIES) {
      console.log(colors.yellow(`[MOM] RabbitMQ indisponível. Tentativa ${tentativa}/${MAX_RETRIES}. Aguardando ${RETRY_DELAY_MS / 1000}s...`));
      await new Promise((resolve) => setTimeout(resolve, RETRY_DELAY_MS));
      return connect(tentativa + 1);
    }
    console.error(colors.red("[MOM] Não foi possível conectar ao RabbitMQ após várias tentativas."));
    throw err;
  }
}

async function getChannel() {
  if (!channel) await connect();
  return channel;
}

module.exports = { connect, getChannel, EXCHANGE };
