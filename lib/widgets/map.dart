import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_advisor/constant/color.dart';
import 'package:my_advisor/utils/hive_store.dart';
import 'package:my_advisor/utils/icon_service.dart';
import 'package:my_advisor/utils/map_api.dart';
import 'package:my_advisor/widgets/filter_dialog_content.dart';
import 'package:my_advisor/widgets/place_info.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:toastification/toastification.dart';
import 'package:my_advisor/constant/place_type.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

class MyMap extends StatefulWidget {
  const MyMap({super.key});

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final Completer<GoogleMapController> _controller = Completer();

  CameraPosition? _initialPosition;

  double initZoom = 14.5;
  LatLngBounds? visibleRegion;
  final Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
    visibleRegion = await controller.getVisibleRegion();

    /*final String style = await rootBundle.loadString('assets/map_style.json');
    controller.setMapStyle(style);*/
  }

  final PanelController _panelController = PanelController();
  Map<String, dynamic>? _selectedPlace;

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
      body: Stack(
        children: [
          Scaffold(
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
                          _onMapCreated(controller);
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
                      icon: const Icon(
                        Icons.search,
                        color: Color(AppColor.primary),
                      ),
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
                    child: const Icon(
                      Icons.tune,
                      color: Color(AppColor.primary),
                    ),
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
          ),
          SlidingUpPanel(
            controller: _panelController,
            minHeight: 0,
            maxHeight: MediaQuery.of(context).size.height * 0.7,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            panelSnapping: true, // assicura lo snap
            backdropEnabled:
                true, // permette di interagire meglio con tutta l'area
            panelBuilder:
                (ScrollController sc) => GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragUpdate: (details) {
                    _panelController.panelPosition +=
                        details.primaryDelta! /
                        MediaQuery.of(context).size.height;
                  },
                  onVerticalDragEnd: (details) {
                    if (_panelController.panelPosition > 0.5) {
                      _panelController.open();
                    } else {
                      _panelController.close();
                    }
                  },
                  child: _buildPlacePanel(sc),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacePanel(ScrollController sc) {
  if (_selectedPlace == null) {
    return const Center(child: CircularProgressIndicator());
  }

  return  PlaceInfo(placeData : _selectedPlace!, scrollController : sc ); 
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
    final originalPlaceTypePref = HiveStore.get("place_type_pref");

    if (originalPlaceTypePref == null || originalPlaceTypePref.isEmpty) {
      toastification.show(
        type: ToastificationType.warning,
        style: ToastificationStyle.fillColored,
        title: Text('Empty preference!'),
        description: RichText(
          text: const TextSpan(
            text: 'Please choose a preference in the filter',
          ),
        ),
        autoCloseDuration: const Duration(seconds: 3),
      );
      return;
    }

    final response = await fetchNearbyPlaces(
      bounds,
      originalPlaceTypePref["name"],
    );

    if (response != null) {
      setState(() {
        _markers.clear();
      });
      final rawRange = HiveStore.get("range_review_pref");
      final min = (rawRange?["min"] ?? 1).toDouble();
      final max = (rawRange?["max"] ?? 5).toDouble();
      final filteredResults =
          response.where((place) {
            final rating = place['rating'];
            return rating != null && rating >= min && rating <= max;
          }).toList();

      final circleAvatar = Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Color(AppColor.darker), width: 3),
        ),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 40,
          child: Icon(
            getIconByName(originalPlaceTypePref["icon"]),
            size: 40,
            color: Color(
              PlaceType.getColorByName(originalPlaceTypePref["name"]) as int,
            ),
          ),
        ),
      );

      for (var result in filteredResults) {
        final name = result['name'];
        final lat = result['geometry']['location']['lat'];
        final lng = result['geometry']['location']['lng'];
        _addMarker(LatLng(lat, lng), name, circleAvatar, result["place_id"]);
      }
    }
  }

  Future<void> _addMarker(
    LatLng position,
    String name,
    Container myCircleAvatar,
    String placeId,
  ) async {
    final icon = await myCircleAvatar.toBitmapDescriptor(
      logicalSize: const Size(80, 80),
      imageSize: const Size(80, 80),
    );

    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(name),
          position: position,
          icon: icon,
          infoWindow: InfoWindow(title: name),
          onTap: () async {
             final response = await fetchPlaceDetails(placeId);
            setState(() {
              _selectedPlace = response;
            });
            _panelController.open();
          },
        ),
      );
    });
  }
}
