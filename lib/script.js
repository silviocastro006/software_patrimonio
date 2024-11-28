$.ajax({
    url: 'http://localhost/server/processa_bdCeet.php',
    type: 'POST',
    contentType: 'application/json',
    data: JSON.stringify({
        comando: 'inserir',
        marca: 'Marca Exemplo',
        modelo: 'Modelo Exemplo',
        cor: 'Cor Exemplo',
        codigo: 'Código Exemplo',
        data: '2024-10-31',
        foto: 'base64string', // Substitua pelo seu base64
        status: 'ativo', // Adicione o status (por exemplo, 'ativo')
        setor: 'setor exemplo', // Adicione o setor (exemplo)
        descricao: 'Descrição do patrimônio' // Adicione uma descrição
    }),
    success: function(response) {
        console.log(response);
    },
    error: function(xhr, status, error) {
        console.error("Erro: " + error);
    }
});

fetch('seu_script.php', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      acao: 'listarMarcas', // ou 'carregarMarca' se precisar carregar uma marca específica
    }),
  })
    .then(response => response.json())
    .then(data => {
      console.log(data); // Verifique se as marcas estão sendo retornadas corretamente
    })
    .catch(error => {
      console.error('Erro na requisição:', error);
    });
  