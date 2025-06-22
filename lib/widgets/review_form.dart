import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
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
  int rating = 3;
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
          Text(
            tr("write_a_review"),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${rating.toInt()} ⭐"),
              Expanded(
                child: Slider(
                  value: rating.toDouble(),
                  onChanged: (value) => setState(() => rating = value.round()),
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
              hintText: tr("write"),
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
            label: Text(tr("add_images")),
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
                child: Text(
                  tr("discard"),
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  place["my_rating"] = rating;
                  place["my_comment"] = _reviewController.text;
                  place["my_images"] =
                      selectedImages.map((f) => f.path).toList();
                  await appendToList("placeReviewed", place);
                  Navigator.of(context).pop();
                },
                child: Text(tr("save")),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
