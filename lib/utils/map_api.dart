import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:toastification/toastification.dart';

Future<List<dynamic>?> fetchNearbyPlaces(
  LatLngBounds bounds, {
  String? type,
  String? keyword,
}) async {
  final String? apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

  final centerLat = (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
  final centerLng =
      (bounds.northeast.longitude + bounds.southwest.longitude) / 2;
  final radius = _calculateRadius(bounds);

  final queryParams = {
    'location': '$centerLat,$centerLng',
    'radius': '$radius',
    'key': apiKey,
    if (type != null && type.isNotEmpty) 'type': type,
    if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
  };

  final uri = Uri.https(
    'maps.googleapis.com',
    '/maps/api/place/nearbysearch/json',
    queryParams,
  );

  final response = await http.get(uri);
  final data = jsonDecode(response.body);

  if (data['status'] == 'OK') {
    return data['results'];
  } else {
    toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      title: Text('Errore Google API!'),
      description: RichText(
        text: TextSpan(text: "Errore Google API: ${data['status']}"),
      ),
      autoCloseDuration: const Duration(seconds: 3),
    );
    return null;
  }
}

Future<Map<String, dynamic>?> fetchPlaceDetails(String placeId) async {
  final String? apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

  final url = Uri.parse(
    'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      return data['result'];
    } else {
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        title: Text('Errore Google API!'),
        description: RichText(
          text: TextSpan(text: "Errore Google API: ${data['status']}"),
        ),
        autoCloseDuration: const Duration(seconds: 3),
      );
      return null;
    }
  } else {
    toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      title: Text('Errore HTTP!'),
      description: RichText(
        text: TextSpan(text: "Errore HTTP: ${response.statusCode}"),
      ),
      autoCloseDuration: const Duration(seconds: 3),
    );
    return null;
  }
}

String getImageUrl(String ref) {
  final String? apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
  return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=$ref&key=$apiKey";
}

Future<List<dynamic>?> fetchNearbyPlacesByKeyword(
  LatLngBounds bounds,
  keyWord,
) async {
  final String? apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

  final centerLat = (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
  final centerLng =
      (bounds.northeast.longitude + bounds.southwest.longitude) / 2;

  final radius = _calculateRadius(bounds);

  final url = Uri.parse(
    'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
    '?location=$centerLat,$centerLng'
    '&radius=$radius'
    '&keyword=$keyWord'
    '&key=$apiKey',
  );

  final response = await http.get(url);
  final data = jsonDecode(response.body);

  if (data['status'] == 'OK') {
    return data['results'];
  } else {
    toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      title: Text('Errore Google API!'),
      description: RichText(
        text: TextSpan(text: "Errore Google API: ${data['status']}"),
      ),
      autoCloseDuration: const Duration(seconds: 3),
    );
    return null;
  }
}

Future<List<dynamic>?> fetchNearbyPlacesShortRange() async {
  final String? apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
  final position = await _determinePosition();
  final uri = Uri.parse(
    'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
    '?location=${position.latitude},${position.longitude}'
    '&radius=50'
    '&key=$apiKey',
  );

  final response = await http.get(uri);
  final data = jsonDecode(response.body);

  if (data['status'] == 'OK') {
    return data['results'];
  } else {
    toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      title: Text('Errore Google API!'),
      description: RichText(
        text: TextSpan(text: "Errore Google API: ${data['status']}"),
      ),
      autoCloseDuration: const Duration(seconds: 3),
    );
    return null;
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) throw Exception('GPS non attivo');

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.deniedForever) {
    throw Exception('Permessi di posizione negati permanentemente');
  }

  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}

double _calculateRadius(LatLngBounds bounds) {
  final latDiff = bounds.northeast.latitude - bounds.southwest.latitude;
  final lngDiff = bounds.northeast.longitude - bounds.southwest.longitude;

  final approx = ((latDiff + lngDiff) / 2) * 111000;
  return approx / 2;
}
