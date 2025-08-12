import 'dart:async';
import 'package:socket_io_client_flutter/socket_io_client_flutter.dart' as IO;

class Connector {

  // Endereço IP do servidor cujo valor equivale a localhost para emulador android
  String serverURL = 'http://10.0.2.2:80';

  //Instância única da classe SocketIO
  late IO.Socket _io;
  //Instância única
  static final Connector instance = Connector._internal();
  //Construtor privado
  Connector._internal();

  // Streams para eventos do servidor
  // Quando vier dados do servidor, quem estiver ouvindo o Stream vai ser notificado
  // dynamic porque o stream pode carregar qualquer tipo de dado
  // broadcast para possibilitar múltiplos ouvintes (várias telas reagindo ao evento)
  final _newUserCtrl = StreamController<dynamic>.broadcast();
  final _createdCtrl = StreamController<dynamic>.broadcast();
  final _closedCtrl = StreamController<dynamic>.broadcast();
  final _joinedCtrl = StreamController<dynamic>.broadcast();
  final _leftCtrl = StreamController<dynamic>.broadcast();
  final _kickedCtrl = StreamController<dynamic>.broadcast();
  final _invitedCtrl = StreamController<dynamic>.broadcast();
  final _postedCtrl = StreamController<dynamic>.broadcast();

  // Getters dos streams
  Stream<dynamic> get onNewUser => _newUserCtrl.stream;
  Stream<dynamic> get onCreated => _createdCtrl.stream;
  Stream<dynamic> get onClosed => _closedCtrl.stream;
  Stream<dynamic> get onJoined => _joinedCtrl.stream;
  Stream<dynamic> get onLeft => _leftCtrl.stream;
  Stream<dynamic> get onKicked => _kickedCtrl.stream;
  Stream<dynamic> get onInvited => _invitedCtrl.stream;
  Stream<dynamic> get onPosted => _postedCtrl.stream;

