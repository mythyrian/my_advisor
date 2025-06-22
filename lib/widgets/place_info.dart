import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_advisor/utils/database_service.dart';
import 'package:my_advisor/utils/map_api.dart';
import 'package:my_advisor/widgets/broker_item.dart';
import 'package:my_advisor/widgets/review_form.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceInfo extends StatefulWidget {
  final Map<String, dynamic> placeData;
  final ScrollController scrollController;
  final String mode;

  const PlaceInfo({
    super.key,
    required this.placeData,
    required this.scrollController,
    required this.mode,
  });

  @override
  State<PlaceInfo> createState() => _PlaceInfoState();
}

class _PlaceInfoState extends State<PlaceInfo> {
  @override
  initState() {
    super.initState();

    if (widget.mode == "home") {
      final placeId = widget.placeData['place_id'];
      final name = widget.placeData['name'];
      final address =
          widget.placeData['vicinity'] ??
          widget.placeData['formatted_address'] ??
          '';
      final location = widget.placeData['geometry']?['location'];
      final lat = location?['lat'];
      final lng = location?['lng'];

      final photos =
          (widget.placeData['photos'] as List?)
              ?.map((p) => p['photo_reference'])
              .toList() ??
          [];

      appendToList("placeVisited", {
        'name': name,
        'place_id': placeId,
        'types': widget.placeData['types'],
        'formatted_address': address,
        'lat': lat,
        'lng': lng,
        'photos': photos,
        'timestamp': DateTime.now().toIso8601String(),
        'formatted_phone_number': widget.placeData['formatted_phone_number'],
        'rating': widget.placeData['rating'],
        'user_ratings_total': widget.placeData['user_ratings_total'],
        'website': widget.placeData['website'],
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.placeData;
    final images = place['photos'] ?? [];

    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          place['name'] ?? '',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.orange, size: 20),
            const SizedBox(width: 4),
            Text(tr("n_a")),
            const SizedBox(width: 8),
            Text(
              tr(
                'user_ratings_total',
                namedArgs: {'val': place['user_ratings_total'].toString()},
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          place['formatted_address'] ?? '',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Text("📞 ${place['formatted_phone_number'] ?? tr('not_available')}"),
        const SizedBox(height: 4),
        link(place),
        const SizedBox(height: 12),

        widget.mode == "history"
            ? Container()
            : images.isNotEmpty
            ? SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final ref = images[index]['photo_reference'];
                  final url = getImageUrl(ref);

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      width: 120,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            )
            : SizedBox(
              height: 100,
              child: Center(child: Text(tr("no_online_image_available"))),
            ),
        widget.mode == "history" ? Container() : const SizedBox(height: 10),
        widget.mode == "history"
            ? Container()
            : SizedBox(height: 150, child: _buildReviewers()),
        const SizedBox(height: 20),
        widget.mode == "history"
            ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _openReviewForm();
                  },
                  icon: const Icon(Icons.edit_note),
                  label: Text(tr("add_review")),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await deleteValueInList("placeVisited", place['place_id']);
                  },
                  icon: const Icon(Icons.delete),
                  label: Text(tr("not_been_here")),
                ),
              ],
            )
            : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await openPlaceOnGoogleMaps(place['place_id']);
                  },
                  icon: const Icon(Icons.directions),
                  label: Text(tr("directions")),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    place['formatted_phone_number'] != null
                        ? composePhoneNumber(place['formatted_phone_number'])
                        : () => {};
                  },
                  icon: const Icon(Icons.call),
                  label: Text(tr("call")),
                ),
              ],
            ),
      ],
    );
  }

  void _openReviewForm() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ReviewForm(place: widget.placeData),
        );
      },
    );
  }

  Future<void> openWebsite(String urlStr) async {
    final Uri url = Uri.parse(urlStr);
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Widget link(place) {
    final String? website = place['website'];
    if (website != null && website.isNotEmpty) {
      return InkWell(
        onTap: () => openWebsite(place['website']),
        child: Text(
          "🌐 ${place['website']}",
          style: TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      );
    } else {
      return Text("🌐 ${tr("not_available")}");
    }
  }

  Future<void> composePhoneNumber(String phoneNumber) async {
    final cleanedNumber = phoneNumber.replaceAll(' ', ''); // rimuove spazi
    final Uri uri = Uri(scheme: 'tel', path: cleanedNumber);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildReviewers() {
    if (widget.placeData["reviews"] != null) {
      final reviews = widget.placeData["reviews"] as List;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: reviews.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return ReviewItem(data: reviews[index]);
            },
          ),
        ),
      );
    }

    return Container();
  }
}
