import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "flutter_chat_model.dart" show FlutterChatModel;
import "app_drawer.dart";
import "connector.dart";


class CreateRoom extends StatefulWidget {
 CreateRoom({Key? key}) : super(key : key);
 @override
 _CreateRoom createState() => _CreateRoom();
}


class _CreateRoom extends State {

  late String _title;
  late String _description;
  bool _private = false;
  double _maxPeople = 25;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(final BuildContext inContext) {
    print("## CreateRoom.build()");

    return Consumer<FlutterChatModel>(
      builder : (BuildContext inContext, FlutterChatModel inModel, Widget? inChild) {
        Connector connector = Connector(inModel);
        return Scaffold(
          //controla como os widgets flutuantes se redimensionarão quando o teclado virtual for exibido
          //o mais comum é evitar que o corpo e os widgets sejam ofuscados pelo teclado
          //aqui queremos que o teclado se sobreponha para evitar que widgets desapareçam
          resizeToAvoidBottomInset : false,
          appBar : AppBar(title : Text("Create Room")),
          drawer : AppDrawer(),
          bottomNavigationBar : Padding(
            padding : EdgeInsets.symmetric(vertical : 0, horizontal : 10),
            child : SingleChildScrollView(child : Row(
              children : [
                TextButton(
                  child : Text("Cancel"),
                  onPressed : () {
                    FocusScope.of(inContext).requestFocus(FocusNode());
                    Navigator.of(inContext).pop();
                  }
                ),
                Spacer(),
                TextButton(
                  child : Text("Save"),
                  onPressed : () {
                    if (!_formKey.currentState!.validate()) { return; }
                    _formKey.currentState!.save();
                    int maxPeople = _maxPeople.truncate(); //necessário para ter um inteiro
                    print("_title=$_title, _description = $_description, _maxPeople = $maxPeople, "
                      "_private = $_private, creator = $inModel.userName"
                    );
                    connector.create(_title, _description, maxPeople, _private, inModel.userName, (inStatus, inRoomList) {
                      print("## CreateRoom.create: callback: inStatus=$inStatus, inRoomList=$inRoomList");
                      if (inStatus == "created") {
                        inModel.setRoomList(inRoomList); //atualiza o modelo com a lista de salas
                        FocusScope.of(inContext).requestFocus(FocusNode());
                        Navigator.of(inContext).pop();
                      } else {
                        ScaffoldMessenger.of(inContext).showSnackBar(
                          SnackBar(backgroundColor : Colors.red, duration : Duration(seconds : 2),
                            content : Text("Sorry, that room already exists")
                          )
                        );
                      }
                    });
                  }
                )
              ]
            ))
          ),
          body : Form(
            key : _formKey,
            child : ListView(
              children : [
                // Name.
                ListTile(
                  leading : Icon(Icons.subject),
                  title : TextFormField(decoration : InputDecoration(hintText : "Name"),
                    validator : (String? inValue) {
                      if (inValue!.length == 0 || inValue.length > 14) {
                        return "Please enter a name no more than 14 characters long";
                      }
                      return null;
                    },
                    onSaved : (String? inValue) { setState(() { _title = inValue!; }); }
                  )
                ),
                // Description.
                ListTile(
                  leading : Icon(Icons.description),
                  title : TextFormField(decoration : InputDecoration(hintText : "Description"),
                    onSaved : (String? inValue) { setState(() { _description = inValue!; }); }
                  )
                ),
                // Max People.
                ListTile(
                  title : Row(children : [
                    Text("Max\nPeople"),
                    Slider(min : 0, max : 99, value : _maxPeople,
                      onChanged : (double inValue) { setState(() { _maxPeople = inValue; }); }
                    )
                  ]),
                  trailing : Text(_maxPeople.toStringAsFixed(0)) //não queremos casas decimais
                ),
                // Private?
                ListTile(
                  title : Row(children : [
                    Text("Private"),
                    Switch(value : _private,
                      onChanged : (inValue) { setState(() { _private = inValue; }); }
                    )
                  ])
                )
              ]
            )
          )
        );
      }
    );
  }

}