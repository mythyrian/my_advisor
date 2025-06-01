import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<List<dynamic>?> fetchNearbyPlaces(LatLngBounds bounds) async {
  final String? apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
  final String placeType = 'restaurant';

  final centerLat = (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
  final centerLng =
      (bounds.northeast.longitude + bounds.southwest.longitude) / 2;

  final radius = _calculateRadius(bounds);

  final url = Uri.parse(
    'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
    '?location=$centerLat,$centerLng'
    '&radius=$radius'
    '&type=$placeType'
    '&key=$apiKey',
  );

  final response = await http.get(url);
  final data = jsonDecode(response.body);

  if (data['status'] == 'OK') {
    return data['results'];
  } else {
    return null;
  }
}

double _calculateRadius(LatLngBounds bounds) {
  final latDiff = bounds.northeast.latitude - bounds.southwest.latitude;
  final lngDiff = bounds.northeast.longitude - bounds.southwest.longitude;

  final approx = ((latDiff + lngDiff) / 2) * 111000;
  return approx / 2;
}
