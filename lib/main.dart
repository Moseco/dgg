import 'package:dgg/services/remote_config_service.dart';
import 'package:dgg/services/shared_preferences_service.dart';
import 'package:dgg/ui/widgets/setup_bottom_sheet_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:stacked_themes/stacked_themes.dart';

import 'app/app.locator.dart';
import 'app/app.router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (kDebugMode) {
    // Force disable Crashlytics collection while doing every day development.
    // Temporarily toggle this to true if you want to test crash reporting in your app.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }
  setupLocator();
  await ThemeManager.initialise();
  await locator<SharedPreferencesService>().initialize();
  await locator<RemoteConfigService>().initialize();
  setupBottomSheetUi();
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
        navigatorKey: StackedService.navigatorKey,
        onGenerateRoute: StackedRouter().onGenerateRoute,
        theme: regularTheme,
      ),
    );
  }
}
