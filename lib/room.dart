import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "flutter_chat_model.dart" show FlutterChatModel;
import "app_drawer.dart";
import "connector.dart";

class Room extends StatefulWidget {
 Room({Key? key}) : super(key : key);
 @override
 _Room createState() => _Room();
}

class _Room extends State {
  bool _expanded = false; //Se a lista de usuários está expandida
  late String _postMessage; //Mensagem a ser postada
  //Controller para a listagem de mensagens
  final ScrollController _controller = ScrollController();
  //Controller para caixa de msg
  final TextEditingController _postEditingController = TextEditingController();

  @override
  Widget build(final BuildContext inContext) {
    print("## Room.build()");

    return Consumer<FlutterChatModel>(
      builder: (BuildContext inContext, FlutterChatModel inModel, Widget? inChild) {
        Connector connector = Connector(inModel);
        return Scaffold(resizeToAvoidBottomInset : true,
          appBar : AppBar(title : Text(inModel.currentRoomName),
            actions : [
              // O menu overflow (3 pontos)
              PopupMenuButton(
                onSelected : (inValue) {
                  if (inValue == "invite") {
                    _inviteOrKick(inContext, "invite");
                  } else if (inValue == "leave") {
                    connector.leave(inModel.userName, inModel.currentRoomName, () {
                      inModel.removeRoomInvite(inModel.currentRoomName);
                      inModel.setCurrentRoomUserList({});
                      inModel.setCurrentRoomName(FlutterChatModel.DEFAULT_ROOM_NAME);
                      inModel.setCurrentRoomEnabled(false);
                      Navigator.of(inContext).pushNamedAndRemoveUntil("/", ModalRoute.withName("/"));
                    });
                  } else if (inValue == "close") {
                    connector.close(inModel.currentRoomName, () {
                      Navigator.of(inContext).pushNamedAndRemoveUntil("/", ModalRoute.withName("/"));
                    });
                  } else if (inValue == "kick") {
                    _inviteOrKick(inContext, "kick");
                  }
                },
                itemBuilder : (BuildContext inPMBContext) {
                  return <PopupMenuEntry<String>>[
                    // Opções disponíveis para todos os usuários
                    PopupMenuItem(value : "leave", child : Text("Leave Room")),
                    PopupMenuItem(value : "invite", child : Text("Invite A User")),
                    PopupMenuDivider(),
                    // Opções disponíveis apenas para o criador da sala
                    PopupMenuItem(value : "close", child : Text("Close Room"), enabled : inModel.creatorFunctionsEnabled),
                    PopupMenuItem(value : "kick", child : Text("Kick User"), enabled : inModel.creatorFunctionsEnabled)
                  ];
                }
              )
            ]
          ),
          drawer : AppDrawer(),
          body : Padding(padding : EdgeInsets.fromLTRB(6, 14, 6, 6),
            child : Column(
              children : [
                //A lista de usuários
                ExpansionPanelList(
                  expansionCallback : (inIndex, inExpanded) => setState(() { _expanded = !_expanded; }),
                  children : [
                    ExpansionPanel(isExpanded : _expanded,
                      headerBuilder : (BuildContext context, bool isExpanded) => Text("  Users In Room"),
                      body : Padding(padding : EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child : Builder(builder : (inBuilderContext) {
                          List<Widget> userList = [ ];
                          for (var user in inModel.currentRoomUserList) {
                            userList.add(Text(user["userName"]));
                          }
                          return Column(children : userList);
                        })
                      )
                    )
                  ]
                ),
                Container(height : 10),
                //A lista de mensagens
                Expanded(child : ListView.builder(controller : _controller,
                  itemCount : inModel.currentRoomMessages.length,
                  itemBuilder : (inContext, inIndex) {
                    Map message = inModel.currentRoomMessages[inIndex];
                    return ListTile(
                      subtitle : Text(message["userName"]),
                      title : Text(message["message"])
                    );
                  }
                )),
                Divider(),
                //Postagem de mensagem
                Row(children : [
                  Flexible(child : TextField(controller : _postEditingController,
                    onChanged : (String inText) => setState(() { _postMessage = inText; }),
                    decoration : new InputDecoration.collapsed(hintText : "Enter message"),
                  )),
                  Container(margin : new EdgeInsets.fromLTRB(2, 0, 2, 0),
                    child : IconButton(icon : Icon(Icons.send), color : Colors.blue,
                      onPressed : () {
                        connector.post(inModel.userName, inModel.currentRoomName, _postMessage, (inStatus) {
                          print("Room.post callback: inStatus = $inStatus");
                          if (inStatus == "ok") {
                            inModel.addMessage(inModel.userName, _postMessage);
                            //sempre exibe o fim da listagem de mensagens
                            _controller.jumpTo(_controller.position.maxScrollExtent);
                            _postEditingController.clear();
                          }
                        });
                      }
                    )
                  )
                ])
              ]
            )
          )
        );
      }
    );
  }

