import 'package:auto_route/auto_route_annotations.dart';
import 'package:dgg/ui/views/screens.dart';

//Generate files
//  flutter pub run build_runner build
@MaterialAutoRouter(routes: [
  MaterialRoute(page: HomeView, initial: true),
  MaterialRoute(page: AuthView),
  MaterialRoute(page: ChatView),
  MaterialRoute(page: SettingsView),
])
class $AutoRouter {}
