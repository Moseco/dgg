import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

import '../auth_viewmodel.dart';

class AuthLoginKey extends StackedHookView<AuthViewModel> {
  const AuthLoginKey({super.key});

  @override
  Widget builder(BuildContext context, AuthViewModel viewModel) {
    final textEditingController = useTextEditingController();
    return AnimationLimiter(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
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
                  "Use login key",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  "This page will explain how to create a login key on destiny.gg and let you use it in this app. The screenshot below shows the correct page.",
                  textAlign: TextAlign.center,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  "• Step 1: Press the start button below to go to the correct destiny.gg page. If you are not signed in already, then sign in.\n\n• Step 2: Expand the 'Connections' drop down. If you do not have an item called 'DGG Login Key' then press the button 'Add login key'.\n\n• Step 3: Press the 'show' button next to 'DGG Login Key', copy the text that appears and return to this app.\n\n• Step 4: With the login key in your clipboard, press the button below to automatically grab the login key from your clipboard. Or enter your login key in the text field below.",
                ),
              ),
              viewModel.isAuthStarted
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text("Get key from clipboard and submit"),
                      onPressed: () => viewModel.getKeyFromClipboard(),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text("Go to destiny.gg"),
                      onPressed: () => viewModel.startAuthentication(),
                    ),
              if (viewModel.isClipboardError)
                const Text(
                  "Failed to get login key from clipboard",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: TextField(
                  controller: textEditingController,
                  maxLines: 1,
                  textInputAction: TextInputAction.done,
                  onSubmitted: viewModel.loginKeySubmitted,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    hintText: "Dgg login key",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () => viewModel
                          .loginKeySubmitted(textEditingController.text),
                    ),
                  ),
                ),
              ),
              Image.asset("assets/images/login_key.png"),
            ],
          ),
        ),
      ),
    );
  }
}
