import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_advisor/constant/color.dart';
import 'package:my_advisor/utils/hive_store.dart';
import 'package:my_advisor/widgets/custom_textbox.dart';
import 'package:my_advisor/widgets/icon_box.dart';

class MySearchBar extends StatefulWidget {
  final bool showFilter;
  final Function search;

  const MySearchBar({
    super.key,
    required this.showFilter,
    required this.search,
  });

  @override
  _MySearchBarState createState() => _MySearchBarState();
}

class _MySearchBarState extends State<MySearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    setUp();
  }

  Future<void> setUp() async {
    await HiveStore.put("search_keyword", " ");
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            Expanded(
              child: CustomTextBox(
                hint: tr("search"),
                prefix: Icon(Icons.search, color: Colors.grey),
                controller: _controller,
                onSubmitted: (value) {
                  HiveStore.put("search_keyword", value.trim());
                  widget.search(value);
                },
              ),
            ),
            const SizedBox(width: 10),
            widget.showFilter
                ? IconBox(
                  bgColor: Color(AppColor.secondary),
                  radius: 10,
                  child: Icon(Icons.filter_list_rounded, color: Colors.white),
                )
                : Container(),
          ],
        ),
      ),
    );
  }
}
