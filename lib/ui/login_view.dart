import 'dart:io';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'chat_view_model.dart';
import '../utils.dart' as utils;

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ChatViewModel>();
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text('Log in')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _userController,
                    decoration: InputDecoration(labelText: 'Username'),
                    validator: (v) {
                      if (v == null || v.isEmpty || v.length > 10) {
                        return l10n.username_error;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _passController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (v) => (v == null || v.isEmpty)
                        ? l10n.empty_password
                        : null,
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() => _isSubmitting = true);
                        final status = await vm.connectAndValidate(
                            _userController.text, _passController.text);
                        setState(() => _isSubmitting = false);
                        if (status == 'ok' || status == 'created') {
                          final file = File(join(utils.docsDir!.path, 'credentials'));
                          await file.writeAsString(
                              '${_userController.text}============${_passController.text}');
                          // Vai para home
                          utils.navigatorKey.currentState?.pushNamedAndRemoveUntil(
                            '/',
                            ModalRoute.withName('/'),
                          );
                        } else if (status == 'fail') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                              content: Text(l10n.username_used),
                            ),
                          );
                        }
                      },
                      child: _isSubmitting
                          ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : Text('Log in'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
