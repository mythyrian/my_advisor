import 'package:my_advisor/constant/color.dart';

class PlaceType {
  static const placeTypeList = [
    {
      'name': 'restaurant',
      'label': 'Restaurant',
      'color': AppColor.yellow,
      'icon': "restaurant",
    },
    {
      'name': 'bar',
      'label': 'Bar',
      'color': AppColor.green,
      'icon': "local_bar",
    },
    {
      'name': 'cafe',
      'label': 'Café',
      'color': AppColor.pink,
      'icon': "local_cafe",
    },
    {'name': 'park', 'label': 'Park', 'color': AppColor.purple, 'icon': "park"},
    {
      'name': 'museum',
      'label': 'Museum',
      'color': AppColor.red,
      'icon': "museum",
    },
    {
      'name': 'movie_theater',
      'label': 'Cinema',
      'color': AppColor.orange,
      'icon': "movie",
    },
    {
      'name': 'amusement_park',
      'label': 'Amusement',
      'color': AppColor.blue,
      'icon': "attractions",
    },
    {
      'name': 'theater',
      'label': 'Theater',
      'color': AppColor.mainColor,
      'icon': "theaters",
    },
  ];

  static int? getColorByName(String name) {
    final type = placeTypeList.firstWhere(
      (element) => element['name'] == name,
      orElse: () => {},
    );
    return type['color'] as int;
  }
}
