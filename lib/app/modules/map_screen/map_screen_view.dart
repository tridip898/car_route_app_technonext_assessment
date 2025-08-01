import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'map_screen_controller.dart';

class MapScreenView extends GetView<MapScreenController> {
  const MapScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Car Route'), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            // Text("Map"),
            Obx(
              () => Expanded(
                child: GoogleMap(
                  initialCameraPosition: controller.initialCameraPosition,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                  onMapCreated: (mapController) {
                    controller.googleMapController = mapController;
                  },
                  markers: controller.markers,
                  polylines: controller.polylines,
                  onTap: (position) => controller.handleMapTap(position),
                ),
              ),
            ),
            Text("data"),
          ],
        ),
      ),
    );
  }
}
