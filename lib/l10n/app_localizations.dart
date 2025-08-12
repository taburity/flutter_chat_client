import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en')
  ];

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'FlutterChat'**
  String get title;

  /// No description provided for @username_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username no more than 10 characters long'**
  String get username_error;

  /// No description provided for @username_used.
  ///
  /// In en, this message translates to:
  /// **'Sorry, that username is already taken'**
  String get username_used;

  /// No description provided for @empty_password.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get empty_password;

  /// No description provided for @room_name_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name no more than 14 characters long'**
  String get room_name_error;

  /// No description provided for @duplicated_room.
  ///
  /// In en, this message translates to:
  /// **'Sorry, that room already exists'**
  String get duplicated_room;

  /// No description provided for @full_room.
  ///
  /// In en, this message translates to:
  /// **'Sorry, that room is full'**
  String get full_room;

  /// No description provided for @closed_room.
  ///
  /// In en, this message translates to:
  /// **'The room you were in was closed by its creator'**
  String get closed_room;

  /// No description provided for @no_rooms.
  ///
  /// In en, this message translates to:
  /// **'There are no rooms yet. Why not add one?'**
  String get no_rooms;

  /// No description provided for @kicked.
  ///
  /// In en, this message translates to:
  /// **'What did you do?! You got kicked from the room! D\'oh!'**
  String get kicked;

  /// No description provided for @no_invite.
  ///
  /// In en, this message translates to:
  /// **'Sorry, you can\'t enter a private room without an invite'**
  String get no_invite;

  /// No description provided for @new_invite.
  ///
  /// In en, this message translates to:
  /// **'You\'ve been invited to the room \'{roomName}\' by user \'{inviterName}\'.\n\nYou can enter the room from the lobby.'**
  String new_invite(Object inviterName, Object roomName);

  /// No description provided for @leave_option.
  ///
  /// In en, this message translates to:
  /// **'Leave Room'**
  String get leave_option;

  /// No description provided for @invite_option.
  ///
  /// In en, this message translates to:
  /// **'Invite A User'**
  String get invite_option;

  /// No description provided for @close_option.
  ///
  /// In en, this message translates to:
  /// **'Close Room'**
  String get close_option;

  /// No description provided for @kick_option.
  ///
  /// In en, this message translates to:
  /// **'Kick User'**
  String get kick_option;

  /// No description provided for @users_header.
  ///
  /// In en, this message translates to:
  /// **'  Users In Room'**
  String get users_header;

  /// No description provided for @message_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter message'**
  String get message_hint;

  /// No description provided for @welcome_new.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {username}!'**
  String welcome_new(Object username);

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the server, {username}!'**
  String welcome(Object username);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
