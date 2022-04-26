import 'package:dgg/services/shared_preferences_service.dart';
import 'package:dgg/ui/widgets/setup_bottom_sheet_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xFF232323), //don't know how to change it based on theme
  ));
  await locator<SharedPreferencesService>().initialize();
  setupBottomSheetUi();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      themes: [
        ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
            brightness: Brightness.dark,
            primary: const Color(0xFF538CC6),
            secondary: const Color(0xFF538CC6),
            surface: const Color(0xFF538CC6),
            onSurface: Colors.white,
          ),
        ),
        ThemeData(
          scaffoldBackgroundColor: Colors.black,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            brightness: Brightness.dark,
            primary: const Color(0xFF538CC6),
            secondary: const Color(0xFF538CC6),
            surface: Colors.black,
            onSurface: Colors.white,
          ),
        ),
        ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
            brightness: Brightness.dark,
            primary: const Color(0xFF538CC6),
            secondary: const Color(0xFF538CC6),
            surface: const Color(0xFF232323),
            onSurface: Colors.white,
          ),
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
