class Model {

  String greeting = "";
  String userName = "";
  static const String DEFAULT_ROOM_NAME = "Not currently in a room";
  String currentRoomName = DEFAULT_ROOM_NAME;
  List currentRoomUserList = [];
  // Indica se a opção Current Room está habilitada no drawer
  bool currentRoomEnabled = false;
  // Os elementos são um mapa na forma { userName : "", message : "" }
  List currentRoomMessages = [];
  List roomList = [];
  List userList = [];
  bool creatorFunctionsEnabled = false;
  Map roomInvites = {};

  void addMessage(String inUserName, String inMessage) {
    currentRoomMessages.add({"userName": inUserName, "message": inMessage});
  }

  void clearCurrentRoomMessages() {
    currentRoomMessages = [];
  }

  void setRoomListFromServerMap(Map inRoomList) {
    roomList = inRoomList.values.toList();
  }

  void setUserListFromServerMap(Map inUserList) {
    userList = inUserList.values.toList();
  }

  void setCurrentRoomUserListFromServerMap(Map inUserList) {
    currentRoomUserList = inUserList.values.toList();
  }

  void addRoomInvite(String inRoomName) {
    roomInvites[inRoomName] = true;
  }

  void removeRoomInvite(String inRoomName) {
    roomInvites.remove(inRoomName);
  }
}