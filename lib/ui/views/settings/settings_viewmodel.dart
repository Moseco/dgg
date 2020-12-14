import 'package:dgg/app/locator.dart';
import 'package:dgg/datamodels/session_info.dart';
import 'package:dgg/services/dgg_api.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _dggApi = locator<DggApi>();

  bool get isSignedIn => _dggApi.sessionInfo is Available;
  String get username => (_dggApi.sessionInfo as Available).nick;

  void openFeedback() {
    launch(
      r"https://docs.google.com/forms/d/e/1FAIpQLScuIOGffMHf3HHnCVdHVN6u08Pr_VGd6nU9raaWJi5ANSN8QQ/viewform?usp=sf_link",
    );
  }

  void signOut() {
    _dggApi.signOut();
    notifyListeners();
  }

  void openProfile() {
    launch(
      r"https://www.destiny.gg/profile",
    );
  }

  void back() {
    _navigationService.back();
  }
}
