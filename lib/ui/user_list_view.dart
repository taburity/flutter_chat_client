import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_view_model.dart';
import 'app_drawer.dart';

class UserListView extends StatelessWidget {
  const UserListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text('User List')),
      drawer: AppDrawer(),
      body: GridView.builder(
        itemCount: vm.userList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (_, index) {
          final user = vm.userList[index];
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: GridTile(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Image.asset('assets/user.png'),
                    ),
                  ),
                  footer: Text(user['userName'], textAlign: TextAlign.center),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
