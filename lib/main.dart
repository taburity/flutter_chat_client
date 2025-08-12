import 'dart:io';
import 'package:flutter/material.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  await _init();
  runApp(FlutterChatMain());
}

Future<void> _init() async {
  utils.docsDir = await getApplicationDocumentsDirectory();
  final credentialsFile = File(join(utils.docsDir!.path, 'credentials'));
  if (await credentialsFile.exists()) {
    utils.credentials = await credentialsFile.readAsString();
    print('## main(): credentials = ${utils.credentials}');
  }
}

class FlutterChatMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hasCreds = utils.credentials != null && utils.credentials!.isNotEmpty;

    return ChangeNotifierProvider<ChatViewModel>(
      create: (_) => ChatViewModel(Model()),
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
          );
        },
      ),
    );
  }
}
