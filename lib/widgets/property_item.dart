import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_advisor/constant/color.dart';
import 'package:my_advisor/constant/place_type.dart';
import 'package:my_advisor/utils/icon_service.dart';

class PropertyItem extends StatelessWidget {
  final Map<String, dynamic> data;

  const PropertyItem({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    final myImages = (data['my_images'] as List<dynamic>?) ?? [];
    final icon = PlaceType.placeTypeList.firstWhere(
      (b) => data['types'].any((a) => a == b['name']),
      orElse:
          () => {
            'name': 'place',
            'label': 'Place',
            'color': AppColor.darker,
            'icon': "place",
          },
    );
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              data['name'] ?? 'Nome sconosciuto',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              data['formatted_address'] ?? 'Indirizzo non disponibile',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber.shade700, size: 20),
                    Text('${data['rating'] ?? '-'}/5'),
                    const SizedBox(width: 6),
                    Text('(${data['user_ratings_total'] ?? 0} voti)'),
                  ],
                ),
                Icon(
                  getIconByName(icon['icon'] as String),
                  size: 32,
                  color: Color(icon['color'] as int),
                ),
              ],
            ),
            if (data['my_rating'] != null || data['my_comment'] != null)
              const Divider(height: 20),
            if (data['my_rating'] != null)
              Row(
                children: [
                  const Icon(Icons.person, size: 18),
                  const SizedBox(width: 4),
                  Text('La mia valutazione: ${data['my_rating']}/5'),
                ],
              ),
            if (data['my_comment'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '"${data['my_comment']}"',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            if (myImages.isNotEmpty)
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: myImages.length,
                  itemBuilder:
                      (_, i) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(myImages[i]),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
