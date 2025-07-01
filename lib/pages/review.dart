import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_advisor/constant/color.dart';
import 'package:my_advisor/constant/place_type.dart';
import 'package:my_advisor/utils/common_function.dart';
import 'package:my_advisor/utils/database_service.dart';
import 'package:my_advisor/widgets/place_type_label_item.dart';
import 'package:my_advisor/widgets/my_search_bar.dart';
import 'package:my_advisor/widgets/property_item.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  String searchValue = "";

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Color(AppColor.appBgColor),
          pinned: true,
          snap: true,
          floating: true,
          title: MySearchBar(
            showFilter: false,
            search:
                (value) => {
                  setState(() {
                    searchValue = value;
                  }),
                },
          ),
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
              tr("reviewed"),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 20),
          FutureBuilder<Widget>(
            future: _buildReviewed(),
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

  Future<Widget> _buildReviewed() async {
    final places = await readValue("placeReviewed") as List<dynamic>;
    late List<dynamic> filterPlaces;

    if (_selectedCategory == "all") {
      filterPlaces = places;
    } else {
      filterPlaces =
          places.where((place) {
            final types = List<String>.from(place["types"]);
            return types.contains(_selectedCategory);
          }).toList();
    }

    if (searchValue != "") {
      filterPlaces = filterListByText(filterPlaces, searchValue);
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height * 0.6,
        enlargeCenterPage: true,
        disableCenter: true,
        viewportFraction: .55,
        enableInfiniteScroll: false,
        scrollDirection: Axis.vertical,
      ),
      items: List.generate(
        filterPlaces.length,
        (index) => PropertyItem(
          data: filterPlaces[index],
          onConfirm: () async {
            await deleteValueAtIndex('placeReviewed', index);
            setState(() {
              filterPlaces.removeAt(index);
            });
          },
        ),
      ),
    );
  }
}
