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
                  builder: (context) => const URLS(),
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
                        snippet: imagedata[index]['snippet'],
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
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                await getImages(title);
                setState(() {});
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Scaffold(
                              appBar: AppBar(
                                title: Text("Images for $title"),
                              ),
                              body: Images(),
                            )));
              },
              icon: const Icon(Icons.image))
        ],
      ),
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
                        child: SearchTile(
                            urls[index].keys.first ?? urls[index].values.first,
                            urls[index].values.first,
                            context,
                            false,
                            insecure)))
                : DescriptionWidget(context, description);
          }),
    );
  }
}

class ImageD extends StatelessWidget {
  final String url;
  final String title;
  final String date;
  final String snippet;
  const ImageD(
      {super.key,
      required this.title,
      required this.url,
      required this.date,
      required this.snippet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title.replaceAll("File:", "")),
        actions: [
          Text(date.split("T").first),
        ],
      ),
      body: Column(
        children: [
          InteractiveViewer(
              minScale: 0.001,
              maxScale: 10,
              child: Container(
                child: Image.network(
                  url,
                  fit: BoxFit.fitHeight,
                ),
              )),
          const Divider(),
          Text(snippet)
        ],
      ),
    );
  }
}

Widget DescriptionWidget(BuildContext context, Map description) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description['title'] ?? "${description['description']}",
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
          Text(
            "${description['description']}",
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 5,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: description['images']?.length,
              itemBuilder: (context, index) {
                return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ImageD(
                                    title: description['titles'][index],
                                    url: description['images'][index],
                                    date: "",
                                    snippet: "",
                                  )));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Image.network(description['images'][index]),
                    ));
              },
            ),
          ),
          const Divider(),
          Text("${description['extract']}"),
          SearchTile(description['title'], description['source'], context, true, false)
        ],
      ),
    ),
  );
}

Widget SearchTile(
    String title, String url, BuildContext context, bool js, bool insecure) {
  return ListTile(
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebsiteViewer(furl: url, js: js)));
    },
    //leading: Image.network("https://t1.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=$url&size=16"),
    title: Text(
      title,
      style: const TextStyle(color: Colors.blueGrey, fontSize: 20),
    ),
    subtitle: Text(
      url,
      style:
          TextStyle(color: insecure ? Colors.red : Colors.green, fontSize: 12),
      overflow: TextOverflow.ellipsis,
    ),
  );
}

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Current Affairs and News")),
      body: ListView.builder(
        itemCount: newsitems.length,
        itemBuilder: (BuildContext context, int count) {
        return DescriptionWidget(context, newsitems[count]);
      }),
    );
  }
}
