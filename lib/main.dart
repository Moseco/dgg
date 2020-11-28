import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

import 'app/locator.dart';
import 'app/router.gr.dart';

void main() {
  setupLocator();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DGG',
      onGenerateRoute: AutoRouter().onGenerateRoute,
      navigatorKey: locator<NavigationService>().navigatorKey,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF538CC6),
        accentColor: Color(0xFF538CC6),
      ),
    );
  }
}
