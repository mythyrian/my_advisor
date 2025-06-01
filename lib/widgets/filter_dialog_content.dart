import 'package:flutter/material.dart';
import 'package:my_advisor/constant/color.dart';
import 'package:my_advisor/constant/place_type.dart';
import 'package:my_advisor/utils/hive_store.dart';
import 'package:my_advisor/utils/icon_service.dart';

class FilterDialogContent extends StatefulWidget {
  const FilterDialogContent({super.key});

  @override
  State<FilterDialogContent> createState() => _FilterDialogContentState();
}

class _FilterDialogContentState extends State<FilterDialogContent> {
  late RangeValues prefRange;
  late Map<dynamic, dynamic> placeTypeRef;
  late List<dynamic> placeTypeWithCheck;

  @override
  void initState() {
    super.initState();
    final originalPlaceTypePref = HiveStore.get("place_type_pref");
    placeTypeRef = originalPlaceTypePref;
    placeTypeWithCheck = PlaceType.placeTypeList;
    final rawRange = HiveStore.get("range_review_pref");
    final min = (rawRange?["min"] ?? 1).toDouble();
    final max = (rawRange?["max"] ?? 5).toDouble();
    prefRange = RangeValues(min, max);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Filters",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            // valutazione
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text("${prefRange.start.round()}"),
                    Icon(Icons.star, size: 24, color: Color(AppColor.yellow)),
                  ],
                ),
                Row(
                  children: [
                    Text("${prefRange.end.round()}"),
                    Icon(Icons.star, size: 24, color: Color(AppColor.yellow)),
                  ],
                ),
              ],
            ),
            RangeSlider(
              values: prefRange,
              min: 1,
              max: 5,
              divisions: 4,
              labels: RangeLabels(
                prefRange.start.toStringAsFixed(0),
                prefRange.end.toStringAsFixed(0),
              ),
              activeColor: Color(AppColor.primary),
              onChanged: (values) {
                setState(() {
                  prefRange = values;
                });
              },
            ),

            // tipo
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children:
                  placeTypeWithCheck.map((type) {
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(type['label'] as String),
                          const SizedBox(width: 6),
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 12,
                            child: Icon(
                              getIconByName(type['icon'] as String),
                              size: 16,
                              color: Color(type['color']),
                            ),
                          ),
                        ],
                      ),
                      selected: type['name'] == placeTypeRef["name"],
                      onSelected: (selected) {
                        setState(() {
                          placeTypeRef = type;
                        });
                      },
                      selectedColor: Color(AppColor.primary),
                      backgroundColor: Colors.grey.shade200,
                      shape: StadiumBorder(),
                    );
                  }).toList(),
            ),

            // Pulsanti
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    "Discard",
                    style: TextStyle(color: Color(AppColor.primary)),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(AppColor.sky),
                  ),
                  onPressed: () {
                    HiveStore.put("place_type_pref", placeTypeRef);
                    HiveStore.put("range_review_pref", {
                      "min": prefRange.start,
                      "max": prefRange.end,
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text("Apply"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
