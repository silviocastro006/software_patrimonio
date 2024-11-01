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
        foto: 'base64string' // Substitua pelo seu base64
    }),
    success: function(response) {
        console.log(response);
    },
    error: function(xhr, status, error) {
        console.error("Erro: " + error);
    }
});
