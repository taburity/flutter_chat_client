import "package:flutter/material.dart";


class FlutterChatModel extends ChangeNotifier {

  String greeting = "";
  String userName = "";
  static final String DEFAULT_ROOM_NAME = "Not currently in a room";
  String currentRoomName = DEFAULT_ROOM_NAME;
  List currentRoomUserList = [ ];
  // Indica se a opção Current Room está habilitada no drawer
  bool currentRoomEnabled = false;
  // Os elementos são um mapa na forma { userName : "", message : "" }.
  List currentRoomMessages = [ ];
  List roomList = [ ];
  List userList = [ ];
  bool creatorFunctionsEnabled = false;
  Map roomInvites = { };

  void setGreeting(final String inGreeting) {
    print("## FlutterChatModel.setGreeting(): inGreeting = $inGreeting");
    greeting = inGreeting;
    notifyListeners();
  }

  void setUserName(final String inUserName) {
    print("## FlutterChatModel.setUserName(): inUserName = $inUserName");
    userName = inUserName;
    notifyListeners();
  }

  void setCurrentRoomName(final String inRoomName) {
    print("## FlutterChatModel.setCurrentRoomName(): inRoomName = $inRoomName");
    currentRoomName = inRoomName;
    notifyListeners();
  }

  void setCreatorFunctionsEnabled(final bool inEnabled) {
    print("## FlutterChatModel.setCreatorFunctionsEnabled(): inEnabled = $inEnabled");
    creatorFunctionsEnabled = inEnabled;
    notifyListeners();
  }

  void setCurrentRoomEnabled(final bool inEnabled) {
    print("## FlutterChatModel.setCurrentRoomEnabled(): inEnabled = $inEnabled");
    currentRoomEnabled = inEnabled;
    notifyListeners();
  }

  void addMessage(final String inUserName, final String inMessage) {
    print("## FlutterChatModel.addMessage(): inUserName = $inUserName, inMessage = $inMessage");
    currentRoomMessages.add({ "userName" : inUserName, "message" : inMessage });
    notifyListeners();
  }

  //O mapa de entrada descreve cada sala com um par chave-valor. Queremos uma lista só com o valor.
  void setRoomList(final Map inRoomList) {
    print("## FlutterChatModel.setRoomList(): inRoomList = $inRoomList");
    List rooms = [ ];
    for (String roomName in inRoomList.keys) {
      Map room = inRoomList[roomName];
      rooms.add(room);
    }
    roomList = rooms;
    notifyListeners();
  }

  //O mapa de entrada descreve cada usuário com um par chave-valor. Queremos uma lista só com o valor.
  void setUserList(final Map inUserList) {
    print("## FlutterChatModel.setUserList(): inUserList = $inUserList");

    List users = [ ];
    for (String userName in inUserList.keys) {
      Map user = inUserList[userName];
      users.add(user);
    }
    userList = users;
    notifyListeners();
  }

  //O mapa de entrada descreve cada usuário com um par chave-valor. Queremos uma lista só com o valor.
  void setCurrentRoomUserList(final Map inUserList) {
    print("## FlutterChatModel.setCurrentRoomUserList(): inUserList = $inUserList");

    List users = [ ];
    for (String userName in inUserList.keys) {
      Map user = inUserList[userName];
      users.add(user);
    }
    currentRoomUserList = users;
    notifyListeners();
  }

  // Um convite resulta em um Snackbar exibido por alguns segundos. Depois que ele desaparece, é necessário
  // saber se o usuário pode entrar numa sala, então aqui o mapa tem como chave o nome da sala e o valor é um boolean.
  // Se o boolean é true, tem convite, então o usuário pode entrar.
  // Não precisa de notificação porque não há uma reconstrução de widgets
  void addRoomInvite(final String inRoomName) {
    print("## FlutterChatModel.addRoomInvite(): inRoomName = $inRoomName");
    roomInvites[inRoomName] = true;
  }

  // Não precisa de notificação porque não há reconstrução de widgets
  void removeRoomInvite(final String inRoomName) {
    print("## FlutterChatModel.removeRoomInvite(): inRoomName = $inRoomName");
    roomInvites.remove(inRoomName);
  }

  // Não precisa de notificação porque não há reconstrução de widgets
  void clearCurrentRoomMessages() {
    print("## FlutterChatModel.clearCurrentRoomMessages()");
    currentRoomMessages = [ ];
  }
}