import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:enhance/interface/index.dart';
import 'package:flutter/material.dart';

class MyBottomNav extends StatefulWidget {
  const MyBottomNav({
    super.key,
    required this.tabs,
    required this.changeScreen,
  });

  final List<MenuItem> tabs;
  final ValueChanged<int> changeScreen; // ✅ callback có int

  @override
  State<MyBottomNav> createState() => _MyBottomNavState();
}

class _MyBottomNavState extends State<MyBottomNav> {
  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      color: Color(0xFFF7F7FA),
      onTap: (value) {
        widget.changeScreen(value);
      },
      backgroundColor: Colors.blue,
      items: [
        ...widget.tabs.map((item) {
          return Icon(item.icon);
        }),
      ],
    );
  }
}
