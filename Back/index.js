const express = require("express");
const colors = require("colors");
const router = require("./routers");

const config = require('./config/database')
const database = require('./database/database')


const app = express();

app.use(express.json())

router(app);

app.get("/home", (req, res) => {
  res.send("Estou rodando");
});

async function startServer() {
    try {
        await database.init();
        
        app.listen(config.port, () => {
            console.log('🚀 =================================');
            console.log(`🚀 Servidor iniciado na porta ${config.port}`);
            console.log(`🚀 URL: http://localhost:${config.port}`);
            console.log(`🚀 Health: http://localhost:${config.port}/health`);
            console.log('🚀 =================================');
        });
    } catch (error) {
        console.error('❌ Falha na inicialização:', error);
        process.exit(1);
    }
}

if (require.main === module) {
    startServer();
}

