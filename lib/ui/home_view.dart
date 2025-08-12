import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_view_model.dart';
import 'app_drawer_view.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();
    return Scaffold(
        appBar : AppBar(title : Text("FlutterChat")),
        drawer : AppDrawerView(),
        body : Center(child : Text(vm.greeting))
    );
  }
}
