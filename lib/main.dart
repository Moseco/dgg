import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

import 'app/locator.dart';
import 'app/router.gr.dart' as AutoRouter;

void main() {
  setupLocator();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DGG',
      initialRoute: AutoRouter.Routes.homeView,
      onGenerateRoute: AutoRouter.Router().onGenerateRoute,
      navigatorKey: locator<NavigationService>().navigatorKey,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF538CC6),
      ),
    );
  }
}
