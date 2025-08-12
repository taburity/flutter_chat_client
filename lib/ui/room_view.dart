import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_view_model.dart';
import 'app_drawer_view.dart';

class RoomView extends StatefulWidget {
  @override
  _RoomViewState createState() => _RoomViewState();
}

class _RoomViewState extends State<RoomView> {
  bool _expanded = false;
  final _scrollController = ScrollController();
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(vm.currentRoomName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'leave':
                  vm.leaveRoom(context);
                  break;
                case 'close':
                  vm.closeRoom(context);
                  break;
                case 'invite':
                case 'kick':
                  _showUserActionDialog(context, value);
                  break;
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'leave', child: Text('Leave Room')),
              PopupMenuItem(value: 'invite', child: Text('Invite A User')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'close', child: Text('Close Room'), enabled: vm.creatorFunctionsEnabled),
              PopupMenuItem(value: 'kick', child: Text('Kick User'), enabled: vm.creatorFunctionsEnabled),
            ],
          )
        ],
      ),
      drawer: AppDrawerView(),
      body: Padding(
        padding: EdgeInsets.fromLTRB(6, 14, 6, 6),
        child: Column(
          children: [
            ExpansionPanelList(
              expansionCallback: (_, __) => setState(() => _expanded = !_expanded),
              children: [
                ExpansionPanel(
                  isExpanded: _expanded,
                  headerBuilder: (_, __) => Text('  Users In Room'),
                  body: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Column(
                      children: vm.currentRoomUserList
                          .map<Widget>((user) => Text(user['userName']))
                          .toList(),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: vm.currentRoomMessages.length,
                itemBuilder: (_, index) {
                  final msg = vm.currentRoomMessages[index];
                  return ListTile(
                    subtitle: Text(msg['userName']),
                    title: Text(msg['message']),
                  );
                },
              ),
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration.collapsed(hintText: 'Enter message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    final text = _textController.text.trim();
                    if (text.isNotEmpty) {
                      vm.postMessage(text);
                      _scrollToBottom();
                      _textController.clear();
                    }
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _scrollToBottom(){
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients){
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _showUserActionDialog(BuildContext context, String action) {
    final vm = context.read<ChatViewModel>();
    final users = action == 'invite' ? vm.userList : vm.currentRoomUserList;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Select user to $action'),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.4,
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (_, index) {
              final user = users[index];
              final name = user['userName'];
              if (name == vm.userName) return SizedBox.shrink();
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                margin: EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text(name),
                  onTap: () {
                    if (action == 'invite') {
                      vm.inviteUser(name, () => Navigator.pop(context));
                    } else {
                      vm.kickUser(name, () => Navigator.pop(context));
                    }
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
