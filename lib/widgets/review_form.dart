import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_advisor/constant/color.dart';
import 'package:my_advisor/utils/database_service.dart';

class ReviewForm extends StatefulWidget {
  const ReviewForm({super.key, required this.place});
  final Map<String, dynamic> place;

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  double rating = 3;
  final TextEditingController _reviewController = TextEditingController();
  List<File> selectedImages = [];

  late Map<String, dynamic> place;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    setState(() {
      selectedImages = pickedFiles.map((file) => File(file.path)).toList();
    });
    }
  
  @override
  void initState() {
    super.initState();
    place = widget.place;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Scrivi una recensione",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${rating.toInt()} ⭐"),
              Expanded(
                child: Slider(
                  value: rating,
                  onChanged: (value) => setState(() => rating = value),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: rating.toStringAsFixed(0),
                  activeColor: Color(AppColor.primary),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          TextField(
            controller: _reviewController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "Scrivi qui la tua esperienza...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 20),
          SizedBox(
            height: 110,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    selectedImages
                        .map(
                          (img) => Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                img,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),

          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.add_a_photo),
            label: const Text("Aggiungi immagini"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppColor.sky),
            ),
          ),

          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  "Discard",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  place["my_rating"] = rating;
                  place["my_comment"] = _reviewController.text;
                  place["my_images"] = selectedImages.map((f) => f.path).toList();
                  await appendToList("placeReviewed", place);
                  Navigator.of(context).pop();
                },
                child: const Text("Save"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
