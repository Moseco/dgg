import 'package:dgg/datamodels/auth_info.dart';
import 'package:injectable/injectable.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';

@lazySingleton
class CookieManagerService {
  static const COOKIE_NAME_SID = "sid";
  static const COOKIE_NAME_REMEMBER_ME = "rememberme";
  static const url = "https://www.destiny.gg";
  static const urlProfile = "https://www.destiny.gg/profile";

  final cookieManager = WebviewCookieManager();

  clearCookies() async {
    cookieManager.clearCookies();
  }

  Future<AuthInfo> readCookies(String currentUrl) async {
    if (currentUrl == urlProfile) {
      final gotCookies = await cookieManager.getCookies(url);

      String sid;
      String rememberMe;
      for (var item in gotCookies) {
        if (item.name == COOKIE_NAME_SID) {
          sid = item.value;
        } else if (item.name == COOKIE_NAME_REMEMBER_ME) {
          rememberMe = item.value;
        }
      }

      if (sid != null) {
        return AuthInfo(sid, rememberMe);
      } else {
        return null;
      }
    } else {
      return null;
    }
  }
}
