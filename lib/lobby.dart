import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "flutter_chat_model.dart" show FlutterChatModel;
import "app_drawer.dart";
import "connector.dart";

class Lobby extends StatelessWidget {

  @override
  Widget build(final BuildContext inContext) {
    print("## Lobby.build()");

    return Consumer<FlutterChatModel>(
      builder: (BuildContext inContext, FlutterChatModel inModel, Widget? inChild) {
        Connector connector = Connector(inModel);
        return Scaffold(
          appBar : AppBar(title : Text("Lobby")),
          drawer : AppDrawer(),
          // Add room.
          floatingActionButton : FloatingActionButton(
            child : Icon(Icons.add, color : Colors.white),
            onPressed : () { Navigator.pushNamed(inContext, "/CreateRoom"); }
          ),
          body : inModel.roomList.length == 0 ? Center(child : Text("There are no rooms yet. Why not add one?")) :
            ListView.builder(
            itemCount : inModel.roomList.length,
            itemBuilder : (BuildContext inBuildContext, int inIndex) {
              Map room = inModel.roomList[inIndex];
              String roomName = room["roomName"];
              return Column(
                children : [
                  ListTile(
                    leading : room["private"] ? Image.asset("assets/private.png") : Image.asset("assets/public.png"),
                    title : Text(roomName),
                    subtitle : Text(room["description"]),
                    // Enter room (if not private).
                    onTap : () {
                      //o usuário não pode entrar na sala
                      if (room["private"] && !inModel.roomInvites.containsKey(roomName) &&
                        room["creator"] != inModel.userName
                      ) {
                        ScaffoldMessenger.of(inBuildContext).showSnackBar(
                          SnackBar(backgroundColor : Colors.red, duration : Duration(seconds : 2),
                            content : Text("Sorry, you can't enter a private room without an invite")
                          )
                        );
                      } else { //a sala é pública ou o usuário tem convite ou o usuário é o criador da sala
                        //avisa ao servidor
                        connector.join(inModel.userName, roomName, (inStatus, inRoomDescriptor) {
                          print("## Lobby.joined callback: inStatus = $inStatus, inRoomDescriptor = $inRoomDescriptor");
                          //o usuário entrou na sala
                          if (inStatus == "joined") {
                            inModel.setCurrentRoomName(inRoomDescriptor["roomName"]);
                            inModel.setCurrentRoomUserList(inRoomDescriptor["users"]);
                            inModel.setCurrentRoomEnabled(true);
                            inModel.clearCurrentRoomMessages();
                            // Habilita funções de criador, se este for o caso do usuário
                            if (inRoomDescriptor["creator"] == inModel.userName) {
                              inModel.setCreatorFunctionsEnabled(true);
                            } else {
                              inModel.setCreatorFunctionsEnabled(false);
                            }
                            //exibe a tela da sala
                            Navigator.pushNamed(inContext, "/Room");
                          } else if (inStatus == "full") { //a sala está cheia
                            ScaffoldMessenger.of(inBuildContext).showSnackBar(
                              SnackBar(backgroundColor : Colors.red, duration : Duration(seconds : 2),
                                content : Text("Sorry, that room is full")
                              )
                            );
                          }
                        });
                      }
                    }
                  ),
                  Divider()
                ]
              );
            }
          )
        );
      }
    );
  }

}