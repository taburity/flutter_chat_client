import 'package:flutter/material.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'chat_view_model.dart';
import 'app_drawer.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
        appBar : AppBar(title : Text(l10n.title)),
        drawer : AppDrawer(),
        body : Center(child : Text(vm.greeting))
    );
  }
}
