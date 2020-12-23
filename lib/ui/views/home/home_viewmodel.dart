import 'package:dgg/app/locator.dart';
import 'package:dgg/app/router.gr.dart';
import 'package:dgg/datamodels/session_info.dart';
import 'package:dgg/services/dgg_api.dart';
import 'package:dgg/services/remote_config_service.dart';
import 'package:dgg/services/shared_preferences_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _dggApi = locator<DggApi>();
  final _remoteConfigService = locator<RemoteConfigService>();
  final _snackbarService = locator<SnackbarService>();
  final _sharedPreferencesService = locator<SharedPreferencesService>();

  SessionInfo get sessionInfo => _dggApi.sessionInfo;

  String _appDownloadUrl;
  String get appDownloadUrl => _appDownloadUrl;

  void initialize() {
    _checkOnboarding();
    _checkForAppUpdate();
    _getSessionInfo();
  }

  Future<void> navigateToAuth() async {
    await _navigationService.navigateTo(Routes.authView);
    notifyListeners();
    _getSessionInfo();
  }

  void navigateToChat() {
    _navigationService.navigateTo(Routes.chatView);
  }

  Future<void> navigateToSettings() async {
    await _navigationService.navigateTo(Routes.settingsView);
    notifyListeners();
  }

  Future<void> _getSessionInfo() async {
    await _dggApi.getSessionInfo();
    notifyListeners();
  }

  Future<void> _checkForAppUpdate() async {
    String newestVersion = await _remoteConfigService.getAppNewestVersion();
    if (double.parse(newestVersion) > 0.1) {
      //There is a newer version, prompt user
      _appDownloadUrl = await _remoteConfigService.getAppDownloadUrl();
      notifyListeners();
    }
  }

  Future<void> openAppDownloadUrl() async {
    if (await canLaunch(_appDownloadUrl)) {
      await launch(_appDownloadUrl);
    } else {
      _snackbarService.showSnackbar(
        message: "Something went wrong. URL can't be opened.",
      );
    }
  }

  Future<void> _checkOnboarding() async {
    bool onboardingFinished = await _sharedPreferencesService.getOnboarding();

    if (!onboardingFinished) {
      _navigationService.navigateTo(Routes.onboardingView);
    }
  }
}
