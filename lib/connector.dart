import 'dart:async';
import 'package:socket_io_client_flutter/socket_io_client_flutter.dart' as IO;

class Connector {
  // Endereço do servidor (10.0.2.2 aponta para localhost quando no emulador Android)
  String serverURL = 'http://10.0.2.2:80';

  late IO.Socket _io;
  static Connector? _instance;

  // Streams para eventos push do servidor (broadcast para múltiplos listeners)
  final _newUserCtrl = StreamController<dynamic>.broadcast();
  final _createdCtrl = StreamController<dynamic>.broadcast();
  final _closedCtrl = StreamController<dynamic>.broadcast();
  final _joinedCtrl = StreamController<dynamic>.broadcast();
  final _leftCtrl = StreamController<dynamic>.broadcast();
  final _kickedCtrl = StreamController<dynamic>.broadcast();
  final _invitedCtrl = StreamController<dynamic>.broadcast();
  final _postedCtrl = StreamController<dynamic>.broadcast();

  Connector._internal();

  factory Connector() {
    _instance ??= Connector._internal();
    return _instance!;
  }

  // Exposição dos streams
  Stream<dynamic> get onNewUser => _newUserCtrl.stream;
  Stream<dynamic> get onCreated => _createdCtrl.stream;
  Stream<dynamic> get onClosed => _closedCtrl.stream;
  Stream<dynamic> get onJoined => _joinedCtrl.stream;
  Stream<dynamic> get onLeft => _leftCtrl.stream;
  Stream<dynamic> get onKicked => _kickedCtrl.stream;
  Stream<dynamic> get onInvited => _invitedCtrl.stream;
  Stream<dynamic> get onPosted => _postedCtrl.stream;

  // ---- Conexão ----
  void connectToServer(void Function() onConnected) {
    _io = IO.io(
      serverURL,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _io.on('connect', (_) {
      _registerListeners();
      onConnected();
    });

    // Garanta um estado limpo antes de conectar
    _io.disconnect();
    _io.connect();

    _io.onError((data) {
      // Apenas loga. A ViewModel decide como expor isso (snackbar, etc.)
      // print('Connector error: $data');
    });
  }

  void _registerListeners() {
    _io.on('newUser', (data) => _newUserCtrl.add(data));
    _io.on('created', (data) => _createdCtrl.add(data));
    _io.on('closed', (data) => _closedCtrl.add(data));
    _io.on('joined', (data) => _joinedCtrl.add(data));
    _io.on('left', (data) => _leftCtrl.add(data));
    _io.on('kicked', (data) => _kickedCtrl.add(data));
    _io.on('invited', (data) => _invitedCtrl.add(data));
    _io.on('posted', (data) => _postedCtrl.add(data));
  }

  // ---- Chamadas request/response com ack ----
  Future<Map> validate(String userName, String password) async {
    final c = Completer<Map>();
    _io.emitWithAck('validate', {
      'userName': userName,
      'password': password,
    }, ack: (res) => c.complete(Map.from(res)));
    return c.future;
  }

  Future<Map> listRooms() async {
    final c = Completer<Map>();
    _io.emitWithAck('listRooms', '{}', ack: (res) => c.complete(Map.from(res)));
    return c.future;
  }

  Future<Map> create(
      String roomName,
      String description,
      int maxPeople,
      bool isPrivate,
      String creator,
      ) async {
    final c = Completer<Map>();
    _io.emitWithAck('create', {
      'roomName': roomName,
      'description': description,
      'maxPeople': maxPeople,
      'private': isPrivate,
      'creator': creator,
    }, ack: (res) => c.complete(Map.from(res)));
    return c.future;
  }

  Future<Map> join(String userName, String roomName) async {
    final c = Completer<Map>();
    _io.emitWithAck('join', {
      'userName': userName,
      'roomName': roomName,
    }, ack: (res) => c.complete(Map.from(res)));
    return c.future;
  }

  Future<void> leave(String userName, String roomName) async {
    final c = Completer<void>();
    _io.emitWithAck('leave', {
      'userName': userName,
      'roomName': roomName,
    }, ack: (_) => c.complete());
    return c.future;
  }

  Future<Map> listUsers() async {
    final c = Completer<Map>();
    _io.emitWithAck('listUsers', '{}', ack: (res) => c.complete(Map.from(res)));
    return c.future;
  }

  Future<void> invite(String userName, String roomName, String inviterName) async {
    final c = Completer<void>();
    _io.emitWithAck('invite', {
      'userName': userName,
      'roomName': roomName,
      'inviterName': inviterName,
    }, ack: (_) => c.complete());
    return c.future;
  }

  Future<Map> post(String userName, String roomName, String message) async {
    final c = Completer<Map>();
    _io.emitWithAck('post', {
      'userName': userName,
      'roomName': roomName,
      'message': message,
    }, ack: (res) => c.complete(Map.from(res)));
    return c.future;
  }

  Future<void> close(String roomName) async {
    final c = Completer<void>();
    _io.emitWithAck('close', {
      'roomName': roomName,
    }, ack: (_) => c.complete());
    return c.future;
  }

  Future<void> kick(String userName, String roomName) async {
    final c = Completer<void>();
    _io.emitWithAck('kick', {
      'userName': userName,
      'roomName': roomName,
    }, ack: (_) => c.complete());
    return c.future;
  }

  // ---- Limpeza ----
  void dispose() {
    _newUserCtrl.close();
    _createdCtrl.close();
    _closedCtrl.close();
    _joinedCtrl.close();
    _leftCtrl.close();
    _kickedCtrl.close();
    _invitedCtrl.close();
    _postedCtrl.close();
    _io.dispose();
  }
}