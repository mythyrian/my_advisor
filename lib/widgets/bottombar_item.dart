import 'package:flutter/material.dart';
import 'package:my_advisor/constant/color.dart';

class BottomBarItem extends StatelessWidget {
  const BottomBarItem(
    this.icon, {
    super.key,
    this.onTap,
    this.color = const Color(AppColor.inActiveColor),
    this.activeColor = const Color(AppColor.primary),
    this.isActive = false,
    this.isNotified = false,
  });

  final IconData icon;
  final Color color;
  final Color activeColor;
  final bool isNotified;
  final bool isActive;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color:
                    isActive
                        ? Color(AppColor.primary).withOpacity(.1)
                        : Colors.transparent,
              ),
              child: Icon(
                icon,
                size: 25,
                color: isActive ? activeColor : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
