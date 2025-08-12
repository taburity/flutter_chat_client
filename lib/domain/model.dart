class Model {

  String greeting = "";
  String userName = "";
  static const String DEFAULT_ROOM_NAME = "Not currently in a room";
  String currentRoomName = DEFAULT_ROOM_NAME;
  List currentRoomUserList = [];
  // Indica se a opção Current Room está habilitada no drawer
  bool currentRoomEnabled = false;
  bool creatorFunctionsEnabled = false;

  // Os elementos são um mapa na forma { userName : "", message : "" }
  List _currentRoomMessages = [];
  List _roomList = [];
  List _userList = [];
  Map _roomInvites = {};

  List get currentRoomMessages => _currentRoomMessages;
  List get roomList => _roomList;
  List get userList => _userList;
  Map get roomInvites => _roomInvites;

  void addMessage(String inUserName, String inMessage) {
    currentRoomMessages.add({"userName": inUserName, "message": inMessage});
  }

  void clearCurrentRoomMessages() {
    _currentRoomMessages = [];
  }

  void setRoomListFromServerMap(Map inRoomList) {
    _roomList = inRoomList.values.toList();
  }

  void setUserListFromServerMap(Map inUserList) {
    _userList = inUserList.values.toList();
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