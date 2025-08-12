import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_view_model.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();

    return Drawer(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/drawback01.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 30, 0, 15),
              child: ListTile(
                title: Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Center(
                    child: Text(
                      vm.userName,
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                ),
                subtitle: Center(
                  child: Text(
                    vm.currentRoomName,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: ListTile(
              leading: Icon(Icons.list),
              title: Text('Lobby'),
              onTap: () async {
                Navigator.of(context).pushNamedAndRemoveUntil('/Lobby', ModalRoute.withName('/'));
                await vm.fetchRooms();
              },
            ),
          ),
          ListTile(
            enabled: vm.currentRoomEnabled,
            leading: Icon(Icons.forum),
            title: Text('Current Room'),
            onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/Room', ModalRoute.withName('/')),
          ),
          ListTile(
            leading: Icon(Icons.face),
            title: Text('User List'),
            onTap: () async {
              Navigator.of(context).pushNamedAndRemoveUntil('/UserList', ModalRoute.withName('/'));
              await vm.fetchUsers();
            },
          ),
        ],
      ),
    );
  }
}
