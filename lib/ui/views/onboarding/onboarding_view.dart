import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:stacked/stacked.dart';

import 'onboarding_viewmodel.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<OnboardingViewModel>.reactive(
      viewModelBuilder: () => OnboardingViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        body: IntroductionScreen(
          pages: <PageViewModel>[
            PageViewModel(
              title: "Welcome",
              body:
                  "This app will let you chat on destiny.gg! Before you begin we have to go over some information.\n\nDisclaimer: This app has no official association with Destiny or destiny.gg",
              image: Center(
                child: Image.asset(
                  "assets/images/dgg_icon.png",
                  width: 200,
                ),
              ),
            ),
            PageViewModel(
              title: "Analytics",
              body:
                  "By default this app collects general usage analytics while you use the app. No specific identifying information is collected. If you want to turn analytics on or off you can do so now or in the app settings later on.",
              image: const Center(
                child: Icon(
                  Icons.analytics,
                  size: 200,
                ),
              ),
              footer: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Analytics collection",
                          maxLines: 1,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Switch(
                        value: viewModel.isAnalyticsEnabled,
                        activeColor: Theme.of(context).colorScheme.primary,
                        onChanged: viewModel.toggleAnalyticsCollection,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Send crash reports",
                          maxLines: 1,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Switch(
                        value: viewModel.isCrashlyticsCollectionEnabled,
                        activeColor: Theme.of(context).colorScheme.primary,
                        onChanged: viewModel.toggleCrashlyticsCollection,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PageViewModel(
              title:
                  viewModel.isSignedIn ? "You are ready to go!" : "Final Thing",
              body: viewModel.isSignedIn
                  ? ""
                  : "To send messages in chat you must sign in, if you want to you can do that now. If not, you can always do it later in the settings.",
              image: const Center(
                child: Icon(
                  Icons.account_circle,
                  size: 200,
                ),
              ),
              footer: viewModel.isSignedIn
                  ? Text(
                      "Signed in as: ${viewModel.nickname}",
                      textAlign: TextAlign.center,
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text("Sign in"),
                      onPressed: () => viewModel.navigateToAuth(),
                    ),
            ),
          ],
          dotsDecorator: DotsDecorator(
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          done: const Text(
            "Done",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          skip: const Text("Skip", style: TextStyle(color: Colors.white)),
          next: const Text("Next"),
          onDone: viewModel.finishOnboarding,
          onSkip: viewModel.finishOnboarding,
          showNextButton: true,
          showSkipButton: true,
        ),
      ),
    );
  }
}
