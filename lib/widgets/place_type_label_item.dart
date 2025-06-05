import 'package:flutter/material.dart';
import 'package:my_advisor/constant/color.dart';
import 'package:my_advisor/utils/icon_service.dart';

class PlaceTypeLabelItem extends StatelessWidget {
  const PlaceTypeLabelItem({
    super.key,
    required this.data,
    this.bgColor = Colors.white,
    this.color = const Color(AppColor.primary),
    this.selected = false,
    this.onTap,
  });

  final data;
  final Color bgColor;
  final Color color;
  final bool selected;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        height: 110,
        margin: EdgeInsets.only(right: 15),
        padding: EdgeInsets.fromLTRB(5, 10, 5, 0),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(.3),
              ),
              child: Icon(
                getIconByName(data['icon'] as String),
                size: 16,
                color: Color(data['color']),
              ),
            ),
            Text(
              data["label"],
              maxLines: 1,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            Visibility(
              visible: selected,
              child: Container(
                width: double.infinity,
                height: 2,
                decoration: BoxDecoration(color: Color(AppColor.primary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
