import 'package:dgg/app/app.locator.dart';
import 'package:dgg/services/shared_preferences_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class IgnoreListViewModel extends BaseViewModel {
  final _sharedPreferencesService = locator<SharedPreferencesService>();
  final _dialogService = locator<DialogService>();

  List<String>? ignoreList;

  bool _updateIgnoreList = false;

  void initialize() {
    ignoreList = _sharedPreferencesService.getIgnoreList();
    notifyListeners();
  }

  void removeFromIgnoreList(int index) {
    ignoreList!.removeAt(index);
    _updateIgnoreList = true;
    notifyListeners();
  }

  void openHelp() {
    _dialogService.showDialog(
      barrierDismissible: true,
      description:
          "This page lets you view and edit your ignore list. Messages from ignored users will not show up in the chat. To ignore users, long press their message in the chat and press ignore.",
    );
  }

  @override
  void dispose() {
    // If ignore list has changed, set changes
    if (_updateIgnoreList) {
      _sharedPreferencesService.setIgnoreList(ignoreList!);
    }
    super.dispose();
  }
}
