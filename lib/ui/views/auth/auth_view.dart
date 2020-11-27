import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'auth_viewmodel.dart';

class AuthView extends StatelessWidget {
  const AuthView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AuthViewModel>.reactive(
      viewModelBuilder: () => AuthViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: Text("Sign in"),
        ),
        body: SafeArea(
          child: model.isAuthStarted
              ? _buildWebView(model)
              : _buildInstructions(model),
        ),
      ),
    );
  }

  Widget _buildInstructions(AuthViewModel model) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                "Sign in on destiny.gg",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                "This page will let you sign into destiny.gg and use your account in this app.\nOn the sign in page, select the \'remember me\' option to stay signed in.\nTo get started press the button below.",
                textAlign: TextAlign.center,
              ),
            ),
            RaisedButton(
              child: Text("Start sign in"),
              onPressed: () => model.startAuthentication(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebView(AuthViewModel model) {
    return WebView(
      initialUrl: "https://www.destiny.gg/login",
      javascriptMode: JavascriptMode.unrestricted,
      onPageStarted: (currentUrl) async => model.readCookies(currentUrl),
    );
  }
}
