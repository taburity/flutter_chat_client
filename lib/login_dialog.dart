import "dart:io";
import "package:path/path.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "flutter_chat_model.dart";
import "connector.dart";
import "utils.dart" as utils;


class LoginDialog extends StatelessWidget {

  final GlobalKey<FormState> _loginFormKey = new GlobalKey<FormState>();
  late String _userName;
  late String _password;

  @override
  Widget build(final BuildContext inContext) {
    print("## LoginDialog.build()");

    return Consumer<FlutterChatModel>(
      builder: (BuildContext inContext, FlutterChatModel inModel, Widget? inChild) {
        Connector connector = Connector(inModel);
        return AlertDialog(
          content : Container(height : 220,
            child : Form(
              key : _loginFormKey,
              child : Column(
                children : [
                  Text("Enter a username and password to register with the server", textAlign : TextAlign.center,
                    style : TextStyle(color : Theme.of(utils.rootBuildContext!).colorScheme.secondary, fontSize : 18)
                  ),
                  SizedBox(height : 20),
                  TextFormField(
                    validator : (String? inValue) {
                      if (inValue!.length == 0 || inValue.length > 10) {
                        return "Please enter a username no more than 10 characters long";
                      }
                      return null;
                    },
                    onSaved : (String? inValue) { _userName = inValue!; },
                    decoration : InputDecoration(hintText : "Username", labelText : "Username")
                  ),
                  TextFormField(obscureText : true,
                    validator : (String? inValue) {
                      if (inValue!.length == 0) { return "Please enter a password"; }
                      return null;
                    },
                    onSaved : (String? inValue) { _password = inValue!; },
                    decoration : InputDecoration(hintText : "Password", labelText : "Password")
                  )
                ]
              )
            )
          ),
          actions : [
            TextButton(
              child : Text("Log In"),
              onPressed : () {
                if (_loginFormKey.currentState!.validate()) {
                  _loginFormKey.currentState!.save();
                  connector.connectToServer(() {
                    connector.validate(_userName, _password, (inStatus) async {
                      print("## LoginDialog: validate callback: inResponseStatus = $inStatus");
                      if (inStatus == "ok") { //usuário autenticado
                        inModel.setUserName(_userName);
                        Navigator.of(utils.rootBuildContext!).pop();
                        inModel.setGreeting("Welcome back, $_userName!");
                      } else if (inStatus == "fail") { // O nome do usuário já está sendo usado
                        ScaffoldMessenger.of(utils.rootBuildContext!).showSnackBar(
                          SnackBar(backgroundColor : Colors.red, duration : Duration(seconds : 2),
                            content : Text("Sorry, that username is already taken")
                          )
                        );
                      } else if (inStatus == "created") { //usuário novo
                        var credentialsFile = File(join(utils.docsDir!.path, "credentials"));
                        await credentialsFile.writeAsString("$_userName============$_password");
                        inModel.setUserName(_userName);
                        Navigator.of(utils.rootBuildContext!).pop();
                        inModel.setGreeting("Welcome to the server, $_userName!");
                      }
                    }, inModel);
                  }, inModel);
                }
              }
            )
          ]
        );
      }
    );
  }

  void validateWithStoredCredentials(final String inUserName, final String inPassword,
      BuildContext inContext) {
    print("## LoginDialog.validateWithStoredCredentials(): inUserName = $inUserName, inPassword = $inPassword");
    FlutterChatModel model = Provider.of<FlutterChatModel>(inContext, listen:false);
    Connector connector = Connector(model);

    connector.connectToServer(() {
      connector.validate(inUserName, inPassword, (inStatus) {
        print("## LoginDialog: validateWithStoredCredentials callback: inStatus = $inStatus");
        //Tudo certo. O usuário existente pode ser tratado como novo usuário caso o servidor tenha reiniciado
        if (inStatus == "ok" || inStatus == "created") {
          model.setUserName(inUserName);
          model.setGreeting("Welcome back, $inUserName!");
        //O servidor reiniciou e outro usuário está usando o nome em questão
        } else if (inStatus == "fail") {
          showDialog(context : utils.rootBuildContext!, barrierDismissible : false,
            builder : (final BuildContext inDialogContext) => AlertDialog(
              title : Text("Validation failed"),
              content : Text("It appears that the server has restarted and the username you last used was "
                "subsequently taken by someone else.\n\nPlease re-start FlutterChat and choose a different username."
              ),
              actions : [
                TextButton(child : Text("Ok"), onPressed : () {
                  //O arquivo de credenciais é apagado
                  var credentialsFile = File(join(utils.docsDir!.path, "credentials"));
                  credentialsFile.deleteSync();
                  exit(0); //O aplicativo é encerrado
                })
              ]
            )
          );
        }
      }, model);
    }, model);
  }

}
