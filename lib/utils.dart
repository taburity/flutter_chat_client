import 'dart:io';
import 'package:flutter/material.dart';

//utils.dart é um módulo, não define classe. seria programação estrutural

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
BuildContext? rootBuildContext; // BuildContext do widget raiz
Directory? docsDir = Directory.systemTemp; //valor default
String? credentials;