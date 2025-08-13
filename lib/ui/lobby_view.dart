import '../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_view_model.dart';
import 'app_drawer.dart';

class LobbyView extends StatelessWidget {
  const LobbyView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text('Lobby')),
      drawer: AppDrawer(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.pushNamed(context, '/CreateRoom'),
      ),
      body: vm.roomList.isEmpty
          ? Center(child: Text(l10n.no_rooms))
          : ListView.builder(
        itemCount: vm.roomList.length,
        itemBuilder: (context, index) {
          final Map room = vm.roomList[index];
          final roomName = room['roomName'];
          return Column(
            children: [
              ListTile(
                leading: room['private']
                    ? Image.asset('assets/private.png')
                    : Image.asset('assets/public.png'),
                title: Text(roomName),
                subtitle: Text(room['description']),
                onTap: () {
                  final hasInvite = vm.roomInvites.containsKey(roomName);
                  final isCreator = room['creator'] == vm.userName;
                  if (room['private'] && !hasInvite && !isCreator) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                        content: Text(l10n.no_invite),
                      ),
                    );
                  } else {
                    vm.joinRoom(roomName, context);
                  }
                },
              ),
              Divider(),
            ],
          );
        },
      ),
    );
  }
}
