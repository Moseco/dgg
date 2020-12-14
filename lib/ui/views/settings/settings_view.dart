import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:stacked/stacked.dart';

import 'settings_viewmodel.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SettingsViewModel>.reactive(
      viewModelBuilder: () => SettingsViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: SettingsList(
          backgroundColor: Colors.transparent,
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
                        leading: Icon(Icons.account_circle),
                        onPressed: (BuildContext context) =>
                            model.openProfile(),
                      ),
                      SettingsTile(
                        title: 'Sign out',
                        leading: Icon(Icons.logout),
                        onPressed: (BuildContext context) => model.signOut(),
                      ),
                    ]
                  : [
                      SettingsTile(
                        title: 'Sign in',
                        subtitle: 'Must be done from home screen',
                        leading: Icon(Icons.account_circle),
                        onPressed: (BuildContext context) => model.back(),
                      ),
                    ],
            ),
            SettingsSection(
              title: 'Analytics',
              tiles: [
                SettingsTile.switchTile(
                  title: 'Send crash reports',
                  leading: Icon(Icons.analytics),
                  switchActiveColor: Theme.of(context).primaryColor,
                  switchValue: model.isCrashlyticsCollectionEnabled,
                  onToggle: model.toggleCrashlyticsCollection,
                ),
              ],
            ),
            SettingsSection(
              title: 'Misc',
              tiles: [
                SettingsTile(
                  title: 'Submit feedback',
                  subtitle: 'Opens Google Form',
                  leading: Icon(Icons.feedback),
                  onPressed: (BuildContext context) => model.openFeedback(),
                ),
                SettingsTile(
                  title: 'About',
                  subtitle: 'App version: 0.1',
                  leading: Icon(Icons.info),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
