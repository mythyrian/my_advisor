import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_advisor/utils/data.dart';
import 'package:my_advisor/utils/database_service.dart';
import 'package:my_advisor/widgets/category_item.dart';
import 'package:my_advisor/widgets/map.dart';
import 'package:my_advisor/widgets/my_search_bar.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState(); //in ogni pages si crea il statefull widget
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MySearchBar(showFilter: false, search: () => {}),
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        _buildCategories(),
        const SizedBox(height: 20),
        FutureBuilder<Widget>(
          future: _buildHistoryMap(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text(tr("error_loading")));
            } else {
              return snapshot.data!;
            }
          },
        ),
      ],
    );
  }

  String _selectedCategory = categories[0]["name"];

  Widget _buildCategories() {
    List<Widget> lists = List.generate(
      categories.length,
      (index) => CategoryItem(
        data: categories[index],
        selected: categories[index]["name"] == _selectedCategory,
        onTap: () {
          setState(() {
            _selectedCategory = categories[index]["name"];
          });
        },
      ),
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(bottom: 5, left: 15),
      child: Row(children: lists),
    );
  }

  Future<Widget> _buildHistoryMap() async {
    final places = await readValue("placeVisited") as List<dynamic>;
    final filterListPlaces = filterAndSortPlaces(places, _selectedCategory);
    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: screenHeight - 230,
      child: MyMap(mode: "history", listHistoryPlaces: filterListPlaces),
    );
  }

  List filterAndSortPlaces(List<dynamic> placeList, String selectedTimeRange) {
    final now = DateTime.now();
    DateTime startDate;

    switch (selectedTimeRange) {
      case "today":
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case "yesterday":
        final yesterday = now.subtract(Duration(days: 1));
        startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
        break;
      case "week":
        startDate = now.subtract(Duration(days: 7));
        break;
      case "month":
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      default:
        return placeList..sort((a, b) {
          final aTime = DateTime.parse(a["timestamp"]);
          final bTime = DateTime.parse(b["timestamp"]);
          return aTime.compareTo(bTime);
        });
    }

    DateTime endDate;
    if (selectedTimeRange == "yesterday") {
      endDate = DateTime(now.year, now.month, now.day); // oggi, inizio
    } else {
      endDate = now;
    }

    final filtered =
        placeList.where((place) {
          final ts = DateTime.tryParse(place["timestamp"] ?? "");
          return ts != null && ts.isAfter(startDate) && ts.isBefore(endDate);
        }).toList();

    filtered.sort((a, b) {
      final aTime = DateTime.parse(a["timestamp"]);
      final bTime = DateTime.parse(b["timestamp"]);
      return aTime.compareTo(bTime);
    });

    return filtered;
  }
}
