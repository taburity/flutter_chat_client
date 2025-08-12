class Model {

  String greeting = "";
  String userName = "";
  static final String DEFAULT_ROOM_NAME = "Not currently in a room";
  String currentRoomName = DEFAULT_ROOM_NAME;
  List currentRoomUserList = [];
  // Indica se a opção Current Room está habilitada no drawer
  bool currentRoomEnabled = false;
  bool creatorFunctionsEnabled = false;
  // Os elementos são um mapa na forma { userName : "", message : "" }
  List<Map<String, String>> currentRoomMessages = [];
  List roomList = [];
  List userList = [];
  Map<String, bool> roomInvites = {};

}