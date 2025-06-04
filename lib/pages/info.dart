import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:my_advisor/constant/color.dart';
import 'package:my_advisor/utils/data.dart';
import 'package:my_advisor/utils/database_service.dart';
import 'package:my_advisor/widgets/category_item.dart';
import 'package:my_advisor/widgets/my_search_bar.dart';
import 'package:my_advisor/widgets/property_item.dart';
import 'package:my_advisor/widgets/recent_item.dart';
import 'package:my_advisor/widgets/recommend_item.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Color(AppColor.appBgColor),
          pinned: true,
          snap: true,
          floating: true,
          title: MySearchBar(showFilter: true, search: () => {},),
        ),
        SliverToBoxAdapter(child: _buildBody()),
      ],
    );
  }

 Widget _buildBody() {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        _buildCategories(),
        const SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Popular",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                "See all",
                style: TextStyle(fontSize: 14, color: Color(AppColor.darker)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FutureBuilder<Widget>(
          future: _buildPopulars(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Errore nel caricamento'));
            } else {
              return snapshot.data!;
            }
          },
        ),
        // … il resto invariato
      ],
    ),
  );
}


  int _selectedCategory = 0;
  Widget _buildCategories() {
    List<Widget> lists = List.generate(
      categories.length,
      (index) => CategoryItem(
        data: categories[index],
        selected: index == _selectedCategory,
        onTap: () {
          setState(() {
            _selectedCategory = index;
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

  Future<Widget> _buildPopulars() async {

    final places = await readValue("placeVisited") as List<dynamic>;

    return CarouselSlider(
      options: CarouselOptions(
        height: 240,
        enlargeCenterPage: true,
        disableCenter: true,
        viewportFraction: .8,
      ),
      items: List.generate(
        places.length,
        (index) => PropertyItem(data: places[index]),
      ),
    );
  }

  Widget _buildRecommended() {
    List<Widget> lists = List.generate(
      recommended.length,
      (index) => RecommendItem(data: recommended[index]),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(bottom: 5, left: 15),
      child: Row(children: lists),
    );
  }

  Widget _buildRecent() {
    List<Widget> lists = List.generate(
      recents.length,
      (index) => RecentItem(data: recents[index]),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(bottom: 5, left: 15),
      child: Row(children: lists),
    );
  }
}
