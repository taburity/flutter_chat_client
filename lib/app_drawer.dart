import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "flutter_chat_model.dart" show FlutterChatModel;
import "connector.dart";

class AppDrawer extends StatelessWidget {

  @override
  Widget build(final BuildContext inContext) {
    print("## AppDrawer.build()");

    return Consumer<FlutterChatModel>(
        builder: (BuildContext inContext, FlutterChatModel inModel, Widget? inChild){
          Connector connector = Connector(inModel);
          return Drawer(
              child: Column(children: [
                Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/drawback01.jpg"),
                            //dimensiona a imagem com o menor tamanho possível, cobrindo a caixa
                            fit: BoxFit.cover
                        )
                    ),
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 30, 0, 15),
                        child: ListTile(
                            title: Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                                child: Center(
                                    child: Text(inModel.userName,
                                        style: TextStyle(color: Colors.white, fontSize: 24)
                                    )
                                )
                            ),
                            subtitle: Center(
                                child: Text(inModel.currentRoomName,
                                    style: TextStyle(color: Colors.white, fontSize: 16)
                                )
                            )
                        )
                    )
                ),
                // Lobby (room list).
                Padding(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: ListTile(
                        leading: Icon(Icons.list),
                        title: Text("Lobby"),
                        onTap: () {
                          // Navega para a tela de lobby, garantindo as outras sejam removidas da navegação, exceto Home
                          Navigator.of(inContext).pushNamedAndRemoveUntil("/Lobby", ModalRoute.withName("/"));
                          connector.listRooms((inRoomList) {
                            print("## AppDrawer.listRooms: callback: inRoomList=$inRoomList");
                            inModel.setRoomList(inRoomList);
                          });
                        }
                    )
                ),
                // Current Room.
                ListTile(
                    enabled: inModel.currentRoomEnabled,
                    leading: Icon(Icons.forum),
                    title: Text("Current Room"),
                    onTap: () {
                      // Navega para a tela da sala, garantindo as outras sejam removidas da navegação, exceto Home
                      Navigator.of(inContext).pushNamedAndRemoveUntil("/Room", ModalRoute.withName("/"));
                    }
                ),
                // User List.
                ListTile(
                    leading: Icon(Icons.face),
                    title: Text("User List"),
                    onTap: () {
                      // Navega para a tela de usuários, garantindo as outras sejam removidas da navegação, exceto Home
                      Navigator.of(inContext).pushNamedAndRemoveUntil("/UserList", ModalRoute.withName("/"));
                      connector.listUsers((inUserList) {
                        print("## AppDrawer.listUsers: callback: inUserList = $inUserList");
                        inModel.setUserList(inUserList);
                      });
                    }
                )
              ])
          );
        }
    );
  }
}
