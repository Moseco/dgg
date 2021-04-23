import 'package:dgg/app/app.locator.dart';
import 'package:dgg/app/app.router.dart';
import 'package:dgg/datamodels/session_info.dart';
import 'package:dgg/services/dgg_service.dart';
import 'package:dgg/services/shared_preferences_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _dggService = locator<DggService>();
  final _sharedPreferencesService = locator<SharedPreferencesService>();
  final _themeService = locator<ThemeService>();

  bool get isSignedIn => _dggService.sessionInfo is Available;
  String? get username => (_dggService.sessionInfo as Available).nick;
  bool get isCrashlyticsCollectionEnabled =>
      FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled;
  bool _isAnalyticsEnabled = false;
  bool get isAnalyticsEnabled => _isAnalyticsEnabled;
  bool _isWakelockEnabled = false;
  bool get isWakelockEnabled => _isWakelockEnabled;
  int _themeIndex = 0;
  int get themeIndex => _themeIndex;
  int _appBarTheme = 0;
  int get appBarTheme => _appBarTheme;

  Future<void> initialize() async {
    await _sharedPreferencesService.initialize();
    _isAnalyticsEnabled = _sharedPreferencesService.getAnalyticsEnabled();
    _isWakelockEnabled = _sharedPreferencesService.getWakelockEnabled();
    _themeIndex = _sharedPreferencesService.getThemeIndex();
    _appBarTheme = _sharedPreferencesService.getAppBarTheme();
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
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(value);
    notifyListeners();
  }

  Future<void> toggleAnalyticsCollection(bool value) async {
    FirebaseAnalytics().setAnalyticsCollectionEnabled(value);
    _sharedPreferencesService.setAnalyticsEnabled(value);
    _isAnalyticsEnabled = value;
    notifyListeners();
  }

  Future<void> toggleWakelockEnabled(bool value) async {
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
}
