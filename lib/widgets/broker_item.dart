import 'package:flutter/material.dart';
import 'package:my_advisor/constant/color.dart';

class ReviewItem extends StatelessWidget {
  const ReviewItem({super.key, required this.data});

  final data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Color(AppColor.shadowColor).withOpacity(0.1),
            spreadRadius: .5,
            blurRadius: 1,
            offset: Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfile(),
          const SizedBox(height: 10),
          SizedBox(
            height: 60,
            width: 150,
            child: Text(
              data["text"],
              style: TextStyle(height: 1.5, color: Color(AppColor.darker)),
            ),
          ),
          const SizedBox(height: 10),
          _buildRate(data["rating"]),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return Row(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data["author_name"],
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 10),
          Text(
            data["relative_time_description"],
            style: TextStyle(height: 1.5, color: Color(AppColor.darker)),
          ),
          ],
        ),
      ],
    );
  }

Widget _buildRate(int rating) {
  return Row(
    children: List.generate(5, (index) {
      return Icon(
        index < rating ? Icons.star : Icons.star_outline,
        size: 16,
        color: Color(AppColor.yellow),
      );
    }),
  );
}
}
