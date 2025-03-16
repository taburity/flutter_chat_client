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
  /// Whether the user list is expanded or not.
  bool _expanded = false;

  /// Message text the user enters to be posted to the room.
  late String _postMessage;

  /// Controller for the message list ListView.
  final ScrollController _controller = ScrollController();

  /// Controller for post TextFields
  final TextEditingController _postEditingController = TextEditingController();

  @override
  Widget build(final BuildContext inContext) {
    print("## Room.build()");

    return Consumer<FlutterChatModel>(
      builder: (BuildContext inContext, FlutterChatModel inModel, Widget? inChild) {
        Connector connector = Connector(inModel);
        return Scaffold(resizeToAvoidBottomInset : false,
          appBar : AppBar(title : Text(inModel.currentRoomName),
            actions : [
              // Function menu.
              PopupMenuButton(
                onSelected : (inValue) {
                  if (inValue == "invite") {
                    _inviteOrKick(inContext, "invite");
                  } else if (inValue == "leave") {
                    connector.leave(inModel.userName, inModel.currentRoomName, () {
                      // Clear out the information in the model about the current room and disable the
                      // Current Room drawer option.
                      inModel.removeRoomInvite(inModel.currentRoomName);
                      inModel.setCurrentRoomUserList({});
                      inModel.setCurrentRoomName(FlutterChatModel.DEFAULT_ROOM_NAME);
                      inModel.setCurrentRoomEnabled(false);
                      // Route back to the home screen.
                      Navigator.of(inContext).pushNamedAndRemoveUntil("/", ModalRoute.withName("/"));
                    });
                  } else if (inValue == "close") {
                    connector.close(inModel.currentRoomName, () {
                      // Route back to the home screen.
                      Navigator.of(inContext).pushNamedAndRemoveUntil("/", ModalRoute.withName("/"));
                    });
                  } else if (inValue == "kick") {
                    _inviteOrKick(inContext, "kick");
                  }
                },
                itemBuilder : (BuildContext inPMBContext) {
                  return <PopupMenuEntry<String>>[
                    // Options available for all users.
                    PopupMenuItem(value : "leave", child : Text("Leave Room")),
                    PopupMenuItem(value : "invite", child : Text("Invite A User")),
                    PopupMenuDivider(),
                    // Options available only for the user who created the room.
                    PopupMenuItem(value : "close", child : Text("Close Room"), enabled : inModel.creatorFunctionsEnabled),
                    PopupMenuItem(value : "kick", child : Text("Kick User"), enabled : inModel.creatorFunctionsEnabled)
                  ];
                }
              )
            ]
          ), /* End AppBar. */
          drawer : AppDrawer(),
          body : Padding(padding : EdgeInsets.fromLTRB(6, 14, 6, 6),
            child : Column(
              children : [
                /* User list. */
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
                ), /* End ExpansionPanelList. */
                Container(height : 10),
                /* Message list. */
                Expanded(child : ListView.builder(controller : _controller,
                  itemCount : inModel.currentRoomMessages.length,
                  itemBuilder : (inContext, inIndex) {
                    Map message = inModel.currentRoomMessages[inIndex];
                    return ListTile(
                      subtitle : Text(message["userName"]),
                      title : Text(message["message"])
                    );
                  }
                )), /* End message ListView. */
                Divider(),
                /* Post fields. */
                Row(children : [
                  Flexible(child : TextField(controller : _postEditingController,
                    onChanged : (String inText) => setState(() { _postMessage = inText; }),
                    decoration : new InputDecoration.collapsed(hintText : "Enter message"),
                  )),
                  Container(margin : new EdgeInsets.fromLTRB(2, 0, 2, 0),
                    child : IconButton(icon : Icon(Icons.send), color : Colors.blue,
                      onPressed : () {
                        // Post message to server.
                        connector.post(inModel.userName, inModel.currentRoomName, _postMessage, (inStatus) {
                          print("Room.post callback: inStatus = $inStatus");
                          // If it was successful, add to the list of messages for the current room so it shows
                          // up on the screen and jump the list to the bottom so the message appears.
                          if (inStatus == "ok") {
                            inModel.addMessage(inModel.userName, _postMessage);
                            _controller.jumpTo(_controller.position.maxScrollExtent);
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
    FlutterChatModel model = Provider.of<FlutterChatModel>(inContext);
    Connector connector = Connector(model);
    // Call server to get user list.
    connector.listUsers((inUserList) {
      print("## Room.listUsers: callback: inUserList=$inUserList");

      // Update the model with the new list of users.
      model.setUserList(inUserList);

      // Show dialog so user can select someone to invite or kick.
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
                        // Don't show this user in the list.
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
                                  // Hide user selection dialog.
                                  Navigator.of(inContext).pop();
                                });
                              } else {
                                connector.kick(user["userName"], model.currentRoomName, () {
                                  // Hide user selection dialog.
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