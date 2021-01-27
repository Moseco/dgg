# Unofficial Dgg chat app

This is an unofficial Dgg chat app built with [Flutter](https://flutter.dev/docs).

You can install it from the Play Store by clicking [here](https://play.google.com/store/apps/details?id=dev.moseco.dgg).

Currently only Android is confirmed to be working, so some setup might be required to get an iOS build working.

## Feature support

- [x] Sign in
- [x] View chat messages
- [x] Send chat message while signed in
- [x] Basic emotes
- [x] Twitch stream embed
- [x] Change Twitch stream embed channel
- [x] Allow clicking on "#twitch/channel" to open stream embed on that channel
- [x] Chat voting
- [ ] Context sensitive  emotes (e.g. sword direction)
- [ ] Animated emotes 
- [ ] Private messages
- [ ] Chat text color changes (e.g. '>' causes green text for subs)
- [ ] Probably more?

## Building

This project uses Firebase for analytics and remote changes. To get a build working you will either need to [create a Firebase project on your own](https://firebase.google.com/docs/flutter/setup?platform=android) or remove the Firebase related code manually. The easiest way to do this is to remove the Firebase packages from the pubspec.yaml file (currently firebase_core, firebase_remote_config, firebase_crashlytics, firebase_analytics) and delete any code that the editor now doesn't recognize.