  //É chamada uma vez da caixa de diálogo de login
  void connectToServer(void Function() inCallback) {
    print("## Connector.connectToServer(): serverURL = $serverURL");
    _io = IO.io(
      serverURL,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _io.on('connect', (_) {
      print("## Connector.connectToServer(): Conectado ao servidor");
      //registra listeners para eventos do servidor
      _registerListeners();
      //notifica que a conexão foi estabelecida
      inCallback();
    });

    // Garante que o socket seja desconectado antes de tentar reconectar
    _io.disconnect();
    _io.connect();

    // Configura callback para erros de conexão
    _io.onError((data) {
      print("## Connector.connectToServer(): Erro de conexão: $data");
    });
    print("## Connector.connectToServer(): Tentativa de conexão iniciada.");
  }

  void _registerListeners() {
    //quando o servidor enviar uma mensagem, o dado recebido vai ser adicionado ao stream adequado
    _io.on('newUser', (data) => _newUserCtrl.add(data));
    _io.on('created', (data) => _createdCtrl.add(data));
    _io.on('closed', (data) => _closedCtrl.add(data));
    _io.on('joined', (data) => _joinedCtrl.add(data));
    _io.on('left', (data) => _leftCtrl.add(data));
    _io.on('kicked', (data) => _kickedCtrl.add(data));
    _io.on('invited', (data) => _invitedCtrl.add(data));
    _io.on('posted', (data) => _postedCtrl.add(data));
  }

  // Valida o usuário quando não há credenciais armazenadas
  Future<Map> validate(String inUserName, String inPassword) async {
    print("## Connector.validate(): inUserName = $inUserName, inPassword = $inPassword");

    // Cria um Completer para controlar manualmente um Future que retornará um Map
    // Nesse momento, o Future está "pendente" (ainda não resolvido)
    final c = Completer<Map>();

    // Envia o evento 'validate' para o servidor via Socket.IO,
    // passando os dados do usuário e senha
    // O ack será chamado quando o servidor enviar a resposta
    _io.emitWithAck('validate', {
      'userName': inUserName,
      'password': inPassword,
    }, ack: (response) {
      print("## Connector.validate(): callback: response = $response");

      // Conclui o Future com a resposta convertida para Map
      c.complete(Map.from(response));
    });

    // Retorna o Future associado ao Completer
    // Esse Future será resolvido quando c.complete() for chamado no callback
    return c.future;
  }

  // Recupera a lista de salas no servidor atualmente
  Future<Map> listRooms() async {
    print("## Connector.listRooms()");
    final c = Completer<Map>();
    _io.emitWithAck('listRooms', '{}',
    ack: (response) {
      print("## Connector.listRooms(): callback: response = $response");
      c.complete(Map.from(response));
    });
    return c.future;
  }

  // Cria uma sala a partir da tela de lobby
  Future<Map> create(String inRoomName, String inDescription, int inMaxPeople,
      bool inPrivate, String inCreator,) async {
    print("## Connector.create(): inRoomName = $inRoomName, inDescription = $inDescription, "
            "inMaxPeople = $inMaxPeople, inPrivate = $inPrivate, inCreator = $inCreator");
    final c = Completer<Map>();
    _io.emitWithAck('create', {
      'roomName': inRoomName,
      'description': inDescription,
      'maxPeople': inMaxPeople,
      'private': inPrivate,
      'creator': inCreator,
    }, ack: (response) {
      print("## Connector.create(): callback: response = $response");
      c.complete(Map.from(response));
    } );
    return c.future;
  }

  // Chamada quando o usuário clica em uma sala da lista de salas na tela de lobby para ingressar nela
  Future<Map> join(String inUserName, String inRoomName) async {
    print("## Connector.join(): inUserName = $inUserName, inRoomName = $inRoomName");
    final c = Completer<Map>();
    _io.emitWithAck('join', {
      'userName': inUserName,
      'roomName': inRoomName,
    }, ack: (response) {
      print("## Connector.join(): callback: response = $response");
      c.complete(Map.from(response));
    });
    return c.future;
  }

  // Chamada quando o usuário sai da sala em que está atualmente
  Future<void> leave(String inUserName, String inRoomName) async {
    print("## Connector.leave(): inUserName = $inUserName, inRoomName = $inRoomName");
    final c = Completer<void>();
    _io.emitWithAck('leave', {
      'userName': inUserName,
      'roomName': inRoomName,
    }, ack: (response) {
      print("## Connector.leave(): callback: response = $response");
      c.complete();
    });
    return c.future;
  }

  // Obtém a lista atualizada de usuários no servidor
  Future<Map> listUsers() async {
    print("## Connector.listUsers()");
    final c = Completer<Map>();
    _io.emitWithAck('listUsers', '{}',
    ack: (response) {
      print("## Connector.listUsers(): callback: response = $response");
      c.complete(Map.from(response));
    });
    return c.future;
  }

  // Chamada quando o usuário convida outro usuário para a sala
  Future<void> invite(String inUserName, String inRoomName, String inInviterName) async {
    print("## Connector.invite(): inUserName = $inUserName, inRoomName = $inRoomName, inInviterName = $inInviterName");
    final c = Completer<void>();
    _io.emitWithAck('invite', {
      'userName': inUserName,
      'roomName': inRoomName,
      'inviterName': inInviterName,
    }, ack: (response) {
      print("## Connector.invite(): callback: response = $response");
      c.complete();
    });
    return c.future;
  }

  // Chamada para postar uma mensagem na sala atual
  Future<Map> post(String inUserName, String inRoomName, String inMessage) async {
    print("## Connector.post(): inUserName = $inUserName, inRoomName = $inRoomName, inMessage = $inMessage");
    final c = Completer<Map>();
    _io.emitWithAck('post', {
      'userName': inUserName,
      'roomName': inRoomName,
      'message': inMessage,
    }, ack: (response) {
      print("## Connector.post(): callback: response = $response");
      c.complete(Map.from(response));
    });
    return c.future;
  }

  // Chamada pelo criador da sala para fechá-la
  Future<void> close(String inRoomName) async {
    print("## Connector.close(): inRoomName = $inRoomName");
    final c = Completer<void>();
    _io.emitWithAck('close', {
      'roomName': inRoomName,
    }, ack: (response) {
      print("## Connector.close(): callback: response = $response");
      c.complete();
    });
    return c.future;
  }

  // Chamada pelo criador da sala para expulsar um usuário dela
  Future<void> kick(String inUserName, String inRoomName) async {
    print("## Connector.kick(): inUserName = $inUserName, inRoomName = $inRoomName");
    final c = Completer<void>();
    _io.emitWithAck('kick', {
      'userName': inUserName,
      'roomName': inRoomName,
    }, ack: (response) {
      print("## Connector.kick(): callback: response = $response");
      c.complete();
    });
    return c.future;
  }

  // Limpeza
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