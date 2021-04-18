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
      builder: (context, model, child) => Scaffold(
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
              image: Center(
                child: Icon(
                  Icons.analytics,
                  size: 200,
                ),
              ),
              footer: _buildAnalyticsSwitches(context, model),
            ),
            PageViewModel(
              title: model.isSignedIn ? "You are ready to go!" : "Final Thing",
              body: model.isSignedIn
                  ? ""
                  : "To send messages in chat you must sign in, if you want to you can do that now. If not, you can always do it later in the settings.",
              image: Center(
                child: Icon(
                  Icons.account_circle,
                  size: 200,
                ),
              ),
              footer: _buildSigninButton(context, model),
            ),
          ],
          dotsDecorator: DotsDecorator(
            activeColor: Theme.of(context).primaryColor,
          ),
          done: const Text(
            "Done",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          skip: const Text("Skip", style: TextStyle(color: Colors.white)),
          next: const Text("Next"),
          onDone: model.finishOnboarding,
          onSkip: model.finishOnboarding,
          showNextButton: true,
          showSkipButton: true,
        ),
      ),
    );
  }

  Widget _buildAnalyticsSwitches(
      BuildContext context, OnboardingViewModel model) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Analytics collection",
                maxLines: 1,
                style: TextStyle(fontSize: 20),
              ),
            ),
            Switch(
              value: model.isAnalyticsEnabled,
              activeColor: Theme.of(context).primaryColor,
              onChanged: model.toggleAnalyticsCollection,
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                "Send crash reports",
                maxLines: 1,
                style: TextStyle(fontSize: 20),
              ),
            ),
            Switch(
              value: model.isCrashlyticsCollectionEnabled,
              activeColor: Theme.of(context).primaryColor,
              onChanged: model.toggleCrashlyticsCollection,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSigninButton(BuildContext context, OnboardingViewModel model) {
    if (model.isSignedIn) {
      return Text(
        "Signed in as: ${model.nickname}",
        textAlign: TextAlign.center,
      );
    } else {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text("Sign in"),
        onPressed: () => model.navigateToAuth(),
      );
    }
  }
}
