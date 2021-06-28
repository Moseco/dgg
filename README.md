# Unofficial Dgg chat app

This is an unofficial Dgg chat app built with [Flutter](https://flutter.dev/docs).

You can install it from the Play Store by clicking [here](https://play.google.com/store/apps/details?id=dev.moseco.dgg).

Currently only Android is confirmed to be working, so some setup might be required to get an iOS build working.

## Feature support

- [x] Sign in
- [x] View chat messages
- [x] Send chat message while signed in
- [x] Basic emotes
- [x] Stream embed
    - [x] Twitch
    - [x] YouTube
- [x] Manually set Twitch stream embed channel
- [x] Allow clicking in chat embed messages
    - [x] Support "#twitch/channel" format
    - [x] Support "#youtube/channel" format
    - [x] Support "#twitch-vod/id" format
    - [x] Support "#twitch-clip/id" format
- [x] Chat voting
- [x] Chat text color changes
    - [x] Green text when text has leading '>'
    - [x] Red underline when text contains 'nsfw'
    - [x] Yellow underline when text contains 'nsfl'
- [x] Allow user to set default stream embed platform (Twitch or YouTube)
- [x] Load chat history when user connects
- [x] User flairs
- [ ] Animated emotes 
    - [x] Emotes in gif format
    - [x] Emotes with frames in a single png
    - [ ] Emotes with extra effects
- [ ] Context sensitive  emotes
    - [ ] Blade: direction based on other emotes
    - [ ] MonkaVirus: Color change and multiple causes one to 'die'
- [ ] Private messages

## Building

### Basic

Follow the [Flutter documentation](https://flutter.dev/docs) to get the framework up and running.

### Firebase

This project uses Firebase for analytics/crashlytics. To get a build working you will either need to [create a Firebase project on your own and add a config file](https://firebase.flutter.dev/docs/overview) or remove the Firebase related code manually.

If you want to remove Firebase, here is a rough list of what you need to do (at least for Android).

* Remove `classpath 'com.google.gms:google-services:4.3.5'` and `classpath 'com.google.firebase:firebase-crashlytics-gradle:2.5.1'` from `android/build.gradle`
* Remove `apply plugin: 'com.google.gms.google-services'` and `apply plugin: 'com.google.firebase.crashlytics'` from `android/app/build.gradle`
* Remove `firebase_core` and `firebase_remote_config` and `firebase_crashlytics:` and `firebase_analytics` from `pubspec.yaml`. Then go through `lib/` and delete any code that the editor now doesn't recognize.
