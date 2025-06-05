import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_advisor/constant/circle_avatar_default.dart';
import 'package:my_advisor/constant/color.dart';
import 'package:my_advisor/utils/hive_store.dart';
import 'package:my_advisor/utils/icon_service.dart';
import 'package:my_advisor/utils/map_api.dart';
import 'package:my_advisor/widgets/filter_dialog_content.dart';
import 'package:my_advisor/widgets/my_search_bar.dart';
import 'package:my_advisor/widgets/place_info.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:toastification/toastification.dart';
import 'package:my_advisor/constant/place_type.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

class MyMap extends StatefulWidget {
  const MyMap({super.key, required this.mode, this.listHistoryPlaces});

  final String mode;
  final List<dynamic>? listHistoryPlaces;

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final Completer<GoogleMapController> _controller = Completer();

  CameraPosition? _initialPosition;
  Set<Polyline> polylinePointsMap = {};
  double initZoom = 14.5;
  LatLngBounds? visibleRegion;
  final Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
    visibleRegion = await controller.getVisibleRegion();
  }

  final PanelController _panelController = PanelController();
  Map<String, dynamic>? _selectedPlace;

  ValueNotifier<List<dynamic>> responseMarker = ValueNotifier([]);

  List<Map> listCircleAvatar = [];

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
    genereteListCircleAvatar();
    responseMarker.addListener(() {
      _generateMarker();
    });

    if (widget.listHistoryPlaces != null) {
      _generateMarkerHistory();
    }
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
            backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
            body:
                widget.mode == "history"
                    ? googleMap()
                    : SafeArea(child: googleMap()),
            floatingActionButton: Stack(
              children: [
                widget.mode == "history"
                    ? Container()
                    : Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 170, left: 40),
                        child: FloatingActionButton.extended(
                          heroTag: 'searchButton',
                          elevation: 0,
                          highlightElevation: 0,
                          onPressed: () async {
                            _fetchNearbyPlaces();
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

                widget.mode == "history"
                    ? Container()
                    : Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 120, left: 40),
                        child: MySearchBar(
                          showFilter: false,
                          search: _fetchNearbyPlaces,
                        ),
                      ),
                    ),

                widget.mode == "history"
                    ? Container()
                    : Positioned(
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
            maxHeight:
                widget.mode == "home"
                    ? MediaQuery.of(context).size.height * 0.71
                    : MediaQuery.of(context).size.height * 0.4,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            panelSnapping: true,
            backdropEnabled: true,
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

  Widget googleMap() {
    return _initialPosition == null
        ? const Center(child: CircularProgressIndicator())
        : GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _initialPosition!,
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          polylines: polylinePointsMap,
          onMapCreated: (GoogleMapController controller) async {
            _onMapCreated(controller);
          },
          onCameraIdle: () async {},
        );
  }

  Widget _buildPlacePanel(ScrollController sc) {
    if (_selectedPlace == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return PlaceInfo(
      placeData: _selectedPlace!,
      scrollController: sc,
      mode: widget.mode,
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

  Future<void> _fetchNearbyPlaces() async {
    final controller = await _controller.future;
    final bounds = await controller.getVisibleRegion();
    final originalPlaceTypePref = HiveStore.get("place_type_pref");
    final keyWord = HiveStore.get("search_keyword");

    if ((originalPlaceTypePref == null || originalPlaceTypePref.isEmpty) &&
        keyWord == "") {
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
      type: originalPlaceTypePref["name"],
      keyword: keyWord,
    );

    if (response != null) {
      setState(() {
        responseMarker.value = response;
        _markers.clear();
      });
    }
  }

  Future<void> _generateMarker() async {
    final originalPlaceTypePref = HiveStore.get("place_type_pref");
    final rawRange = HiveStore.get("range_review_pref");
    final min = (rawRange?["min"] ?? 1).toDouble();
    final max = (rawRange?["max"] ?? 5).toDouble();
    final filteredResults =
        responseMarker.value.where((place) {
          final rating = place['rating'];
          return rating != null && rating >= min && rating <= max;
        }).toList();

    for (var result in filteredResults) {
      final name = result['name'];
      final lat = result['geometry']['location']['lat'];
      final lng = result['geometry']['location']['lng'];
      List types = result['types'] ?? [];

      Map circleAvatar = {};

      if (originalPlaceTypePref.isEmpty) {
        circleAvatar = listCircleAvatar.firstWhere(
          (b) => types.any((a) => a == b['name']),
          orElse: () => {"widget": circleAvatarDefault},
        );
      } else {
        circleAvatar = listCircleAvatar.firstWhere(
          (b) => b["name"] == originalPlaceTypePref["name"],
          orElse: () => {"widget": circleAvatarDefault},
        );
      }

      _addMarker(
        LatLng(lat, lng),
        name,
        circleAvatar["widget"],
        result["place_id"],
      );
    }
  }

  Future<void> _generateMarkerHistory() async {
    List<LatLng> polylinePoints = [];

    for (var result in widget.listHistoryPlaces!) {
      final name = result['name'];
      final lat = result['lat'];
      final lng = result['lng'];
      List types = result['types'] ?? [];

      polylinePoints.add(LatLng(lat, lng));

      Map circleAvatar = {};

      circleAvatar = listCircleAvatar.firstWhere(
        (b) => types.any((a) => a == b['name']),
        orElse: () => {"widget": circleAvatarDefault},
      );

      _addMarker(
        LatLng(lat, lng),
        name,
        circleAvatar["widget"],
        result["place_id"],
      );
    }

    Set<Polyline> polylines = {
      Polyline(
        polylineId: const PolylineId("route"),
        color: Colors.blue,
        width: 5,
        points: polylinePoints,
      ),
    };

    setState(() {
      polylinePointsMap = polylines;
    });
  }

  void genereteListCircleAvatar() {
    List<Map> list = [];

    for (var element in PlaceType.placeTypeList) {
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
            getIconByName(element["icon"] as String),
            size: 40,
            color: Color(
              PlaceType.getColorByName(element["name"] as String) as int,
            ),
          ),
        ),
      );

      list.add({"name": element["name"], "widget": circleAvatar});
    }

    setState(() {
      listCircleAvatar = list;
    });
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
