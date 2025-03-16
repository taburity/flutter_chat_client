import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "flutter_chat_model.dart" show FlutterChatModel;
import "app_drawer.dart";
import "login_dialog.dart";
import "utils.dart" as utils;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();

    // Aguarda o primeiro frame ser renderizado para chamar executeAfterBuild()
    WidgetsBinding.instance.addPostFrameCallback((_) {
      executeAfterBuild(this.context);
    });
  }

  @override
  Widget build(final BuildContext inContext) {
    print("## Home.build()");
    utils.rootBuildContext = inContext;
    return Consumer<FlutterChatModel>(
        builder: (BuildContext inContext, FlutterChatModel inModel, Widget? inChild) {
          return Scaffold(
              appBar : AppBar(title : Text("FlutterChat")),
              drawer : AppDrawer(),
              body : Center(child : Text(inModel.greeting))
          );
        }
    );
  }

  Future<void> executeAfterBuild(BuildContext inContext) async {
    if (utils.credentials!=null && utils.credentials!.isNotEmpty) {
      print("## main(): Credential file exists, calling server with stored credentials");
      List credParts = utils.credentials!.split("============");
      LoginDialog().validateWithStoredCredentials(credParts[0], credParts[1], inContext);
    } else {
      print("## main(): Credential file does NOT exist, prompting for credentials");
      await showDialog(context : inContext, barrierDismissible : false,
          builder : (BuildContext inDialogContext) {
            return LoginDialog();
          }
      );
    }
  }

}

/**
 * Esse código deve verificar se as credenciais do usuário estão salvas em um arquivo local.
 * Se sim, deve fazer chamada para autenticar via servidor.
 * Se a autenticação for bem sucedida, deve exibir home.
 * Se a autenticação falhar, deve exibir a tela de login.
 * Se não houver credencias salvas, deve exibir a tela de login.
 * O login deve exibir home em caso de autenticação bem sucedida.
 */

/**
 * Formato do arquivo de credenciais:
 * xxx============yyy
 * xxx é o nome de usuário limitado à 10 caracteres
 * yyy é a senha limitada à 10 caracteres
 * o delimitador são 12 sinais de igualdade
 */