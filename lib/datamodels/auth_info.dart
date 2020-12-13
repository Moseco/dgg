class AuthInfo {
  final String sid;
  final String rememberMe;
  final String loginKey;

  const AuthInfo({
    this.sid,
    this.rememberMe,
    this.loginKey,
  });

  String toHeaderString() {
    var cookieHeader = StringBuffer();

    if (loginKey != null) {
      cookieHeader.write("authtoken=");
      cookieHeader.write(loginKey);
    } else {
      if (sid != null) {
        cookieHeader.write("sid=");
        cookieHeader.write(sid);
      }

      if (rememberMe != null) {
        cookieHeader.write(";rememberme=");
        cookieHeader.write(rememberMe);
      }
    }

    return cookieHeader.toString();
  }
}
