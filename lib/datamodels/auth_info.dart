class AuthInfo {
  final String sid;
  final String rememberMe;

  const AuthInfo(
    this.sid,
    this.rememberMe,
  );

  String toHeaderString() {
    var cookieHeader = StringBuffer();

    if (sid != null) {
      cookieHeader.write("sid=");
      cookieHeader.write(sid);
    }

    if (rememberMe != null) {
      cookieHeader.write(";rememberme=");
      cookieHeader.write(rememberMe);
    }

    return cookieHeader.toString();
  }
}
