import 'package:dgg/app/app.locator.dart';
import 'package:dgg/services/shared_preferences_service.dart';
import 'package:stacked/stacked.dart';

class ChatSizeViewModel extends BaseViewModel {
  final _sharedPreferencesService = locator<SharedPreferencesService>();

  double _textSize = 1;
  double get textSize => _textSize;
  double _emoteSize = 1;
  double get emoteSize => _emoteSize;

  double _textFontSize = 16;
  double get textFontSize => _textFontSize;
  double _iconSize = 20;
  double get iconSize => _iconSize;
  double _emoteHeight = 30;
  double get emoteHeight => _emoteHeight;

  String get textSizeLabel => _getLabel(_textSize);
  String get emoteSizeLabel => _getLabel(_emoteSize);

  void initialize() {
    // Get raw values
    _textSize = _sharedPreferencesService.getChatTextSize().toDouble();
    _emoteSize = _sharedPreferencesService.getChatEmoteSize().toDouble();
    // Translate values
    _updateTextFontSize();
    _updateEmoteHeight();

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

  @override
  void dispose() {
    _sharedPreferencesService.setChatTextSize(_textSize.toInt());
    _sharedPreferencesService.setChatEmoteSize(_emoteSize.toInt());
    super.dispose();
  }
}
