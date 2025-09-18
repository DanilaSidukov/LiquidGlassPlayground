import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_playground/ui/navigation_bar/bottom_navigation_bar_item.dart';
import 'package:liquid_glass_playground/ui/navigation_bar/custom_ios_navigation_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Liquid Glass Style NavBar"),
      ),
      body: PageView(
        physics: const ClampingScrollPhysics(),
        controller: controller,
        onPageChanged: (value) => setState(() => index = value),
        children: const <Widget>[
          ColoredBox(color: CupertinoColors.black),
          ColoredBox(color: CupertinoColors.systemGrey),
          ColoredBox(color: CupertinoColors.separator),
          ColoredBox(color: CupertinoColors.inactiveGray),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: BottomNavBar(
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
            BottomNavBarItem(title: "Profile", icon: Icons.person_outline),
          ],
        ),
      ),
    );
  }
}
