import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../domain/model.dart';
import '../data/connector.dart';
import '../utils.dart' as utils;

class ChatViewModel extends ChangeNotifier {
  final Model _model;
  final Connector _connector = Connector.instance;
  late AppLocalizations _l10n;

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

  void setLocalizations(AppLocalizations l10n) {
    _l10n = l10n;
  }

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

  void _setGreeting(String inGreeting) {
    print("## ChatViewModel.setGreeting(): inGreeting = $inGreeting");
    _model.greeting = inGreeting;
    notifyListeners();
  }

  void _setUserName(String inUserName) {
    print("## ChatViewModel.setUserName(): inUserName = $inUserName");
    _model.userName = inUserName;
    notifyListeners();
  }

  void _setCurrentRoomName(String inRoomName) {
    print("## ChatViewModel.setCurrentRoomName(): inRoomName = $inRoomName");
    _model.currentRoomName = inRoomName;
    notifyListeners();
  }

  void _setCurrentRoomEnabled(bool inEnabled) {
    print("## ChatViewModel.setCurrentRoomEnabled(): inEnabled = $inEnabled");
    _model.currentRoomEnabled = inEnabled;
    notifyListeners();
  }

  void _setCreatorFunctionsEnabled(bool inEnabled) {
    print("## ChatViewModel.setCreatorFunctionsEnabled(): inEnabled = $inEnabled");
    _model.creatorFunctionsEnabled = inEnabled;
    notifyListeners();
  }

  void _clearMessages() {
    print("## ChatViewModel.clearCurrentRoomMessages()");
    _model.currentRoomMessages = [];
    notifyListeners();
  }

  void _setRoomList(Map inRoomList) {
    print("## ChatViewModel.setRoomList(): inRoomList = $inRoomList");
    _model.roomList = inRoomList.values.toList();
    notifyListeners();
  }

  void _setUserList(Map inUserList) {
    print("## ChatViewModel.setUserList(): inUserList = $inUserList");
    _model.userList = inUserList.values.toList();
    notifyListeners();
  }

  void _setCurrentRoomUserList(Map inUserList) {
    print("## ChatViewModel.setCurrentRoomUserList(): inUserList = $inUserList");
    _model.currentRoomUserList = inUserList.values.toList();
    notifyListeners();
  }

  void _addMessage(String inUserName, String inMessage) {
    print("## ChatViewModel.addMessage(): inUserName = $inUserName, inMessage = $inMessage");
    _model.currentRoomMessages.add({"userName": inUserName, "message": inMessage});
    notifyListeners();
  }

  void _addIRoomnvite(String inRoomName) {
    print("## ChatViewModel.addRoomInvite(): inRoomName = $inRoomName");
    _model.roomInvites[inRoomName] = true;
    notifyListeners();
  }

  void _removeRoomInvite(String inRoomName) {
    print("## ChatViewModel.removeRoomInvite(): inRoomName = $inRoomName");
    _model.roomInvites.remove(inRoomName);
    notifyListeners();
  }

  // Autenticação (chamar da LoginView)
  Future<String> connectAndValidate(String username, String password, AppLocalizations l10n) async {
    final c = Completer<String>();
    _connector.connectToServer(() async {
      final res = await _connector.validate(username, password);
      final status = res['status'];
      if (status == 'ok' || status == 'created') {
        _setUserName(username);
        _setGreeting(status == 'ok' ? l10n.welcome_new(username) : l10n.welcome(username));
      }
      c.complete(status);
    });
    return c.future;
  }

  Future<void> fetchRooms() async {
    final res = await _connector.listRooms();
    _setRoomList(res);
  }

  Future<void> fetchUsers() async {
    final res = await _connector.listUsers();
    _setUserList(res);
  }

  Future<void> createRoom(String title, String description, int maxPeople, bool isPrivate, BuildContext context,
      AppLocalizations l10n) async {
    final res = await _connector.create(title, description, maxPeople, isPrivate, userName);
    if (res['status'] == 'created') {
      _setRoomList(res['rooms']);
      utils.navigatorKey.currentState?.pop();
    } else {
      final ctx = utils.navigatorKey.currentContext ?? context;
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(backgroundColor: Colors.red, duration: Duration(seconds: 2), content: Text(l10n.duplicated_room)),
      );
    }
  }

  Future<void> joinRoom(String roomName, BuildContext context, AppLocalizations l10n) async {
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
        SnackBar(backgroundColor: Colors.red, duration: Duration(seconds: 2), content: Text(l10n.full_room)),
      );
    }
  }

  Future<void> leaveRoom(BuildContext context) async {
    await _connector.leave(userName, currentRoomName);
    _removeRoomInvite(currentRoomName);
    _setCurrentRoomUserList({});
    _setCurrentRoomName(Model.DEFAULT_ROOM_NAME);
    _setCurrentRoomEnabled(false);
    utils.navigatorKey.currentState?.pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
  }

  Future<void> closeRoom(BuildContext context) async {
    await _connector.close(currentRoomName);
    utils.navigatorKey.currentState?.pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
  }

  Future<void> inviteUser(String target, VoidCallback onDone) async {
    await _connector.invite(target, currentRoomName, userName);
    onDone();
  }

  Future<void> kickUser(String target, VoidCallback onDone) async {
    await _connector.kick(target, currentRoomName);
    onDone();
  }

  Future<void> postMessage(String message) async {
    final res = await _connector.post(userName, currentRoomName, message);
    if (res['status'] == 'ok') {
      _addMessage(userName, message);
    }
  }

  // Handlers push
  void _handlePosted(Map data) {
    if (currentRoomName == data['roomName']) {
      _addMessage(data['userName'], data['message']);
    }
  }

  void _handleInvited(Map data) {
    final roomName = data['roomName'];
    _addIRoomnvite(roomName);
    final ctx = utils.navigatorKey.currentContext;
    if (ctx != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          backgroundColor: Colors.amber,
          duration: Duration(seconds: 60),
          content: Text(_l10n.new_invite(roomName, data['inviterName'])),
          action: SnackBarAction(label: 'Ok', onPressed: () {}),
        ),
      );
    }
  }

  void _handleJoined(Map data) {
    if (currentRoomName == data['roomName']) {
      _setCurrentRoomUserList(data['users']);
    }
  }

  void _handleLeft(Map data) {
    if (currentRoomName == data['room']['roomName']) {
      _setCurrentRoomUserList(data['room']['users']);
    }
  }

  void _handleClosed(Map data) {
    _setRoomList(data);
    if (data['roomName'] == currentRoomName) {
      _removeRoomInvite(data['roomName']);
      _setCurrentRoomUserList({});
      _setCurrentRoomName(Model.DEFAULT_ROOM_NAME);
      _setCurrentRoomEnabled(false);
      _setGreeting(_l10n.closed_room);
      utils.navigatorKey.currentState?.pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
    }
  }

  void _handleKicked(Map data) {
    _removeRoomInvite(data['roomName']);
    _setCurrentRoomUserList({});
    _setCurrentRoomName(Model.DEFAULT_ROOM_NAME);
    _setCurrentRoomEnabled(false);
    _setGreeting(_l10n.kicked);
    utils.navigatorKey.currentState?.pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
  }
}
