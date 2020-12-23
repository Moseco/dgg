import 'package:injectable/injectable.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_themes/stacked_themes.dart';

@module
abstract class ThirdPartyServicesModule {
  @lazySingleton
  NavigationService get navigationService;
  @lazySingleton
  SnackbarService get snackbarService;
  @lazySingleton
  ThemeService get themeService => ThemeService.getInstance();
}
