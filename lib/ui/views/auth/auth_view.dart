import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'auth_viewmodel.dart';
import 'widgets/auth_login_key.dart';
import 'widgets/auth_webview.dart';

class AuthView extends StatelessWidget {
  const AuthView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AuthViewModel>.reactive(
      viewModelBuilder: () => AuthViewModel(),
      builder: (context, viewModel, child) => WillPopScope(
        onWillPop: viewModel.handleOnWillPop,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Sign in"),
          ),
          body: SafeArea(
            child: viewModel.isAuthMethodSelected
                ? const _AuthMethod()
                : const _Instructions(),
          ),
        ),
      ),
    );
  }
}

class _Instructions extends ViewModelWidget<AuthViewModel> {
  const _Instructions({Key? key}) : super(key: key, reactive: false);

  @override
  Widget build(BuildContext context, AuthViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                "Sign in with destiny.gg",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                "How would you like to sign in with your destiny.gg account?",
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: 200,
              height: 50,
              margin: const EdgeInsets.only(top: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Use in-app webview",
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () =>
                    viewModel.setAuthMethod(AuthViewModel.AUTH_METHOD_WEBVIEW),
              ),
            ),
            TextButton(
              child: const Text(
                "Use login key",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.white,
                ),
              ),
              onPressed: () =>
                  viewModel.setAuthMethod(AuthViewModel.AUTH_METHOD_LOGIN_KEY),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthMethod extends ViewModelWidget<AuthViewModel> {
  const _AuthMethod({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, AuthViewModel viewModel) {
    if (viewModel.isSavingAuth) {
      if (viewModel.isVerifyFailed) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text("Failed to verify login information with dgg."),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text("Try again"),
                onPressed: () => viewModel.restartAuth(),
              ),
            ],
          ),
        );
      } else {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(),
              ),
              Text("Verifying information with dgg."),
            ],
          ),
        );
      }
    } else {
      if (viewModel.authMethod == AuthViewModel.AUTH_METHOD_WEBVIEW) {
        return const AuthWebview();
      } else {
        return const AuthLoginKey();
      }
    }
  }
}
