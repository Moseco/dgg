// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:stacked_services/stacked_services.dart';

import '../services/cookie_manager_service.dart';
import '../services/dgg_api.dart';
import '../services/shared_preferences_service.dart';
import '../services/third_party_services_module.dart';
import '../services/user_message_elements_service.dart';

/// adds generated dependencies
/// to the provided [GetIt] instance

GetIt $initGetIt(
  GetIt get, {
  String environment,
  EnvironmentFilter environmentFilter,
}) {
  final gh = GetItHelper(get, environment, environmentFilter);
  final thirdPartyServicesModule = _$ThirdPartyServicesModule();
  gh.lazySingleton<CookieManagerService>(() => CookieManagerService());
  gh.lazySingleton<DggApi>(() => DggApi());
  gh.lazySingleton<NavigationService>(
      () => thirdPartyServicesModule.navigationService);
  gh.lazySingleton<SharedPreferencesService>(() => SharedPreferencesService());
  gh.lazySingleton<UserMessageElementsService>(
      () => UserMessageElementsService());
  return get;
}

class _$ThirdPartyServicesModule extends ThirdPartyServicesModule {
  @override
  NavigationService get navigationService => NavigationService();
}
