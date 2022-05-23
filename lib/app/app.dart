import 'package:dgg/services/cookie_manager_service.dart';
import 'package:dgg/services/dgg_service.dart';
import 'package:dgg/services/image_service.dart';
import 'package:dgg/services/shared_preferences_service.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:dgg/ui/views/screens.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_themes/stacked_themes.dart';

// Run the following to generate files
//    flutter pub run build_runner build --delete-conflicting-outputs
@StackedApp(
  routes: [
    MaterialRoute(page: ChatView, initial: true),
    MaterialRoute(page: AuthView),
    MaterialRoute(page: SettingsView),
    MaterialRoute(page: OnboardingView),
    MaterialRoute(page: ChatSizeView),
    MaterialRoute(page: IgnoreListView),
  ],
  dependencies: [
    LazySingleton(classType: CookieManagerService),
    LazySingleton(classType: DggService),
    LazySingleton(classType: ImageService),
    LazySingleton(classType: SharedPreferencesService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: SnackbarService),
    LazySingleton(
      classType: ThemeService,
      resolveUsing: ThemeService.getInstance,
    ),
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
  ],
)
class AppSetup {
  /** Serves no purpose besides having an annotation attached to it */
}
