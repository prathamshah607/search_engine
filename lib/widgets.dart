import 'package:flutter/material.dart';
import 'package:wikiprathamia/data.dart';
import 'package:wikiprathamia/webview.dart';

Widget search_items(BuildContext context) {
  return ListView.builder(
    itemCount: data['pages'] != null ? data['pages'].length : 0,
    itemBuilder: (BuildContext context, int index) {
      String image = data['pages']![index]['thumbnail'] != null
          ? data['pages']![index]['thumbnail']['url']
              .toString()
              .replaceFirst(RegExp(r'//'), "https://")
          : "https://static-00.iconduck.com/assets.00/search-icon-2044x2048-psdrpqwp.png";
      return ListTile(
          onTap: () async {
            await getRefs(data['pages']![index]['title']);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => URLS(),
                ));
          },
          title: Text(data['pages']![index]['title']),
          subtitle: Text(data["pages"]![index]['description'] ?? ""),
          leading: SizedBox(
            height: 30,
            width: 30,
            child: Image.network(
              image,
              fit: BoxFit.cover,
            ),
          ));
    },
  );
}

Widget Images() {
  return Expanded(
      child: GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2, // number of items in each row
      mainAxisSpacing: 1.0, // spacing between rows
      crossAxisSpacing: 1.0, // spacing between columns
    ),
    itemCount: imagedata.length,
    itemBuilder: (BuildContext context, int index) {
      return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ImageD(
                        title: imagedata[index]['title'],
                        url: imagedata[index]['fullsrc'],
                        date: imagedata[index]['timestamp'],
                      )));
        },
        child: Expanded(
          child: Image.network(
            imagedata[index]['src'],
            fit: BoxFit.fitHeight,
          ),
        ),
      );
    },
  ));
}

class URLS extends StatefulWidget {
  const URLS({super.key});

  @override
  State<URLS> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<URLS> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
          itemCount: urls.length + 1,
          itemBuilder: (BuildContext context, int count) {
            int index = count - 1;
            bool insecure = index >= 0
                ? urls[index].values.first.toString().contains("http://")
                : false;
            return index > -1
                ? Card(
                    child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WebsiteViewer(
                                        furl:
                                            urls[index].values.first.toString(),
                                        js: false)));
                          },
                          //leading: Image.network(
                          //"https://www.google.com/s2/favicons?domain_url=${urls[index].values.first}",
                          //),
                          title: Text(
                            urls[index].keys.first ?? urls[index].values.first,
                            style: const TextStyle(
                                color: Colors.blueGrey, fontSize: 20),
                          ),
                          subtitle: Text(
                            urls[index].values.first,
                            style: TextStyle(
                                color: insecure ? Colors.red : Colors.green,
                                fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                  )
                : DescriptionWidget();
          }),
    );
  }
}

class ImageD extends StatelessWidget {
  final String url;
  final String title;
  final String date;
  const ImageD(
      {super.key, required this.title, required this.url, required this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title.replaceAll("File:", "")),
        actions: [
          Text(date.split("T").first),
        ],
      ),
      body: InteractiveViewer(
          minScale: 0.001,
          maxScale: 10,
          child: Image.network(
            url,
            fit: BoxFit.fitHeight,
          )),
    );
  }
}

Widget DescriptionWidget (){
  return Container();
}