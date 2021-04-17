// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_themes/stacked_themes.dart';

import '../services/cookie_manager_service.dart';
import '../services/dgg_service.dart';
import '../services/image_service.dart';
import '../services/remote_config_service.dart';
import '../services/shared_preferences_service.dart';
import '../services/user_message_elements_service.dart';

final locator = StackedLocator.instance;

void setupLocator() {
  locator.registerLazySingleton(() => CookieManagerService());
  locator.registerLazySingleton(() => DggService());
  locator.registerLazySingleton(() => ImageService());
  locator.registerLazySingleton(() => RemoteConfigService());
  locator.registerLazySingleton(() => SharedPreferencesService());
  locator.registerLazySingleton(() => UserMessageElementsService());
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => SnackbarService());
  locator.registerLazySingleton(() => ThemeService());
  locator.registerLazySingleton(() => BottomSheetService());
}
