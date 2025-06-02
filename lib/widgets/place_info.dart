import 'package:flutter/material.dart';
import 'package:my_advisor/utils/map_api.dart';

class PlaceInfo extends StatefulWidget {
  final Map<String, dynamic> placeData;
  final ScrollController scrollController;

  const PlaceInfo({
    super.key,
    required this.placeData,
    required this.scrollController,
  });

  @override
  State<PlaceInfo> createState() => _PlaceInfoState();
}

class _PlaceInfoState extends State<PlaceInfo> {

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
            Text('${place['rating'] ?? 'N/A'}'),
            const SizedBox(width: 8),
            Text("(${place['user_ratings_total'] ?? 0} recensioni)"),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          place['formatted_address'] ?? '',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Text("📞 ${place['formatted_phone_number'] ?? 'Non disponibile'}"),
        const SizedBox(height: 4),
        Text("🌐 ${place['website'] ?? 'Non disponibile'}"),
        const SizedBox(height: 12),

        images.isNotEmpty
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
            : const SizedBox(
                height: 100,
                child: Center(child: Text("No online image available")),
              ),

        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                final url = place['url'];
                // Usa url_launcher per aprire Maps
              },
              icon: const Icon(Icons.directions),
              label: const Text("Indicazioni"),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Usa url_launcher per chiamare
              },
              icon: const Icon(Icons.call),
              label: const Text("Chiama"),
            ),
          ],
        ),
      ],
    );
  }
}
