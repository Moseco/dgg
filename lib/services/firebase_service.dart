import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart'
    show FlutterError, PlatformDispatcher, kDebugMode;
import 'package:dgg/firebase_options.dart';
import 'package:stacked/stacked_annotations.dart';

class FirebaseService implements InitializableDependency {
  bool get crashlyticsEnabled =>
      FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled;

  @override
  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Enable Firebase Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    // If in debug mode disable analytics and crashlytics collection
    if (kDebugMode) {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    }
  }

  void setAnalyticsEnabled(bool enabled) {
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(enabled);
  }

  void setCrashlyticsEnabled(bool enabled) {
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);
  }

  Future<String?> getAppInstanceId() async {
    return FirebaseAnalytics.instance.appInstanceId;
  }
}
