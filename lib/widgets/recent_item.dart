import 'package:flutter/material.dart';
import 'package:my_advisor/constant/color.dart';

import 'custom_image.dart';

class RecentItem extends StatelessWidget {
  const RecentItem({super.key, required this.data});
  final data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(AppColor.shadowColor).withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: [
          CustomImage(data["image"], radius: 20),
          const SizedBox(width: 15),
          Expanded(child: _buildInfo()),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data["name"],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.place_outlined, size: 13),
            const SizedBox(width: 3),
            Expanded(
              child: Text(
                data["location"],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          data["price"],
          style: TextStyle(
            fontSize: 13,
            color: Color(AppColor.primary),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
