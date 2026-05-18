const { getChannel, EXCHANGE } = require("./rabbitmq");
const colors = require("colors");

async function publicarEvento(routingKey, payload) {
  try {
    const channel = await getChannel();
    const mensagem = JSON.stringify({ ...payload, timestamp: new Date().toISOString() });
    channel.publish(EXCHANGE, routingKey, Buffer.from(mensagem), { persistent: true });
    console.log(colors.cyan(`[MOM] Evento publicado → ${routingKey}`), payload);
  } catch (err) {
    console.error(colors.red(`[MOM] Falha ao publicar evento ${routingKey}:`), err.message);
  }
}

module.exports = { publicarEvento };
