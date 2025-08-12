import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'domain/model.dart';
import 'ui/chat_view_model.dart';
import 'utils.dart' as utils;

import 'ui/home_view.dart';
import 'ui/lobby_view.dart';
import 'ui/room_view.dart';
import 'ui/user_list_view.dart';
import 'ui/create_room_view.dart';
import 'ui/login_view.dart';

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
  final credentialsFile = File(join(utils.docsDir!.path, 'credentials'));

  // Se existir, obtém as credenciais
  if (await credentialsFile.exists()) {
    utils.credentials = await credentialsFile.readAsString();
    print('## main(): credentials = ${utils.credentials}');
  }
}

class FlutterChatMain extends StatelessWidget {
  const FlutterChatMain({super.key});

  @override
  Widget build(BuildContext context) {
    final hasCreds = utils.credentials != null && utils.credentials!.isNotEmpty;

    return ChangeNotifierProvider<ChatViewModel>(
      create: (_) => ChatViewModel(Model(), AppLocalizations.of(context)!),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            navigatorKey: utils.navigatorKey,
            initialRoute: hasCreds ? '/' : '/Login',
            routes: {
              '/': (_) => HomeView(),
              '/Lobby': (_) => LobbyView(),
              '/Room': (_) => RoomView(),
              '/UserList': (_) => UserListView(),
              '/CreateRoom': (_) => CreateRoomView(),
              '/Login': (_) => LoginView(),
            },
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('en')
            ],
          );
        },
      ),
    );
  }
}
