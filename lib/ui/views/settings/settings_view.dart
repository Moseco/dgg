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
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
          backgroundColor: model.appBarTheme == 1 ? Colors.transparent : null,
          elevation: model.appBarTheme == 1 ? 0 : null,
        ),
        body: SettingsList(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          sections: [
            SettingsSection(
              title: 'Account',
              titlePadding: const EdgeInsets.only(
                  left: 15, right: 15, top: 15, bottom: 6),
              tiles: model.isSignedIn
                  ? [
                      SettingsTile(
                        title: 'Account info',
                        subtitle: model.username,
                        leading: const Icon(Icons.account_circle),
                        onPressed: (BuildContext context) =>
                            model.openProfile(),
                      ),
                      SettingsTile(
                        title: 'Sign out',
                        leading: const Icon(Icons.logout),
                        onPressed: (BuildContext context) => model.signOut(),
                      ),
                    ]
                  : [
                      SettingsTile(
                        title: 'Sign in',
                        leading: const Icon(Icons.account_circle),
                        onPressed: (BuildContext context) =>
                            model.navigateToAuth(),
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
                      _showThemeDialog(context, model),
                ),
                SettingsTile(
                  title: 'Select app bar theme',
                  leading: const Icon(Icons.line_style),
                  onPressed: (BuildContext context) =>
                      _showAppBarThemeDialog(context, model),
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
                  switchValue: model.isWakelockEnabled,
                  onToggle: model.toggleWakelockEnabled,
                ),
                SettingsTile(
                  title: 'Set default stream platform',
                  leading: const Icon(Icons.desktop_windows),
                  onPressed: (BuildContext context) =>
                      _showDefaultStreamDialog(context, model),
                ),
                SettingsTile(
                  title: 'Customize chat style',
                  leading: const Icon(Icons.format_size),
                  onPressed: (BuildContext context) =>
                      model.navigateToChatSize(),
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
                  switchValue: model.isCrashlyticsCollectionEnabled,
                  onToggle: model.toggleCrashlyticsCollection,
                ),
                SettingsTile.switchTile(
                  title: 'Analytics collection',
                  leading: const Icon(Icons.analytics),
                  switchActiveColor: Theme.of(context).colorScheme.primary,
                  switchValue: model.isAnalyticsEnabled,
                  onToggle: model.toggleAnalyticsCollection,
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
                  onPressed: (BuildContext context) => model.openFeedback(),
                ),
                SettingsTile(
                  title: 'About',
                  subtitle: 'App version: 0.9.2',
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
                activeColor: Theme.of(context).primaryColor,
                onChanged: (int? value) {
                  model.setTheme(value!);
                  Navigator.of(c).pop();
                },
              ),
              RadioListTile<int>(
                title: const Text("True black"),
                value: 1,
                groupValue: model.themeIndex,
                activeColor: Theme.of(context).primaryColor,
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
                activeColor: Theme.of(context).primaryColor,
                onChanged: (int? value) {
                  model.setAppBarTheme(value!);
                  Navigator.of(c).pop();
                },
              ),
              RadioListTile<int>(
                title: const Text("Match background"),
                value: 1,
                groupValue: model.appBarTheme,
                activeColor: Theme.of(context).primaryColor,
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
                activeColor: Theme.of(context).primaryColor,
                onChanged: (int? value) {
                  model.setDefaultStream(value!);
                  Navigator.of(c).pop();
                },
              ),
              RadioListTile<int>(
                title: const Text("YouTube"),
                value: 1,
                groupValue: model.defaultStream,
                activeColor: Theme.of(context).primaryColor,
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
