import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'menu.dart';
import 'menuAdm.dart';

// Função principal que inicia a aplicação Flutter
void main() {
  runApp(const MyApp());
}

// Widget Raiz da Aplicação
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove o banner "DEBUG" no canto superior direito
      debugShowCheckedModeBanner: false,
      // Título da aplicação (visível na multitarefa do sistema)
      title: "Login App",
      // Tela inicial da aplicação
      home: MeuAplicativo(),
      // Tema global da aplicação
      theme: ThemeData(
        // Cor de fundo padrão para os Scaffolds
        scaffoldBackgroundColor: Colors.white,
        // Paleta de cores primária (pode afetar outros widgets como AppBar)
        primarySwatch: Colors.grey,
        // Remove efeitos visuais de toque (ripple/highlight) indesejados
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        // Define a fonte padrão, se desejado (opcional)
        // fontFamily: 'SuaFonteCustomizada',
      ),
    );
  }
}

// Widget que representa a tela de Login
class MeuAplicativo extends StatelessWidget {
  // Controladores para obter o texto dos campos de Usuário e Senha
  final TextEditingController _login = TextEditingController();
  final TextEditingController _senha = TextEditingController();

  // Construtor (não precisa do super.key aqui se for StatelessWidget simples)
  MeuAplicativo({Key? key}) : super(key: key);

  // Função assíncrona para lidar com o processo de login
  Future<void> _enviarDados(BuildContext context) async {
    // URL do seu backend PHP (ajuste se necessário)
    const String url = "http://localhost/server/processa_bdCeet.php";

    // Dados a serem enviados para o backend
    final Map<String, String> data = {
      'acao': 'logar', // Ação que o backend deve executar
      'usuario': _login.text.trim().toUpperCase(), // Usuário em maiúsculas e sem espaços extras
      'senha': _senha.text.toUpperCase(), // Senha em maiúsculas (cuidado com case-sensitivity!)
    };

    // --- Bloco try-catch para tratamento de erros durante a requisição ---
    try {

      print("Enviando dados para $url: ${json.encode(data)}");
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'}, // Informa que o corpo é JSON
        body: json.encode(data), // Converte o Map para uma string JSON
      ).timeout(const Duration(seconds: 15)); // Define um timeout para a requisição

      print("Resposta recebida: Status=${response.statusCode}, Corpo=${response.body}");

      if (response.statusCode == 200) { // Verifica se a requisição foi bem-sucedida (HTTP OK)
        final responseBody = json.decode(response.body); // Decodifica a resposta JSON

        if (responseBody['status'] == 'success') { // Verifica o status lógico retornado pelo backend
          print("Login bem-sucedido (backend)");
          // Navega para a tela apropriada usando pushReplacement
          if (data['usuario']!.toLowerCase().startsWith('adm')) { // '!' assume que data['usuario'] não é null
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MenuAdm()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Menu()),
            );
          }
        } else {
          // Login falhou (resposta do backend indica falha)
          print("Login falhou (backend): ${responseBody['message']}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login falhou: ${responseBody['message'] ?? 'Erro desconhecido'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Erro na comunicação HTTP (status code diferente de 200)
        print("Falha na comunicação HTTP. Código: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro de comunicação (${response.statusCode}). Tente novamente.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      
      // ----- FIM DA CHAMADA HTTP REAL -----

    } catch (error) {
      // Captura erros gerais (problemas de rede, timeout, erro de parsing JSON, etc.)
      print("Erro durante o processo de login: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ocorreu um erro: $error. Verifique sua conexão.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Método que constrói a interface visual da tela de login
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SafeArea evita que o conteúdo fique atrás de barras de status ou notches
      body: SafeArea(
        child: Center( // Centraliza o conteúdo na tela
          child: SingleChildScrollView( // Permite rolagem se o conteúdo exceder a tela
            // Padding nas laterais e verticalmente
            padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 20.0),
            child: Column(
              // Alinha os widgets no centro do eixo principal (vertical)
              mainAxisAlignment: MainAxisAlignment.center,
              // Alinha os widgets no centro do eixo transversal (horizontal)
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // 1. Imagem Ilustrativa
                Container(
                  height: 200, // Altura fixa para a imagem
                  margin: const EdgeInsets.only(bottom: 25), // Espaço abaixo da imagem
                  child: Image.asset(
                    // --- IMPORTANTE: Crie a pasta 'assets' na raiz do seu projeto ---
                    // --- e coloque sua imagem lá. Declare a pasta no pubspec.yaml ---
                    'assets/logo_patri.png', // Caminho para a imagem
                    fit: BoxFit.contain, // Ajusta a imagem dentro do container
                    // Widget a ser mostrado se a imagem não puder ser carregada
                    errorBuilder: (context, error, stackTrace) {
                      print("Erro ao carregar imagem: $error");
                      return const Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                            Icon(Icons.error_outline, color: Colors.red, size: 50),
                            SizedBox(height: 8),
                            Text('Erro ao carregar imagem', textAlign: TextAlign.center, style: TextStyle(color: Colors.red)),
                            Text('Verifique o caminho e o pubspec.yaml', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey))
                         ],
                      );
                    },
                  ),
                ),
                // const SizedBox(height: 25), // Espaçamento movido para a margem do Container

                // 2. Título Principal "Log In"
                const Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // Preto levemente acinzentado
                  ),
                ),
                const SizedBox(height: 10), // Espaço abaixo do título

                // 3. Texto de Instrução
                Text(
                  'Insira suas informações para entrar no sistema',
                  textAlign: TextAlign.center, // Centraliza o texto
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600], // Tom de cinza médio
                  ),
                ),
                const SizedBox(height: 40), // Espaço maior antes dos campos

