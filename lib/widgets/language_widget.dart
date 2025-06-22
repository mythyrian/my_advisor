import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_advisor/utils/hive_store.dart' show HiveStore;

class LanguageDropdown extends StatefulWidget {
  const LanguageDropdown({super.key});

  @override
  _LanguageDropdownState createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  late String selectedLang = 'en';
  bool isDropdownOpen = false;
  final List<String> languages = ['en', 'it', 'ro'];

@override
void initState() {
  super.initState();
  _loadSelectedLang();
}

void _loadSelectedLang() async {
  final value = HiveStore.get("app_language");
  if (mounted) {
    setState(() {
      selectedLang = value ?? 'en'; 
    });
  }
}
  void toggleDropdown() {
    setState(() {
      isDropdownOpen = !isDropdownOpen;
    });
  }

  void selectLanguage(String lang, BuildContext context) {
    context.setLocale(Locale(lang));
    Get.updateLocale(Locale(lang));
    HiveStore.put("app_language", lang);
    setState(() {
      selectedLang = lang;
      isDropdownOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: toggleDropdown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedLang,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blueGrey[700],
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.blue),
            ],
          ),
        ),
        if (isDropdownOpen)
          Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  languages.map((lang) {
                    return InkWell(
                      onTap: () => selectLanguage(lang, context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          lang,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
      ],
    );
  }
}
