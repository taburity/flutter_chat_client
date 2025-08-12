import 'package:flutter/material.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'chat_view_model.dart';
import 'app_drawer.dart';

class CreateRoomView extends StatefulWidget {
  const CreateRoomView({super.key});

  @override
  _CreateRoomViewState createState() => _CreateRoomViewState();
}

class _CreateRoomViewState extends State<CreateRoomView> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  bool _private = false;
  double _maxPeople = 25;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ChatViewModel>();
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Create Room')),
      drawer: AppDrawer(),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        child: SingleChildScrollView(
          child: Row(
            children: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Spacer(),
              TextButton(
                child: Text('Save'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    vm.createRoom(_title, _description, _maxPeople.truncate(), _private, context, l10n);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.subject),
              title: TextFormField(
                decoration: InputDecoration(hintText: 'Name'),
                validator: (v) {
                  if (v == null || v.isEmpty || v.length > 14) {
                    return l10n.room_name_error;
                  }
                  return null;
                },
                onSaved: (v) => _title = v!,
              ),
            ),
            ListTile(
              leading: Icon(Icons.description),
              title: TextFormField(
                decoration: InputDecoration(hintText: 'Description'),
                onSaved: (v) => _description = v!,
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Text('Max\nPeople'),
                  Slider(
                    min: 0,
                    max: 99,
                    value: _maxPeople,
                    onChanged: (v) => setState(() => _maxPeople = v),
                  ),
                ],
              ),
              trailing: Text(_maxPeople.toStringAsFixed(0)),
            ),
            ListTile(
              title: Row(
                children: [
                  Text('Private'),
                  Switch(
                    value: _private,
                    onChanged: (v) => setState(() => _private = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
