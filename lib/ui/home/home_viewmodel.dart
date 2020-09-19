import 'package:dgg/app/locator.dart';
import 'package:dgg/app/router.gr.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HomeViewModel extends BaseViewModel {
  final NavigationService _navigationService = locator<NavigationService>();

  Future navigateToAuth() async {
    await _navigationService.navigateTo(Routes.authView);
  }

  Future navigateToChat() async {
    await _navigationService.navigateTo(Routes.chatView);
  }
}
