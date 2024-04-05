import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:stacked/stacked.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../auth_viewmodel.dart';

class AuthWebview extends ViewModelWidget<AuthViewModel> {
  const AuthWebview({super.key});

  @override
  Widget build(BuildContext context, AuthViewModel viewModel) {
    if (viewModel.isAuthStarted) {
      return WebView(
        initialUrl: "https://www.destiny.gg/login",
        javascriptMode: JavascriptMode.unrestricted,
        onPageStarted: (currentUrl) async => viewModel.readCookies(currentUrl),
      );
    } else {
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
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      "Sign in with webview",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 32),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      "This page will let you sign into your destiny.gg account and use it in this app. On the sign in page, make sure to select the 'remember me' option to stay signed in, then sign in normally.\nTo get started press the button below.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      "Warning: Signing in with Google might not work because Google has disabled WebView login. Use a different login option or go back and use the login key method",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text("Start"),
                    onPressed: () => viewModel.startAuthentication(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
