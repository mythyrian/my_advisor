import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_advisor/constant/color.dart';
import 'package:my_advisor/utils/map_api.dart';
import 'package:my_advisor/widgets/filter_dialog_content.dart';

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
                  zoomControlsEnabled: false,
                  onMapCreated: (GoogleMapController controller) async {
                    _controller.complete(controller);
                    visibleRegion = await controller.getVisibleRegion();
                  },
                  onCameraIdle: () async {},
                ),
      ),
      floatingActionButton: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 120, left: 40),
              child: FloatingActionButton.extended(
                heroTag: 'searchButton',
                elevation: 0,
                highlightElevation: 0,
                onPressed: () async {
                  final controller = await _controller.future;
                  final bounds = await controller.getVisibleRegion();
                  _fetchNearbyPlaces(bounds);
                },
                backgroundColor: Color(AppColor.sky),
                icon: const Icon(Icons.search, color: Color(AppColor.primary)),
                label: const Text("Search by filter"),
              ),
            ),
          ),
          Positioned(
            bottom: 125,
            right: 0,
            child: FloatingActionButton(
              heroTag: 'filterButton',
              onPressed: _openFilterList,
              elevation: 0,
              highlightElevation: 0,
              backgroundColor: Color(AppColor.sky),
              child: const Icon(Icons.tune, color: Color(AppColor.primary)),
            ),
          ),
          Positioned(
            bottom: 60,
            right: 0,
            child: FloatingActionButton(
              heroTag: 'centerButton',
              onPressed: _centerMyPosition,
              elevation: 0,
              highlightElevation: 0,
              backgroundColor: Color(AppColor.sky),
              child: const Icon(
                Icons.my_location,
                color: Color(AppColor.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFilterList() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: const FilterDialogContent(),
        );
      },
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

        /* final types = result['types'] as List<dynamic>;
        final mainType = types.isNotEmpty ? types[0] : 'default';
        final icon = await _getIconForType(mainType); */

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
