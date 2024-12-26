import 'package:flutter/material.dart';
import 'package:wikiprathamia/data.dart';
import 'package:wikiprathamia/webview.dart';
import 'package:wikiprathamia/widgets.dart';

void main() => runApp(const MyWidget());

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int navbarindex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.green),
        home: Scaffold(
          bottomNavigationBar: BottomNavigationBar(
              currentIndex: navbarindex,
              onTap: (value) {
                setState(() {
                  navbarindex = value;
                });
              },
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.search), label: "Keyword"),
                BottomNavigationBarItem(icon: Icon(Icons.image), label: "Images"),
                BottomNavigationBarItem(icon: Icon(Icons.play_arrow), label: "Videos"),
              ]),
          appBar: AppBar(
            title: TextField(
              onChanged: (value) async {
                query = value;
                await getTitlesRaw(value);
                setState(() {});
              },
              onSubmitted: (value) async {
                query = value;
                await getTitlesRaw(value);
                await getImages(query);
                setState(() {});
              },
            ),
          ),
          body: [
            query != ""
                ? search_items(context)
                : Center(
                    child: Text("KeyNote", style: TextStyle(
                      fontSize: 25
                    ),),
                  ),
            Images(),
            WebsiteViewer(
                furl: "https://www.youtube.com/results?search_query=$query",
                js: true) //Icon(Icons.dangerous),
          ][navbarindex]),
        );
  }
}
