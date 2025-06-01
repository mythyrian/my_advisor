import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_advisor/theme/color.dart';
import 'package:my_advisor/utils/map_api.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  final Completer<GoogleMapController> _controller = Completer();

  CameraPosition? _initialPosition;

  double initZoom = 14.5;
  LatLngBounds? visibleRegion;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica se il servizio di localizzazione è attivo
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('I servizi di localizzazione sono disattivati.');
    }

    // Controlla e richiedi i permessi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permessi negati.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'I permessi sono negati permanentemente, non possiamo accedere alla posizione.',
      );
    }

    // Ottieni la posizione corrente
    final position = await Geolocator.getCurrentPosition();

    setState(() {
      _initialPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: initZoom,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child:
            _initialPosition == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _initialPosition!,
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  onMapCreated: (GoogleMapController controller) async {
                    _controller.complete(controller);
                    visibleRegion = await controller.getVisibleRegion();
                  },
                  onCameraIdle: () async {
                    final controller = await _controller.future;
                    visibleRegion = await controller.getVisibleRegion();

                    if (visibleRegion != null) {
                      _fetchNearbyPlaces(visibleRegion!);
                    }
                  },
                ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: FloatingActionButton(
          onPressed: _centerMyPosition,
          elevation: 0,
          highlightElevation: 0,
          backgroundColor: AppColor.sky,
          child: const Icon(Icons.my_location, color: AppColor.primary),
        ),
      ),
    );
  }

  Future<void> _centerMyPosition() async {
    final controller = await _controller.future;
    final position = await Geolocator.getCurrentPosition();

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: initZoom,
        ),
      ),
    );
  }

  Future<void> _fetchNearbyPlaces(LatLngBounds bounds) async {
    final response = await fetchNearbyPlaces(bounds);

    if (response != null) {
      for (var result in response) {
        final name = result['name'];
        final lat = result['geometry']['location']['lat'];
        final lng = result['geometry']['location']['lng'];

        _addMarker(LatLng(lat, lng), name);
      }
    }
  }

  void _addMarker(LatLng position, String name) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(name),
          position: position,
          infoWindow: InfoWindow(title: name),
        ),
      );
    });
  }
}
