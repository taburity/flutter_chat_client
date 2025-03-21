import "dart:convert";
import "flutter_chat_model.dart" show FlutterChatModel;
import "package:flutter/material.dart";
import 'package:socket_io_client_flutter/socket_io_client_flutter.dart' as IO;
import "utils.dart" as utils;


class Connector {

  // Endereço IP do servidor cujo valor equivale a localhost para emulador android
  String serverURL = "http://10.0.2.2:80";

  //Instância única da classe SocketIO
  late IO.Socket _io;

  //Referência para o modelo
  FlutterChatModel model;

  //Instância única
  static Connector? _instance;

  //Construtor privado
  Connector._internal(this.model);

  //Fábrica para inicializar apenas uma vez
  factory Connector(FlutterChatModel model) {
    return _instance ??= Connector._internal(model);
  }

  // ------------------------------ MÉTODOS NÃO RELACIONADOS AO ENVIO DE MENSAGENS ------------------------------

  //Exibe caixa de diálogo para o usuário esperar (em operações rápidas, pode aparecer só o clarão)
  void showPleaseWait() {
    print("## Connector.showPleaseWait()");
    showDialog(context: utils.navigatorKey.currentContext!, barrierDismissible: false,
        builder: (BuildContext inDialogContext) {
          return Dialog(
              child: Container(width: 150,
                  height: 150,
                  alignment: AlignmentDirectional.center,
                  decoration: BoxDecoration(color: Colors.blue[200]),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(child: SizedBox(height: 50, width: 50,
                            child: CircularProgressIndicator(value: null,
                                strokeWidth: 10) //a operação é infinita e o giro é rápido
                        )),
                        Container(margin: EdgeInsets.only(top: 20),
                            child: Center(
                                child: Text("Please wait, contacting server...",
                                    style: new TextStyle(color: Colors.white)
                                ))
                        )
                      ]
                  )
              )
          );
        }
    );
  }

  //Omite a caixa de diálogo de espera
  void hidePleaseWait() {
    print("## Connector.hidePleaseWait()");
    Navigator.of(utils.navigatorKey.currentContext!).pop();
  }

  //É chamada uma vez da caixa de diálogo de login
  void connectToServer(final Function inCallback, FlutterChatModel model) {
    print("## Connector.connectToServer(): serverURL = $serverURL");
    _io = IO.io(serverURL, IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build());
    //Configura callback para o evento connect
    _io.on('connect', (_) {
      print("## Connector.connectToServer(): Conectado ao servidor");
      //registra listeners para eventos do servidor
      _io.on('newUser', (data) => newUser(data));
      _io.on('created', (data) => created(data));
      _io.on('closed', (data) => closed(data));
      _io.on('joined', (data) => joined(data));
      _io.on('left', (data) => left(data));
      _io.on('kicked', (data) => kicked(data));
      _io.on('invited', (data) => invited(data));
      _io.on('posted', (data) => posted(data));
      //notifica que a conexão foi estabelecida
      inCallback();
    });
    // Garante que o socket seja desconectado antes de tentar reconectar
    _io.disconnect(); // Se já estiver conectado, desconectar.
    _io.connect(); // Reconectar.
    // Configura callback para erros de conexão
    _io.onError((data) {
      print("## Connector.connectToServer(): Erro de conexão: $data");
    });
    print("## Connector.connectToServer(): Tentativa de conexão iniciada.");
  }

  // ------------------------------ FUNÇÕES DE MENSAGENS DESTINADAS AO SERVIDOR  ------------------------------
  /*
  Todas elas seguem o mesmo algoritmo: Exibir tela de espera, enviar uma mensagem,
  decodificar a resposta em um mapa no callback, ocultar a tela de espera e enviar
  para o callback certas propriedades do mapa ou o mapa inteiro.
   */

  // Valida o usuário, sendo invocada de LoginDialog quando não há credenciais armazenadas
  void validate(final String inUserName, final String inPassword,
      final Function inCallback, FlutterChatModel model) {
    print("## Connector.validate(): inUserName = $inUserName, inPassword = $inPassword");
    showPleaseWait();
    //envia mensagem validade para o servidor com objeto JSON com usuário e senha
    _io.emitWithAck('validate', {
      "userName": inUserName,
      "password": inPassword
    }, ack: (response) {
      print("## Connector.validate(): callback: response = $response");
      hidePleaseWait();
      inCallback(response["status"]);
    });
  }

  // Recupera a lista de salas no servidor atualmente
  void listRooms(final Function inCallback) {
    print("## Connector.listRooms()");
    showPleaseWait();
    _io.emitWithAck("listRooms", "{}",
    ack: (response){
      print("## Connector.listRooms(): callback: response = $response");
      hidePleaseWait();
      inCallback(response);
    });
  }

  // Cria uma sala a partir da tela de lobby
  void create(final String inRoomName, final String inDescription,
      final int inMaxPeople, final bool inPrivate,
      final String inCreator, final Function inCallback) {
    print(
        "## Connector.create(): inRoomName = $inRoomName, inDescription = $inDescription, "
            "inMaxPeople = $inMaxPeople, inPrivate = $inPrivate, inCreator = $inCreator"
    );
    showPleaseWait();
    _io.emitWithAck("create", {
      "roomName": inRoomName,
      "description": inDescription,
      "maxPeople": inMaxPeople,
      "private": inPrivate,
      "creator": inCreator,
    }, ack: (response){
      print("## Connector.create(): callback: response = $response");
      hidePleaseWait();
      inCallback(response["status"], response["rooms"]);
    });
  }

  // Chamada quando o usuário clica em uma sala da lista de salas na tela de lobby para ingressar nela
  void join(final String inUserName, final String inRoomName, final Function inCallback) {
    print(
        "## Connector.join(): inUserName = $inUserName, inRoomName = $inRoomName");
    showPleaseWait();
    _io.emitWithAck("join", {
      "userName": inUserName,
      "roomName": inRoomName,
    }, ack: (response){
      print("## Connector.join(): callback: response = $response");
      hidePleaseWait();
      inCallback(response["status"], response["room"]);
    });
  }

  // Chamada quando o usuário sai da sala em que está atualmente
  void leave(final String inUserName, final String inRoomName,
      final Function inCallback) {
    print(
        "## Connector.leave(): inUserName = $inUserName, inRoomName = $inRoomName");
    showPleaseWait();
    _io.emitWithAck("leave", {
      "userName": inUserName,
      "roomName": inRoomName,
    }, ack: (response){
      print("## Connector.leave(): callback: response = $response");
      hidePleaseWait();
      inCallback();
    });
  }

  // Obtém a lista atualizada de usuários no servidor quando solicitado pelo AppDrawer
  void listUsers(final Function inCallback) {
    print("## Connector.listUsers()");
    showPleaseWait();
    _io.emitWithAck("listUsers", "{}",
        ack: (response){
          print("## Connector.listUsers(): callback: response = $response");
          hidePleaseWait();
          inCallback(response);
    });
  }

  // Chamada quando o usuário convida outro usuário para a sala
  void invite(final String inUserName, final String inRoomName,
      final String inInviterName,
      final Function inCallback) {
    print(
        "## Connector.invite(): inUserName = $inUserName, "
            "inRoomName = $inRoomName, inInviterName = $inInviterName");
    showPleaseWait();

    _io.emitWithAck("invite", {
      "userName": inUserName,
      "roomName": inRoomName,
      "inviterName": inInviterName
    }, ack: (response){
      print("## Connector.invite(): callback: response = $response");
      hidePleaseWait();
      inCallback();
    });
  }

  // Chamada para postar uma mensagem na sala atual
  void post(final String inUserName, final String inRoomName,
      final String inMessage,
      final Function inCallback) {
    print(
        "## Connector.post(): inUserName = $inUserName, inRoomName = $inRoomName, "
            "inMessage = $inMessage");
    showPleaseWait();

    _io.emitWithAck("post", {
      "userName": inUserName,
      "roomName": inRoomName,
      "message": inMessage
    }, ack: (response){
      print("## Connector.post(): callback: response = $response");
      hidePleaseWait();
      inCallback(response["status"]);
    });
  }

  // Chamada pelo criador da sala para fechá-la
  void close(final String inRoomName, final Function inCallback) {
    print("## Connector.close(): inRoomName = $inRoomName");
    showPleaseWait();
    _io.emitWithAck("close", {
      "roomName": inRoomName
    }, ack: (response){
      print("## Connector.close(): callback: response = $response");
      hidePleaseWait();
      inCallback();
    });
  }

  // Chamada pelo criador da sala para expulsar um usuário dela
  void kick(final String inUserName, final String inRoomName,
      final Function inCallback) {
    print("## Connector.kick(): inUserName = $inUserName, inRoomName = $inRoomName");
    showPleaseWait();
    _io.emitWithAck("kick", {
      "userName": inUserName,
      "roomName": inRoomName
    }, ack: (response){
      print("## Connector.kick(): callback: response = $response");
      hidePleaseWait();
      inCallback();
    });
  }

  // ------------------------------ FUNÇÕES DE MENSAGENS DESTINADAS AO CLIENTE ------------------------------

  // Chamada quando um novo usuário é criado.
  // O servidor envia uma lista de usuários completa e essa função apenas a define no modelo
  void newUser(inData) {
    print("## Connector.newUser(): inData = $inData");
    Map<String, dynamic> payload = jsonDecode(inData);
    print("## Connector.newUser(): payload = $payload");
    model.setUserList(payload);
  }

  // Chamada quando uma nova sala é criada.
  // O servidor envia uma lista de salas completa e essa função apenas a define no modelo
  void created(inData) {
    print("## Connector.created(): inData = $inData");
    Map<String, dynamic> payload = jsonDecode(inData);
    print("## Connector.created(): payload = $payload");
    model.setRoomList(payload);
  }

  // Chamada quando uma sala é fechada.
  void closed(inData) {
    print("## Connector.closed(): inData = $inData");
    Map<String, dynamic> payload = jsonDecode(inData);
    print("## Connector.closed(): payload = $payload");
    //a lista de salas atualizada é definida no modelo
    model.setRoomList(payload);

    //Se o usuário está na sala que foi fechada...
    if (payload["roomName"] == model.currentRoomName) {
      //Se houver convite para essa sala, ele deve ser removido
      model.removeRoomInvite(payload["roomName"]);
      //limpa a lista de usuários da sala atual
      model.setCurrentRoomUserList({});
      //ajusta o nome da sala
      model.setCurrentRoomName(FlutterChatModel.DEFAULT_ROOM_NAME);
      //desativa current room para indicar que o usuário não está em sala alguma
      model.setCurrentRoomEnabled(false);
      //atualiza a saudação na tela inicial para o usuário saber que a sala foi fechada
      model.setGreeting("The room you were in was closed by its creator.");
      //navega para a tela inicial
      Navigator.of(utils.rootBuildContext!).pushNamedAndRemoveUntil(
          "/", ModalRoute.withName("/"));
    }
  }

  // Chamada quando um novo usuário entra em uma sala
  void joined(inData) {
    print("## Connector.joined(): inData = $inData");
    Map<String, dynamic> payload = jsonDecode(inData);
    print("## Connector.joined(): payload = $payload");
    //Atualiza a lista de usuários na sala se o usuário estiver na sala que possui novo participante
    if (model.currentRoomName == payload["roomName"]) {
      model.setCurrentRoomUserList(payload["users"]);
    }
  }

  // Chamada quando um usuário sai de uma sala
  void left(inData) {
    print("## Connector.left(): inData = $inData");
    Map<String, dynamic> payload = jsonDecode(inData);
    print("## Connector.left(): payload = $payload");
    //Atualiza a lista de usuários na sala se o usuário estiver na sala de onde o participante saiu
    if (model.currentRoomName == payload["room"]["roomName"]) {
      model.setCurrentRoomUserList(payload["room"]["users"]);
    }
  }

  // Chamada quando o criador da sala expulsar um usuário
  // Mesmo caso do usuário estar em uma sala que foi fechada, tem que limpar os dados no modelo
  void kicked(inData) {
    print("## Connector.kicked(): inData = $inData");
    Map<String, dynamic> payload = jsonDecode(inData);
    print("## Connector.kicked(): payload = $payload");
    //remove convites
    model.removeRoomInvite(payload["roomName"]);
    //limpa a lista de usuários
    model.setCurrentRoomUserList({});
    //ajusta o nome da sala atual
    model.setCurrentRoomName(FlutterChatModel.DEFAULT_ROOM_NAME);
    //desativa current room para indicar que o usuário não está em sala alguma
    model.setCurrentRoomEnabled(false);
    //atualiza a saudação
    model.setGreeting("What did you do?! You got kicked from the room! D'oh!");
    //navega para a tela inicial
    Navigator.of(utils.rootBuildContext!).pushNamedAndRemoveUntil(
        "/", ModalRoute.withName("/"));
  }

  /// Executada quando um usuário é convidado para uma sala
  void invited(inData) async {
    print("## Connector.invited(): inData = $inData");
    Map<String, dynamic> payload = jsonDecode(inData);
    print("## Connector.invited(): payload = $payload");

    //processa a resposta para obter o nome da sala
    String roomName = payload["roomName"];
    //o usuário que convidou
    String inviterName = payload["inviterName"];
    //atualiza o modelo com o novo convite
    model.addRoomInvite(roomName);

    //Exibir um snackbar para alertar o usuário sobre o convite, que some depois de 1 minuto
    ScaffoldMessenger.of(utils.rootBuildContext!).showSnackBar(
        SnackBar(backgroundColor: Colors.amber, duration: Duration(seconds: 60),
            content: Text(
                "You've been invited to the room '$roomName' by user '$inviterName'.\n\n"
                    "You can enter the room from the lobby."
            ),
            action: SnackBarAction(
                label: "Ok",
                onPressed: () {}
            )
        )
    );
  }

  // Executada quando uma mensagem é postada em uma sala
  void posted(inData) {
    print("## Connector.posted(): inData = $inData");
    Map<String, dynamic> payload = jsonDecode(inData);
    print("## Connector.posted(): payload = $payload");
    // Se o usuário estiver na sala para a qual a mensagem foi enviada, atualiza o modelo
    if (model.currentRoomName == payload["roomName"]) {
      model.addMessage(payload["userName"], payload["message"]);
    }
  }

}