  /// Show the user the invite dialog and handle taps on users.
  ///
  /// @param inContent      The BuildContext from the calling widget.
  /// @param inInviteOrKick "invite" to invite a user, "kick" to kick them.
  _inviteOrKick(final BuildContext inContext, final String inInviteOrKick) {
    FlutterChatModel model = Provider.of<FlutterChatModel>(inContext, listen: false);
    Connector connector = Connector(model);
    connector.listUsers((inUserList) {
      print("## Room.listUsers: callback: inUserList=$inUserList");
      model.setUserList(inUserList);
      showDialog(context : inContext,
        builder : (BuildContext inDialogContext) {
                return AlertDialog(title : Text("Select user to $inInviteOrKick"),
                  content : Container(width : double.maxFinite, height : double.maxFinite / 2,
                    child : ListView.builder(
                      itemCount : inInviteOrKick == "invite" ? model.userList.length : model.currentRoomUserList.length,
                      itemBuilder : (BuildContext inBuildContext, int inIndex) {
                        Map user;
                        if (inInviteOrKick == "invite") {
                          user = model.userList[inIndex];
                        } else {
                          user = model.currentRoomUserList[inIndex];
                        }
                        // Omite o usuário da listagem
                        if (user["userName"] == model.userName) { return Container(); }
                        // Each user will be displayed in a box with a gradient background, just for fun!
                        return Container(
                          decoration : BoxDecoration(
                            borderRadius : BorderRadius.all(Radius.circular(15.0)),
                            border : Border(
                              bottom : BorderSide(), top : BorderSide(),
                              left : BorderSide(), right : BorderSide()
                            ),
                            gradient : LinearGradient(begin : Alignment.topLeft, end : Alignment.bottomRight,
                              stops : [ .1, .2, .3, .4, .5, .6, .7, .8, .9],
                              colors : [
                                Color.fromRGBO(250, 250, 0, .75), Color.fromRGBO(250, 220, 0, .75),
                                Color.fromRGBO(250, 190, 0, .75), Color.fromRGBO(250, 160, 0, .75),
                                Color.fromRGBO(250, 130, 0, .75), Color.fromRGBO(250, 110, 0, .75),
                                Color.fromRGBO(250, 80, 0, .75), Color.fromRGBO(250, 50, 0, .75),
                                Color.fromRGBO(250, 0, 0, .75)
                              ]
                            )
                          ),
                          margin : EdgeInsets.only(top : 10.0),
                          child : ListTile(title : Text(user["userName"]),
                            onTap : () {
                              if (inInviteOrKick == "invite") {
                                connector.invite(user["userName"], model.currentRoomName, model.userName, () {
                                  Navigator.of(inContext).pop();
                                });
                              } else {
                                connector.kick(user["userName"], model.currentRoomName, () {
                                  Navigator.of(inContext).pop();
                                });
                              }
                            }
                          )
                        );
                      }
                    )
                  )
                );
              }
        );
      });
    }

}