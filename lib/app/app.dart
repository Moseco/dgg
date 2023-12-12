import 'package:dgg/services/cookie_manager_service.dart';
import 'package:dgg/services/dgg_service.dart';
import 'package:dgg/services/firebase_service.dart';
import 'package:dgg/services/image_service.dart';
import 'package:dgg/services/shared_preferences_service.dart';
import 'package:dgg/ui/bottom_sheets/message_action_bottom_sheet.dart';
import 'package:dgg/ui/dialogs/confirmation_dialog.dart';
import 'package:dgg/ui/dialogs/select_embed_dialog.dart';
import 'package:dgg/ui/dialogs/select_platform_dialog.dart';
import 'package:dgg/ui/dialogs/text_input_dialog.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:dgg/ui/views/screens.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_themes/stacked_themes.dart';

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
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: SnackbarService),
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(
      classType: ThemeService,
      resolveUsing: ThemeService.getInstance,
    ),
    LazySingleton(classType: CookieManagerService),
    LazySingleton(classType: DggService),
    LazySingleton(classType: ImageService),
    InitializableSingleton(classType: SharedPreferencesService),
    InitializableSingleton(classType: FirebaseService),
  ],
  dialogs: [
    StackedDialog(classType: TextInputDialog),
    StackedDialog(classType: SelectEmbedDialog),
    StackedDialog(classType: SelectPlatformDialog),
    StackedDialog(classType: ConfirmationDialog),
  ],
  bottomsheets: [
    StackedBottomsheet(classType: MessageActionBottomSheet),
  ],
)
class AppSetup {
  /** Serves no purpose besides having an annotation attached to it */
}
