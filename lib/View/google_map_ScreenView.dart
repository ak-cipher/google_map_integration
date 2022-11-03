import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapScreenView extends StatefulWidget {
  const GoogleMapScreenView({super.key});

  @override
  State<GoogleMapScreenView> createState() => _GoogleMapScreenViewState();
}

class _GoogleMapScreenViewState extends State<GoogleMapScreenView> {
  Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _cameraPosition =
      CameraPosition(target: LatLng(20.9871, 80.9871), zoom: 14.4);

  final List<Marker> _markers = <Marker>[
    const Marker(
        markerId: MarkerId('1'), infoWindow: InfoWindow(title: 'My Position'))
  ];

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
    });
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF0F9D58),
          title: Text('Maps'),
        ),
        body: Container(
          child: SafeArea(
            child: GoogleMap(
              initialCameraPosition: _cameraPosition,
              markers: Set<Marker>.of(_markers),
              myLocationEnabled: true,
              compassEnabled: true,
              onMapCreated: ((controller) {
                _controller.complete(controller);
              }),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (() async {
            getUserCurrentLocation().then((value) async {
              print(
                  value.latitude.toString() + " " + value.longitude.toString());
              _markers.add(Marker(
                  markerId: const MarkerId('2'),
                  position: LatLng(value.latitude, value.longitude),
                  infoWindow: const InfoWindow(title: 'My Current Location')));
              CameraPosition cameraPosition = CameraPosition(
                  target: LatLng(value.latitude, value.longitude), zoom: 14.4);
              final GoogleMapController controller = await _controller.future;
              controller.animateCamera(
                  CameraUpdate.newCameraPosition(cameraPosition));
              setState(() {});
            });
          }),
          child: const Icon(Icons.local_activity),
        ),
      ),
    );
  }
}
