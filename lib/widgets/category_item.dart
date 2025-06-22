import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_advisor/constant/color.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    super.key,
    required this.data,
    this.selected = false,
    this.onTap,
  });

  final data;
  final bool selected;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
        margin: EdgeInsets.only(right: 10),
        width: 90,
        height: 40,
        decoration: BoxDecoration(
          color: selected ? Color(AppColor.primary) : Color(AppColor.cardColor),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Color(AppColor.shadowColor).withOpacity(0.1),
              spreadRadius: .5,
              blurRadius: .5,
              offset: Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Center(
          child: Text(
            tr(data["name"]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: selected ? Colors.white : Color(AppColor.darker),
            ),
          ),
        ),
      ),
    );
  }
}
