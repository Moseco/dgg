import 'package:dgg/app/locator.dart';
import 'package:dgg/services/shared_preferences_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class OnboardingViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _sharedPreferencesService = locator<SharedPreferencesService>();

  bool get isCrashlyticsCollectionEnabled =>
      FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled;
  bool _isAnalyticsEnabled = true;
  bool get isAnalyticsEnabled => _isAnalyticsEnabled;

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

  Future<void> finishOnboarding() async {
    _sharedPreferencesService.setOnboarding();
    _navigationService.back();
  }
}
