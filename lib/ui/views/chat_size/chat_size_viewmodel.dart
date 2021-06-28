import 'package:dgg/app/app.locator.dart';
import 'package:dgg/services/shared_preferences_service.dart';
import 'package:stacked/stacked.dart';

class ChatSizeViewModel extends BaseViewModel {
  final _sharedPreferencesService = locator<SharedPreferencesService>();

  double _textSize = 1;
  double get textSize => _textSize;
  double _emoteSize = 1;
  double get emoteSize => _emoteSize;
  bool _flairEnabled = true;
  bool get flairEnabled => _flairEnabled;
  double _flairSize = 1;
  double get flairSize => _flairSize;

  double _textFontSize = 16;
  double get textFontSize => _textFontSize;
  double _iconSize = 20;
  double get iconSize => _iconSize;
  double _emoteHeight = 30;
  double get emoteHeight => _emoteHeight;
  double _flairHeight = 20;
  double get flairHeight => _flairHeight;

  String get textSizeLabel => _getLabel(_textSize);
  String get emoteSizeLabel => _getLabel(_emoteSize);
  String get flairSizeLabel => _getLabel(_flairSize);

  void initialize() {
    // Get raw values
    _textSize = _sharedPreferencesService.getChatTextSize().toDouble();
    _emoteSize = _sharedPreferencesService.getChatEmoteSize().toDouble();
    _flairEnabled = _sharedPreferencesService.getFlairEnabled();
    _flairSize = _sharedPreferencesService.getChatFlairSize().toDouble();
    // Translate values
    _updateTextFontSize();
    _updateEmoteHeight();
    _updateFlairHeight();

    notifyListeners();
  }

  void updateTextSize(double value) {
    _textSize = value;
    _updateTextFontSize();
    notifyListeners();
  }

  void _updateTextFontSize() {
    if (_textSize == 0) {
      _textFontSize = 12;
      _iconSize = 14;
    } else if (_textSize == 1) {
      _textFontSize = 16;
      _iconSize = 20;
    } else if (_textSize == 2) {
      _textFontSize = 20;
      _iconSize = 24;
    }
  }

  void updateEmoteSize(double value) {
    _emoteSize = value;
    _updateEmoteHeight();
    notifyListeners();
  }

  void _updateEmoteHeight() {
    if (_emoteSize == 0) {
      _emoteHeight = 20;
    } else if (_emoteSize == 1) {
      _emoteHeight = 30;
    } else if (_emoteSize == 2) {
      _emoteHeight = 40;
    }
  }

  String _getLabel(num value) {
    switch (value) {
      case 0:
        return "Small";
      case 1:
        return "Default";
      case 2:
        return "Large";
      default:
        return "";
    }
  }

  void updateFlairEnabled(bool value) {
    _flairEnabled = value;
    notifyListeners();
  }

  void updateFlairSize(double value) {
    _flairSize = value;
    _updateFlairHeight();
    notifyListeners();
  }

  void _updateFlairHeight() {
    if (_flairSize == 0) {
      _flairHeight = 15;
    } else if (_flairSize == 1) {
      _flairHeight = 20;
    } else if (_flairSize == 2) {
      _flairHeight = 25;
    }
  }

  @override
  void dispose() {
    _sharedPreferencesService.setChatTextSize(_textSize.toInt());
    _sharedPreferencesService.setChatEmoteSize(_emoteSize.toInt());
    _sharedPreferencesService.setFlairEnabled(_flairEnabled);
    _sharedPreferencesService.setChatFlairSize(_flairSize.toInt());
    super.dispose();
  }
}
