class userControler {
  buscar() {
    return "Buscando usuarios...";
  }

  criar(){
   return "Criando usuario"
  }

  atualizar(id){
   return "Atualizando usuario id: " + id + " !!"
  }

  apagar(id){
   return "Deletando usuario id: " + id + " !!"
  }
}

module.exports = new userControler();
