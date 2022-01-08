import 'package:dgg/app/app.locator.dart';
import 'package:dgg/app/app.router.dart';
import 'package:dgg/datamodels/session_info.dart';
import 'package:dgg/services/dgg_service.dart';
import 'package:dgg/services/shared_preferences_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class OnboardingViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _sharedPreferencesService = locator<SharedPreferencesService>();
  final _dggService = locator<DggService>();

  bool get isCrashlyticsCollectionEnabled =>
      FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled;
  bool _isAnalyticsEnabled = true;
  bool get isAnalyticsEnabled => _isAnalyticsEnabled;
  bool get isSignedIn => _dggService.isSignedIn;
  String? _nickname;
  String? get nickname => _nickname;

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

  void finishOnboarding() {
    _sharedPreferencesService.setOnboarding();
    // Call this here so that changelog is not shown to new users
    _sharedPreferencesService.shouldShowChangelog();
    _navigationService.clearStackAndShow(Routes.chatView);
  }

  Future<void> navigateToAuth() async {
    await _navigationService.navigateTo(Routes.authView);
    if (_dggService.isSignedIn) {
      _nickname = (_dggService.sessionInfo as Available).nick;
    }
    notifyListeners();
  }
}
