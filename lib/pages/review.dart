import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:my_advisor/constant/color.dart';
import 'package:my_advisor/constant/place_type.dart';
import 'package:my_advisor/utils/data.dart';
import 'package:my_advisor/utils/database_service.dart';
import 'package:my_advisor/widgets/category_item.dart';
import 'package:my_advisor/widgets/place_type_label_item.dart';
import 'package:my_advisor/widgets/my_search_bar.dart';
import 'package:my_advisor/widgets/property_item.dart';
import 'package:my_advisor/widgets/recent_item.dart';
import 'package:my_advisor/widgets/recommend_item.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Color(AppColor.appBgColor),
          pinned: true,
          snap: true,
          floating: true,
          title: MySearchBar(showFilter: false, search: () => {}),
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
            child: Text(
              "Reviewed",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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

  String _selectedCategory = "all";

  Widget _buildCategories() {
    final data = PlaceType.placeTypeList;
    List<Widget> lists = List.generate(
      data.length,
      (index) => PlaceTypeLabelItem(
        data: data[index],
        color: Color(data[index]['color'] as int),
        selected: data[index]["name"] == _selectedCategory,
        onTap: () {
          setState(() {
            _selectedCategory = data[index]["name"] as String;
          });
        },
      ),
    );

    Widget allItem = PlaceTypeLabelItem(
      data: {
        'name': 'all',
        'label': 'All',
        'color': AppColor.darker,
        'icon': "all",
      },
      color: Color(AppColor.darker),
      selected: _selectedCategory == "all",
      onTap: () {
        setState(() {
          _selectedCategory = "all";
        });
      },
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(bottom: 5, left: 15),
      child: Row(children: [allItem, ...lists]),
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
}