                // 4. Campo "Usuário"
                Align( // Alinha o rótulo à esquerda
                  alignment: Alignment.centerLeft,
                  child: Text(
                      'Usuário',
                       style: TextStyle(
                         color: Colors.grey[700], // Cinza mais escuro
                         fontSize: 14,
                         fontWeight: FontWeight.w500 // Peso semi-bold
                       ),
                    ),
                ),
                const SizedBox(height: 5), // Espaço entre rótulo e campo
                TextFormField(
                  controller: _login, // Associa o controlador
                  style: const TextStyle(color: Colors.black87, fontSize: 16), // Estilo do texto digitado
                  decoration: InputDecoration(
                    // Borda apenas na parte inferior
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[350]!), // Cor da linha quando inativo
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54), // Cor da linha quando focado
                    ),
                    // Padding interno reduzido
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                    isDense: true, // Torna o campo mais compacto verticalmente
                    // hintText: 'Seu usuário', // Texto placeholder (opcional)
                    // hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                  // Força o texto a ser digitado em maiúsculas
                  textCapitalization: TextCapitalization.characters,
                  // Ação ao pressionar "próximo" no teclado (vai para o campo de senha)
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 25), // Espaço entre os campos de usuário e senha

                // 5. Campo "Senha"
                Align( // Alinha o rótulo à esquerda
                   alignment: Alignment.centerLeft,
                   child: Text(
                      'Senha',
                      style: TextStyle(
                         color: Colors.grey[700],
                         fontSize: 14,
                         fontWeight: FontWeight.w500
                       ),
                    ),
                ),
                 const SizedBox(height: 5), // Espaço entre rótulo e campo
                TextFormField(
                  controller: _senha, // Associa o controlador
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[350]!),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                    isDense: true,
                    // hintText: 'Sua senha', // Texto placeholder (opcional)
                    // hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                  obscureText: true, // Esconde o texto digitado (para senhas)
                  // Força o texto a ser digitado em maiúsculas (geralmente não para senhas)
                  // textCapitalization: TextCapitalization.characters,
                   // Ação ao pressionar "concluído" no teclado (tenta fazer login)
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _enviarDados(context), // Chama o login ao pressionar "done"
                ),
                const SizedBox(height: 40), // Espaço maior antes do botão

                // 6. Botão "Log in"
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, // Cor do texto
                    backgroundColor: Colors.grey[850], // Cor de fundo (cinza escuro)
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Cantos arredondados
                    ),
                    // Padding interno do botão
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 60),
                    elevation: 2, // Leve sombra
                    // minimumSize: Size(double.infinity, 48), // Para ocupar largura total (removido para seguir a imagem)
                  ),
                  // Ação ao pressionar o botão
                  onPressed: () {
                    // Validação básica para campos vazios antes de enviar
                    if (_login.text.trim().isEmpty || _senha.text.isEmpty) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(
                           content: Text('Por favor, preencha o usuário e a senha.'),
                           backgroundColor: Colors.orangeAccent,
                           duration: Duration(seconds: 3),
                         ),
                       );
                    } else {
                      // Fecha o teclado antes de navegar ou mostrar snackbar
                      FocusScope.of(context).unfocus();
                      _enviarDados(context); // Chama a função de login
                    }
                  },
                  child: const Text(
                    'Log in',
                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                ),
                 const SizedBox(height: 20), // Espaço adicional no final da coluna
              ],
            ),
          ),
        ),
      ),
    );
  }
}