import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:stacked/stacked.dart';

import 'settings_viewmodel.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SettingsViewModel>.reactive(
      viewModelBuilder: () => SettingsViewModel(),
      onModelReady: (model) => model.initialize(),
      fireOnModelReadyOnce: true,
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
          backgroundColor:
              viewModel.appBarTheme == 1 ? Colors.transparent : null,
          elevation: viewModel.appBarTheme == 1 ? 0 : null,
        ),
        body: SettingsList(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          sections: [
            SettingsSection(
              title: 'Account',
              titlePadding: const EdgeInsets.only(
                  left: 15, right: 15, top: 15, bottom: 6),
              tiles: viewModel.isSignedIn
                  ? [
                      SettingsTile(
                        title: 'Account info',
                        subtitle: viewModel.username,
                        leading: const Icon(Icons.account_circle),
                        onPressed: (BuildContext context) =>
                            viewModel.openProfile(),
                      ),
                      SettingsTile(
                        title: 'Sign out',
                        leading: const Icon(Icons.logout),
                        onPressed: (BuildContext context) =>
                            viewModel.signOut(),
                      ),
                    ]
                  : [
                      SettingsTile(
                        title: 'Sign in',
                        leading: const Icon(Icons.account_circle),
                        onPressed: (BuildContext context) =>
                            viewModel.navigateToAuth(),
                      ),
                    ],
            ),
            SettingsSection(
              title: 'General',
              tiles: [
                SettingsTile(
                  title: 'Select app theme',
                  leading: const Icon(Icons.color_lens),
                  onPressed: (BuildContext context) =>
                      _showThemeDialog(context, viewModel),
                ),
                SettingsTile(
                  title: 'Select app bar theme',
                  leading: const Icon(Icons.line_style),
                  onPressed: (BuildContext context) =>
                      _showAppBarThemeDialog(context, viewModel),
                ),
              ],
            ),
            SettingsSection(
              title: 'Chat',
              tiles: [
                SettingsTile.switchTile(
                  title: 'Wakelock',
                  subtitle: 'Prevent screen from turning off while in chat',
                  subtitleMaxLines: 2,
                  leading: const Icon(Icons.lightbulb),
                  switchActiveColor: Theme.of(context).colorScheme.primary,
                  switchValue: viewModel.isWakelockEnabled,
                  onToggle: viewModel.toggleWakelockEnabled,
                ),
                SettingsTile(
                  title: 'Set default stream platform',
                  leading: const Icon(Icons.desktop_windows),
                  onPressed: (BuildContext context) =>
                      _showDefaultStreamDialog(context, viewModel),
                ),
                SettingsTile(
                  title: 'Customize chat style',
                  leading: const Icon(Icons.format_size),
                  onPressed: (BuildContext context) =>
                      viewModel.navigateToChatSize(),
                ),
                SettingsTile.switchTile(
                  title: 'Use in-app browser',
                  leading: const Icon(Icons.open_in_browser),
                  switchActiveColor: Theme.of(context).colorScheme.primary,
                  switchValue: viewModel.isInAppBrowserEnabled,
                  onToggle: viewModel.toggleInAppBrowserEnabled,
                ),
                SettingsTile(
                  title: 'Open ignore list',
                  leading: const Icon(Icons.person_off),
                  onPressed: (BuildContext context) =>
                      viewModel.navigateToIgnoreList(),
                ),
              ],
            ),
            SettingsSection(
              title: 'Analytics',
              tiles: [
                SettingsTile.switchTile(
                  title: 'Send crash reports',
                  leading: const Icon(Icons.bug_report),
                  switchActiveColor: Theme.of(context).colorScheme.primary,
                  switchValue: viewModel.isCrashlyticsCollectionEnabled,
                  onToggle: viewModel.toggleCrashlyticsCollection,
                ),
                SettingsTile.switchTile(
                  title: 'Analytics collection',
                  leading: const Icon(Icons.analytics),
                  switchActiveColor: Theme.of(context).colorScheme.primary,
                  switchValue: viewModel.isAnalyticsEnabled,
                  onToggle: viewModel.toggleAnalyticsCollection,
                ),
              ],
            ),
            SettingsSection(
              title: 'Misc',
              tiles: [
                SettingsTile(
                  title: 'Submit feedback',
                  subtitle: 'Opens Google Form',
                  leading: const Icon(Icons.feedback),
                  onPressed: (BuildContext context) => viewModel.openFeedback(),
                ),
                SettingsTile(
                  title: 'Source code',
                  subtitle: 'See the code on GitHub',
                  leading: const Icon(Icons.code),
                  onPressed: (BuildContext context) => viewModel.openGitHub(),
                ),
                SettingsTile(
                  title: 'About',
                  subtitle: 'App version: 0.11.0',
                  leading: const Icon(Icons.info),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, SettingsViewModel model) {
    showDialog(
      context: context,
      builder: (BuildContext c) => AlertDialog(
        title: const Text("Select app theme"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              RadioListTile<int>(
                title: const Text("Default"),
                value: 0,
                groupValue: model.themeIndex,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (int? value) {
                  model.setTheme(value!);
                  Navigator.of(c).pop();
                },
              ),
              RadioListTile<int>(
                title: const Text("True black"),
                value: 1,
                groupValue: model.themeIndex,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (int? value) {
                  model.setTheme(value!);
                  Navigator.of(c).pop();
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(c).pop(),
          ),
        ],
      ),
    );
  }

  void _showAppBarThemeDialog(BuildContext context, SettingsViewModel model) {
    showDialog(
      context: context,
      builder: (BuildContext c) => AlertDialog(
        title: const Text("Select app bar theme"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              RadioListTile<int>(
                title: const Text("Default"),
                value: 0,
                groupValue: model.appBarTheme,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (int? value) {
                  model.setAppBarTheme(value!);
                  Navigator.of(c).pop();
                },
              ),
              RadioListTile<int>(
                title: const Text("Match background"),
                value: 1,
                groupValue: model.appBarTheme,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (int? value) {
                  model.setAppBarTheme(value!);
                  Navigator.of(c).pop();
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(c).pop(),
          ),
        ],
      ),
    );
  }

  void _showDefaultStreamDialog(BuildContext context, SettingsViewModel model) {
    showDialog(
      context: context,
      builder: (BuildContext c) => AlertDialog(
        title: const Text("Set default stream platform"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              RadioListTile<int>(
                title: const Text("Twitch"),
                value: 0,
                groupValue: model.defaultStream,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (int? value) {
                  model.setDefaultStream(value!);
                  Navigator.of(c).pop();
                },
              ),
              RadioListTile<int>(
                title: const Text("YouTube"),
                value: 1,
                groupValue: model.defaultStream,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (int? value) {
                  model.setDefaultStream(value!);
                  Navigator.of(c).pop();
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(c).pop(),
          ),
        ],
      ),
    );
  }
}
