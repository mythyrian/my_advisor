import 'package:flutter/material.dart';
import 'package:my_advisor/constant/color.dart';

final circleAvatarDefault = Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Color(AppColor.darker), width: 3),
        ),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 40,
          child: Icon(
           Icons.place,
            size: 40,
            color: Color(
              AppColor.darker
            ),
          ),
        ),
      );