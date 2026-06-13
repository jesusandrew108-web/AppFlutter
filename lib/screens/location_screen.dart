import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Position>(
      future: Geolocator.getCurrentPosition(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        final pos = snapshot.data!;
        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(pos.latitude, pos.longitude),
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId: MarkerId('yo'),
              position: LatLng(pos.latitude, pos.longitude),
            ),
          },
        );
      },
    );
  }
}
