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

  bool check = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        theme: ThemeData(
        ),
        home: DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                title: TextField(
                  onChanged: (value) async {
                    check = false;
                    query = value;
                    await getTitlesRaw(value);
                    setState(() {});
                  },
                  onSubmitted: (value) async {
                    query = value;
                    await getTitlesRaw(value);
                    await getImages(query);
                    check = (data['pages'][0]['title'].toLowerCase() == query.toLowerCase());
                    if(check) await getRefs(data['pages'][0]['title']);
                    setState(() {});
                  },
                ),
                bottom: TabBar(
                    onTap: (c) async {
                      if (c == 1) {
                        await getImages(query);
                        setState(() {});
                      }
                    },
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.search),
                      ),
                      Tab(
                        icon: Icon(Icons.image),
                      ),
                      Tab(
                        icon: Icon(Icons.ondemand_video_sharp),
                      ),
                    ]),
              ),
              body: TabBarView(children: [
                check ? URLS() : search_items(context),
                Images(),
                WebsiteViewer(furl: "https://www.youtube.com/results?search_query=$query", js: true)//Icon(Icons.dangerous),
              ]),
            )));
  }
}
