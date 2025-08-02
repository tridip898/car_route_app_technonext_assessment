import 'package:get/get.dart';

import '../modules/map_screen/map_screen_binding.dart';
import '../modules/map_screen/map_screen_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.MAP_SCREEN;

  static final routes = [
    GetPage(
      name: _Paths.MAP_SCREEN,
      page: () => const MapScreenView(),
      binding: MapScreenBinding(),
    ),
  ];
}
