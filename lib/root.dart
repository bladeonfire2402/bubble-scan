import "package:enhance/screen/camera_screen/index.dart";
import "package:enhance/screen/test.dart";
import "package:enhance/screen/upload_screen/index.dart";
import "package:enhance/widgets/my_bottom_nav/index.dart";
import "package:enhance/interface/index.dart";
import "package:flutter/material.dart";

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  int screenIndex = 0;

  void changeScreen(int i) {
    setState(() => screenIndex = i);
  }

  final List<MenuItem> screens = [
    MenuItem(icon: Icons.inventory, widget: UploadScreen()),
    MenuItem(icon: Icons.scanner, widget: CameraScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // theme: eduLightTheme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Row(
            spacing: 5,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.asset("assets/images/logo.png", width: 30),
              ),
              Text(
                "Omr ",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        body: screens[screenIndex].widget,
        // Tuỳ vào API của MyBottomNav — nếu cần, truyền menus & currentIndex
        bottomNavigationBar: MyBottomNav(
          tabs: screens,
          changeScreen: (i) => changeScreen(i),
          // ví dụ:
        ),
      ),
    );
  }
}
