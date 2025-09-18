import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_playground/ui/navigation_bar/bottom_nav_bar_item.dart';
import 'package:liquid_glass_playground/ui/navigation_bar/custom_nav_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final controller = PageController();
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: CupertinoColors.extraLightBackgroundGray,
        title: const Text("Liquid Glass Style NavBar"),
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller,
        onPageChanged: (value) => setState(() => index = value),
        children: <Widget>[
          _ColoredBoxPage(title: "Home"),
          _ColoredBoxPage(title: "Search"),
          _ColoredBoxPage(title: "Chat"),
          _ColoredBoxPage(title: "News"),
          _ColoredBoxPage(title: "Profile"),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: CustomBottomNavBar(
          currentIndex: index,
          onTap: (value) {
            setState(() {
              index = value;
              controller.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              );
            });
          },
          children: [
            BottomNavBarItem(title: "Home", icon: Icons.home_outlined),
            BottomNavBarItem(title: "Search", icon: Icons.search_rounded),
            BottomNavBarItem(title: 'Chat', icon: Icons.chat_bubble_outline),
            BottomNavBarItem(title: "News", icon: Icons.newspaper),
            BottomNavBarItem(title: "Profile", icon: Icons.person_outline),
          ],
        ),
      ),
    );
  }
}

class _ColoredBoxPage extends StatelessWidget {
  final String title;

  const _ColoredBoxPage({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    return ColoredBox(
      color: CupertinoColors.black,
      child: Align(
        alignment: Alignment.center,
        child: Text(title, style: textStyle?.copyWith(color: Colors.white)),
      ),
    );
  }
}
