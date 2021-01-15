import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:stacked_themes/stacked_themes.dart';

import 'app/locator.dart';
import 'app/router.gr.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocator();
  if (kDebugMode) {
    // Force disable Crashlytics collection while doing every day development.
    // Temporarily toggle this to true if you want to test crash reporting in your app.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }
  await ThemeManager.initialise();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      themes: [
        ThemeData(
          brightness: Brightness.dark,
          primaryColor: Color(0xFF538CC6),
          accentColor: Color(0xFF538CC6),
        ),
        ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          primaryColor: Color(0xFF538CC6),
          accentColor: Color(0xFF538CC6),
        ),
      ],
      builder: (context, regularTheme, darkTheme, themeMode) => MaterialApp(
        title: 'Dgg',
        onGenerateRoute: AutoRouter().onGenerateRoute,
        navigatorKey: locator<NavigationService>().navigatorKey,
        theme: regularTheme,
      ),
    );
  }
}
