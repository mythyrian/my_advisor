import 'package:flutter/material.dart';

IconData getIconByName(String name) {
  switch (name) {
    case 'restaurant':
      return Icons.restaurant;
    case 'local_bar':
      return Icons.local_bar;
    case 'local_cafe':
      return Icons.local_cafe;
    case 'park':
      return Icons.park;
    case 'museum':
      return Icons.museum;
    case 'movie':
      return Icons.movie;
    case 'attractions':
      return Icons.attractions;
    case 'theaters':
      return Icons.theaters;
    case 'all':
      return Icons.all_inclusive_outlined;
    default:
      return Icons.place;
  }
}
