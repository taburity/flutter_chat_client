import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "flutter_chat_model.dart" show FlutterChatModel, model;
import "app_drawer.dart";

class UserList extends StatelessWidget {

  @override
  Widget build(final BuildContext inContext) {
    print("## UserList.build()");

    return Consumer<FlutterChatModel>(
      builder: (BuildContext inContext, FlutterChatModel inModel, Widget? inChild) {
        print("users: " + (inModel.userList.length).toString());
        return Scaffold(
          appBar : AppBar(title : Text("User List")),
          drawer : AppDrawer(),
          body :  GridView.builder(
            itemCount: inModel.userList.length,
            gridDelegate : SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount : 3),
            itemBuilder : (BuildContext inContext, int inIndex) {
              Map user = inModel.userList[inIndex];
              print(user);
              return Padding(padding : EdgeInsets.fromLTRB(10, 10, 10, 10), child : Card(
                child : Padding(padding : EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child : GridTile(
                    child : Center(child : Padding(padding : EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child : Image.asset("assets/user.png")
                    )),
                    footer : Text(user["userName"], textAlign : TextAlign.center)
                  )
                )
              ));
            }
          )
        );
      }
    );
  }

}