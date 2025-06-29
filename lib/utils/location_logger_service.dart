import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_advisor/constant/place_type.dart';
import 'package:my_advisor/utils/database_service.dart';
import 'package:my_advisor/utils/map_api.dart';
import 'package:toastification/toastification.dart';

class LocationLoggerService {
  static bool _isInitialized = false;

  static Future<void> runBackgroundTask() async {
    try {
      await _fetchAndStorePlace();
    } catch (e) {
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        title: Text(tr("error_background_title")),
        description: RichText(
          text: TextSpan(
            text: tr(
              "error_background_label",
              namedArgs: {'resp': e.toString()},
            ),
          ),
        ),
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
  }

  static Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await _fetchAndStorePlace();
  }

  static Future<void> _fetchAndStorePlace() async {
    final placeTypeDefList = PlaceType.placeTypeList;

    final places = await fetchNearbyPlacesShortRange();

    if (places != null && places.isNotEmpty) {
      for (var place in places) {
        final matchedTypes =
            placeTypeDefList
                .where((b) => place['types'].contains(b['name']))
                .toList();

        if (matchedTypes != []) {
          final placeId = place['place_id'];
          final name = place['name'];
          final address = place['vicinity'] ?? place['formatted_address'] ?? '';
          final location = place['geometry']?['location'];
          final lat = location?['lat'];
          final lng = location?['lng'];

          final photos =
              (place['photos'] as List?)
                  ?.map((p) => p['photo_reference'])
                  .toList() ??
              [];

          await appendToList("placeVisited", {
            'name': name,
            'place_id': placeId,
            'types': matchedTypes,
            'formatted_address': address,
            'lat': lat,
            'lng': lng,
            'photos': photos,
            'timestamp': DateTime.now().toIso8601String(),
            'formatted_phone_number': place['formatted_phone_number'],
            'rating': place['rating'],
            'user_ratings_total': place['user_ratings_total'],
            'website': place['website'],
          });
        }
      }
    }
  }
}
