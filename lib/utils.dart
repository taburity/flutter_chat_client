import 'dart:io';
import 'package:flutter/material.dart';

//utils.dart é um módulo, não define classe. seria programação estrutural

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Directory? docsDir = Directory.systemTemp;
String? credentials;