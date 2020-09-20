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
          child:
              model.isStarted ? _buildWebView(model) : _buildOnboarding(model),
        ),
      ),
    );
  }

  Widget _buildOnboarding(AuthViewModel model) {
    return Center(
      child: RaisedButton(
        child: Text("Start"),
        onPressed: () => model.startAuthentication(),
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
