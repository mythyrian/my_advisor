import 'package:flutter/material.dart';
import 'package:my_advisor/constant/color.dart';
import 'package:my_advisor/utils/hive_store.dart';
import 'package:my_advisor/utils/icon_service.dart';

class FilterDialogContent extends StatefulWidget {
  const FilterDialogContent({super.key});

  @override
  State<FilterDialogContent> createState() => _FilterDialogContentState();
}

class _FilterDialogContentState extends State<FilterDialogContent> {
  RangeValues _priceRange = const RangeValues(1, 5);

  late List<dynamic> placeTypeWithCheck;

  @override
  void initState() {
    super.initState();
    placeTypeWithCheck = HiveStore.get("place_type_pref");
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
                    Text("${_priceRange.start.round()}"),
                    Icon(Icons.star, size: 24, color: Color(AppColor.yellow)),
                  ],
                ),
                Row(
                  children: [
                    Text("${_priceRange.end.round()}"),
                    Icon(Icons.star, size: 24, color: Color(AppColor.yellow)),
                  ],
                ),
              ],
            ),
            RangeSlider(
              values: _priceRange,
              min: 1,
              max: 5,
              divisions: 4,
              labels: RangeLabels(
                _priceRange.start.toStringAsFixed(0),
                _priceRange.end.toStringAsFixed(0),
              ),
              activeColor: Color(AppColor.primary),
              onChanged: (values) {
                setState(() {
                  _priceRange = values;
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
                      selected: type['checked'] as bool,
                      onSelected: (selected) {
                        setState(() {
                          type['checked'] = selected;
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
                    HiveStore.put("place_type_pref", placeTypeWithCheck);
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
