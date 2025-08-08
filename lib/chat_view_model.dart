import 'dart:async';
import 'package:flutter/material.dart';
import 'model.dart';
import 'connector.dart';
import 'utils.dart' as utils;

class ChatViewModel extends ChangeNotifier {
  final Model _model;
  final Connector _connector = Connector();

  ChatViewModel(this._model) {
    // Assina eventos do servidor
    _connector.onNewUser.listen((data) => _setUserList(Map.from(data)));
    _connector.onCreated.listen((data) => _setRoomList(Map.from(data)));
    _connector.onClosed.listen((data) => _handleClosed(Map.from(data)));
    _connector.onJoined.listen((data) => _handleJoined(Map.from(data)));
    _connector.onLeft.listen((data) => _handleLeft(Map.from(data)));
    _connector.onKicked.listen((data) => _handleKicked(Map.from(data)));
    _connector.onInvited.listen((data) => _handleInvited(Map.from(data)));
    _connector.onPosted.listen((data) => _handlePosted(Map.from(data)));
  }

  // Getters para a View
  String get greeting => _model.greeting;
  String get userName => _model.userName;
  String get currentRoomName => _model.currentRoomName;
  bool get currentRoomEnabled => _model.currentRoomEnabled;
  List get currentRoomMessages => _model.currentRoomMessages;
  List get roomList => _model.roomList;
  List get userList => _model.userList;
  List get currentRoomUserList => _model.currentRoomUserList;
  bool get creatorFunctionsEnabled => _model.creatorFunctionsEnabled;
  Map get roomInvites => _model.roomInvites;

  // Mutadores + notify
  void _setGreeting(String v) { _model.greeting = v; notifyListeners(); }
  void _setUserName(String v) { _model.userName = v; notifyListeners(); }
  void _setCurrentRoomName(String v) { _model.currentRoomName = v; notifyListeners(); }
  void _setCurrentRoomEnabled(bool v) { _model.currentRoomEnabled = v; notifyListeners(); }
  void _setCreatorFunctionsEnabled(bool v) { _model.creatorFunctionsEnabled = v; notifyListeners(); }
  void _clearMessages() { _model.clearCurrentRoomMessages(); notifyListeners(); }
  void _setRoomList(Map serverMap) { _model.setRoomListFromServerMap(serverMap); notifyListeners(); }
  void _setUserList(Map serverMap) { _model.setUserListFromServerMap(serverMap); notifyListeners(); }
  void _setCurrentRoomUserList(Map serverMap) { _model.setCurrentRoomUserListFromServerMap(serverMap); notifyListeners(); }
  void _addMessage(String user, String msg) { _model.addMessage(user, msg); notifyListeners(); }
  void _addInvite(String room) { _model.addRoomInvite(room); notifyListeners(); }
  void _removeInvite(String room) { _model.removeRoomInvite(room); notifyListeners(); }

  // Autenticação (chamar da LoginView)
  Future<String> connectAndValidate(String username, String password) async {
    final c = Completer<String>();
    _connector.connectToServer(() async {
      final res = await _connector.validate(username, password);
      final status = res['status'];
      if (status == 'ok' || status == 'created') {
        _setUserName(username);
        _setGreeting(status == 'ok' ? 'Welcome back, $username!' : 'Welcome to the server, $username!');
      }
      c.complete(status);
    });
    return c.future;
  }

  // Salas / Usuários
  Future<void> fetchRooms() async { final res = await _connector.listRooms(); _setRoomList(res); }
  Future<void> fetchUsers() async { final res = await _connector.listUsers(); _setUserList(res); }

  Future<void> createRoom(String title, String description, int maxPeople, bool isPrivate, BuildContext context) async {
    final res = await _connector.create(title, description, maxPeople, isPrivate, userName);
    if (res['status'] == 'created') {
      _setRoomList(res['rooms']);
      utils.navigatorKey.currentState?.pop();
    } else {
      final ctx = utils.navigatorKey.currentContext ?? context;
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(backgroundColor: Colors.red, duration: Duration(seconds: 2), content: Text('Sorry, that room already exists')),
      );
    }
  }

  Future<void> joinRoom(String roomName, BuildContext context) async {
    final res = await _connector.join(userName, roomName);
    final status = res['status'];
    if (status == 'joined') {
      final room = res['room'];
      _setCurrentRoomName(room['roomName']);
      _setCurrentRoomUserList(room['users']);
      _setCurrentRoomEnabled(true);
      _clearMessages();
      _setCreatorFunctionsEnabled(room['creator'] == userName);
      utils.navigatorKey.currentState?.pushNamed('/Room');
    } else if (status == 'full') {
      final ctx = utils.navigatorKey.currentContext ?? context;
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(backgroundColor: Colors.red, duration: Duration(seconds: 2), content: Text('Sorry, that room is full')),
      );
    }
  }

  Future<void> leaveRoom(BuildContext context) async {
    await _connector.leave(userName, currentRoomName);
    _removeInvite(currentRoomName);
    _setCurrentRoomUserList({});
    _setCurrentRoomName(Model.DEFAULT_ROOM_NAME);
    _setCurrentRoomEnabled(false);
    utils.navigatorKey.currentState?.pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
  }

  Future<void> closeRoom(BuildContext context) async {
    await _connector.close(currentRoomName);
    utils.navigatorKey.currentState?.pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
  }

  Future<void> inviteUser(String target, VoidCallback onDone) async { await _connector.invite(target, currentRoomName, userName); onDone(); }
  Future<void> kickUser(String target, VoidCallback onDone) async { await _connector.kick(target, currentRoomName); onDone(); }
  Future<void> postMessage(String message) async { final res = await _connector.post(userName, currentRoomName, message); if (res['status'] == 'ok') { _addMessage(userName, message); } }

  // Handlers push
  void _handlePosted(Map data) { if (currentRoomName == data['roomName']) { _addMessage(data['userName'], data['message']); } }

  void _handleInvited(Map data) {
    final roomName = data['roomName'];
    _addInvite(roomName);
    final ctx = utils.navigatorKey.currentContext;
    if (ctx != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          backgroundColor: Colors.amber,
          duration: Duration(seconds: 60),
          content: Text("You've been invited to the room '$roomName' by user '${data['inviterName']}'.\n\nYou can enter the room from the lobby."),
          action: SnackBarAction(label: 'Ok', onPressed: () {}),
        ),
      );
    }
  }

  void _handleJoined(Map data) { if (currentRoomName == data['roomName']) { _setCurrentRoomUserList(data['users']); } }
  void _handleLeft(Map data) { if (currentRoomName == data['room']['roomName']) { _setCurrentRoomUserList(data['room']['users']); } }

  void _handleClosed(Map data) {
    _setRoomList(data);
    if (data['roomName'] == currentRoomName) {
      _removeInvite(data['roomName']);
      _setCurrentRoomUserList({});
      _setCurrentRoomName(Model.DEFAULT_ROOM_NAME);
      _setCurrentRoomEnabled(false);
      _setGreeting('The room you were in was closed by its creator.');
      utils.navigatorKey.currentState?.pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
    }
  }

  void _handleKicked(Map data) {
    _removeInvite(data['roomName']);
    _setCurrentRoomUserList({});
    _setCurrentRoomName(Model.DEFAULT_ROOM_NAME);
    _setCurrentRoomEnabled(false);
    _setGreeting("What did you do?! You got kicked from the room! D'oh!");
    utils.navigatorKey.currentState?.pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
  }
}
