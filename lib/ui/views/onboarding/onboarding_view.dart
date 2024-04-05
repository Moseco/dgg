import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:stacked/stacked.dart';

import 'onboarding_viewmodel.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<OnboardingViewModel>.reactive(
      viewModelBuilder: () => OnboardingViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        body: IntroductionScreen(
          next: const Text('Next'),
          done: const Text('Done'),
          showSkipButton: true,
          skip: const Text('Skip'),
          onDone: viewModel.finishOnboarding,
          onSkip: viewModel.finishOnboarding,
          dotsDecorator: DotsDecorator(
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          pages: <PageViewModel>[
            PageViewModel(
              image: Image.asset(
                'assets/images/dgg_icon.png',
                width: 160,
              ),
              title: 'Welcome',
              body:
                  'This app will let you chat on destiny.gg! Before you begin we have to go over some information.\n\nDisclaimer: This app has no official association with Destiny or destiny.gg',
            ),
            PageViewModel(
              image: const Icon(
                Icons.analytics,
                size: 160,
              ),
              title: 'Analytics',
              bodyWidget: Column(
                children: [
                  const Text(
                    'By default this app collects general usage analytics while you use the app. No identifying information is collected. If you want to turn analytics on or off you can do so now or in the app settings later on.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text(
                      'Analytics',
                      style: TextStyle(fontSize: 18),
                    ),
                    activeColor: Theme.of(context).colorScheme.primary,
                    value: viewModel.isAnalyticsEnabled,
                    onChanged: viewModel.toggleAnalyticsCollection,
                  ),
                  SwitchListTile(
                    title: const Text(
                      'Crash reports',
                      style: TextStyle(fontSize: 18),
                    ),
                    activeColor: Theme.of(context).colorScheme.primary,
                    value: viewModel.isCrashlyticsCollectionEnabled,
                    onChanged: viewModel.toggleCrashlyticsCollection,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: viewModel.openPrivacyPolicy,
                    child: const Text(
                      'View privacy policy',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            PageViewModel(
              image: const Icon(
                Icons.account_circle,
                size: 160,
              ),
              title:
                  viewModel.isSignedIn ? 'You are ready to go!' : 'Final Thing',
              bodyWidget: Column(
                children: [
                  if (!viewModel.isSignedIn)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text(
                        'To send messages in chat you must sign in, if you want to you can do that now. If not, you can always do it later in the settings.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  viewModel.isSignedIn
                      ? Text(
                          'Signed in as: ${viewModel.nickname}',
                          textAlign: TextAlign.center,
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Sign in'),
                          onPressed: () => viewModel.navigateToAuth(),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
