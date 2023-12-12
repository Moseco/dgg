import 'package:dgg/app/app.dialogs.dart';
import 'package:dgg/app/app.locator.dart';
import 'package:dgg/app/app.router.dart';
import 'package:dgg/datamodels/session_info.dart';
import 'package:dgg/services/dgg_service.dart';
import 'package:dgg/services/firebase_service.dart';
import 'package:dgg/services/shared_preferences_service.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _dggService = locator<DggService>();
  final _sharedPreferencesService = locator<SharedPreferencesService>();
  final _themeService = locator<ThemeService>();
  final _dialogService = locator<DialogService>();
  final _snackbarService = locator<SnackbarService>();
  final _firebaseService = locator<FirebaseService>();

  bool get isSignedIn => _dggService.sessionInfo is Available;
  String? get username => (_dggService.sessionInfo as Available).nick;
  bool get isCrashlyticsCollectionEnabled =>
      _firebaseService.crashlyticsEnabled;
  bool _isAnalyticsEnabled = false;
  bool get isAnalyticsEnabled => _isAnalyticsEnabled;
  bool _isWakelockEnabled = false;
  bool get isWakelockEnabled => _isWakelockEnabled;
  int _themeIndex = 0;
  int get themeIndex => _themeIndex;
  int _appBarTheme = 0;
  int get appBarTheme => _appBarTheme;
  bool _isInAppBrowserEnabled = true;
  bool get isInAppBrowserEnabled => _isInAppBrowserEnabled;

  void initialize() {
    _isAnalyticsEnabled = _sharedPreferencesService.getAnalyticsEnabled();
    _isWakelockEnabled = _sharedPreferencesService.getWakelockEnabled();
    _themeIndex = _sharedPreferencesService.getThemeIndex();
    _appBarTheme = _sharedPreferencesService.getAppBarTheme();
    _isInAppBrowserEnabled = _sharedPreferencesService.getInAppBrowserEnabled();
    notifyListeners();
  }

  void openFeedback() {
    launch(
      r"https://docs.google.com/forms/d/e/1FAIpQLScuIOGffMHf3HHnCVdHVN6u08Pr_VGd6nU9raaWJi5ANSN8QQ/viewform?usp=sf_link",
    );
  }

  void signOut() {
    _dggService.signOut();
    notifyListeners();
  }

  void openProfile() {
    launch(
      r"https://www.destiny.gg/profile",
    );
  }

  Future<void> navigateToAuth() async {
    await _navigationService.navigateTo(Routes.authView);
    notifyListeners();
  }

  Future<void> toggleCrashlyticsCollection(bool value) async {
    _firebaseService.setCrashlyticsEnabled(value);
    notifyListeners();
  }

  void toggleAnalyticsCollection(bool value) {
    _firebaseService.setAnalyticsEnabled(value);
    _sharedPreferencesService.setAnalyticsEnabled(value);
    _isAnalyticsEnabled = value;
    notifyListeners();
  }

  void toggleWakelockEnabled(bool value) {
    _sharedPreferencesService.setWakelockEnabled(value);
    _isWakelockEnabled = value;
    notifyListeners();
  }

  void setTheme(int value) {
    _themeService.selectThemeAtIndex(value);
    _themeIndex = value;
    notifyListeners();
  }

  void setAppBarTheme(int value) {
    _sharedPreferencesService.setAppBarTheme(value);
    _appBarTheme = value;
    notifyListeners();
  }

  void navigateToChatSize() {
    _navigationService.navigateTo(Routes.chatSizeView);
  }

  void navigateToIgnoreList() {
    _navigationService.navigateTo(Routes.ignoreListView);
  }

  void toggleInAppBrowserEnabled(bool value) {
    _sharedPreferencesService.setInAppBrowserEnabled(value);
    _isInAppBrowserEnabled = value;
    notifyListeners();
  }

  void openGitHub() {
    launch(r"https://github.com/Moseco/dgg");
  }

  Future<void> requestDataDeletion() async {
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.confirmation,
      title: 'Request data deletion',
      description:
          'If enabled, this app collects analytics relating to app usage and crash reports. You can request to have all your analytics related data deleted. If you choose to, your unique ID will be copied to your clipboard which you need to submit in the form that will be opened in a browser.',
      mainButtonTitle: 'Open',
      secondaryButtonTitle: 'Cancel',
      barrierDismissible: true,
    );

    if (response != null && response.confirmed) {
      final id = await _firebaseService.getAppInstanceId();
      if (id == null) {
        _snackbarService.showSnackbar(
          message: 'Failed to get ID',
          duration: const Duration(seconds: 2),
        );
      } else {
        Clipboard.setData(ClipboardData(text: id));
        try {
          if (!await launchUrl(
            Uri.parse(
                r'https://docs.google.com/forms/d/e/1FAIpQLSfaqQbshNtDOiwfns2co3tmAj6fSFRNUahqNPXCyRMTezQ1Eg/viewform?usp=sf_link'),
          )) {
            _snackbarService.showSnackbar(
              message: 'Failed to open form',
              duration: const Duration(seconds: 2),
            );
          }
        } catch (_) {
          _snackbarService.showSnackbar(
            message: 'Failed to open form',
            duration: const Duration(seconds: 2),
          );
        }
      }
    }
  }
}
