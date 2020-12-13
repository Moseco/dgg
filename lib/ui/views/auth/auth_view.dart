import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
          child: model.isAuthMethodSelected
              ? _buildAuthMethod(context, model)
              : _buildInstructions(context, model),
        ),
      ),
    );
  }

  Widget _buildInstructions(BuildContext context, AuthViewModel model) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
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
                "How would you like to sign in with your destiny.gg account?",
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: 200,
              height: 50,
              margin: const EdgeInsets.only(top: 16),
              child: RaisedButton(
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "Use in-app webview",
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () =>
                    model.setAuthMethod(AuthViewModel.AUTH_METHOD_WEBVIEW),
              ),
            ),
            FlatButton(
              child: Text(
                "Use login key",
                style: TextStyle(decoration: TextDecoration.underline),
              ),
              onPressed: () =>
                  model.setAuthMethod(AuthViewModel.AUTH_METHOD_LOGIN_KEY),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthMethod(BuildContext context, AuthViewModel model) {
    if (model.authMethod == AuthViewModel.AUTH_METHOD_WEBVIEW) {
      if (model.isAuthStarted) {
        return _buildWebView(model);
      } else {
        return _buildWebViewInstructions(context, model);
      }
    } else {
      return _buildLoginKeyInstructions(context, model);
    }
  }

  Widget _buildWebViewInstructions(BuildContext context, AuthViewModel model) {
    return AnimationLimiter(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: widget,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "Sign in with webview",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "This page will let you sign into destiny.gg and use your account in this app. On the sign in page, make sure to select the \'remember me\' option to stay signed in, then sign in normally.\nTo get started press the button below.",
                    textAlign: TextAlign.center,
                  ),
                ),
                RaisedButton(
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "Start",
                  ),
                  onPressed: () => model.startAuthentication(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginKeyInstructions(BuildContext context, AuthViewModel model) {
    return AnimationLimiter(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: widget,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "Use login key",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "This page will explain how to create a login key on destiny.gg and let you use it to use your account in this app.",
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "•Step 1: Press the \'Start\' button below to go to the correct destiny.gg page. If you are not signed in already, then sign in.\n\n•Step 2: Expand the \'Connections\' drop down. If you do not have an item called \'DGG Login Key\' then press the button \'Add login key\'.\n\n•Step 3: Press the \'show\' button next to \'DGG Login Key\', copy the text that appears and return to this app.\n\n•Step 4: Press the button below to automatically grab the login key from your clipboard.",
                  ),
                ),
                !model.isAuthStarted
                    ? RaisedButton(
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          "Go to destiny.gg",
                        ),
                        onPressed: () => model.startAuthentication(),
                      )
                    : model.isSavingAuth
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          )
                        : RaisedButton(
                            color: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              "Get key from clipboard and submit",
                            ),
                            onPressed: () => model.getKeyFromClipboard(),
                          ),
                Image.asset("assets/images/login_key.png"),
              ],
            ),
          ),
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