import "dart:io";
import "package:path/path.dart";
import "package:path_provider/path_provider.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "flutter_chat_model.dart";
import "home.dart";
import "lobby.dart";
import "room.dart";
import "user_list.dart";
import "create_room.dart";
import "utils.dart" as utils; //manipula utils como módulo

void main() async {
  //garante que o flutter foi inicializado corretamente
  WidgetsFlutterBinding.ensureInitialized();
  print("## main(): FlutterChat starting");

  //carregar o diretório de documentos e as credenciais salvas
  await _init();

  runApp(FlutterChatMain());
}

Future<void> _init() async {
  // Obtém o diretório de arquivos do aplicativo
  utils.docsDir = await getApplicationDocumentsDirectory();

  // Verifica se o arquivo de credenciais existe
  var credentialsFile = File(join(utils.docsDir!.path, "credentials"));

  // Se existir, obtém as credenciais
  if (await credentialsFile.exists()) {
    utils.credentials = await credentialsFile.readAsString();
    print("## main(): credentials = ${utils.credentials}");
  }
}


class FlutterChatMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("## FlutterChat.build()");

    return ChangeNotifierProvider<FlutterChatModel>(
      create: (context) => FlutterChatModel(),
      child: MaterialApp(
        initialRoute: "/", //tela apontada por home
        routes: {
          "/Lobby": (screenContext) => Lobby(), //lista de salas
          "/Room": (screenContext) => Room(), //dentro de uma sala
          "/UserList": (screenContext) => UserList(), //lista de usuários no servidor
          "/CreateRoom": (screenContext) => CreateRoom() //criação de uma sala
        },
        home: Home(),
        navigatorKey: utils.navigatorKey
      ),
    );
  }
}