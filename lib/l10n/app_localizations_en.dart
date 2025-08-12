// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'FlutterChat';

  @override
  String get username_error => 'Please enter a username no more than 10 characters long';

  @override
  String get username_used => 'Sorry, that username is already taken';

  @override
  String get empty_password => 'Please enter a password';

  @override
  String get room_name_error => 'Please enter a name no more than 14 characters long';

  @override
  String get no_rooms => 'There are no rooms yet. Why not add one?';

  @override
  String get no_invite => 'Sorry, you can\'t enter a private room without an invite';

  @override
  String get leave_option => 'Leave Room';

  @override
  String get invite_option => 'Invite A User';

  @override
  String get close_option => 'Close Room';

  @override
  String get kick_option => 'Kick User';

  @override
  String get users_header => '  Users In Room';

  @override
  String get message_hint => 'Enter message';
}
