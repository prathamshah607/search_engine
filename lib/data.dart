import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

Map<dynamic, dynamic> data = {};
String query = "";
List<Map> imagedata = [];
List<Map> urls = [];
Map description = {};
String title = "";

Future getTitlesRaw(query) async {
  Map<dynamic, dynamic> mydata = {"lmao": "lmao"};
  http.Response mystring = await http.get(Uri.parse(
      "https://api.wikimedia.org/core/v1/wikipedia/en/search/title?q=$query&limit=10"));
  mydata = jsonDecode(mystring.body);
  data = mydata;
}

Future getImages(String query) async {
  Map<dynamic, dynamic> imagest = {};
  http.Response mystring = await http.get(Uri.parse(
      "https://commons.wikimedia.org/w/api.php?action=query&format=json&uselang=en&generator=search&gsrsearch=filetype%3Abitmap%7Cdrawing%20$query&gsrlimit=40&gsroffset=0&gsrinfo=totalhits%7Csuggestion&gsrprop=size%7Cwordcount%7Ctimestamp%7Csnippet&prop=info%7Cimageinfo%7Centityterms&inprop=url&gsrnamespace=6&iiprop=url%7Csize%7Cmime&iiurlheight=180&wbetterms=label"));
  imagest = jsonDecode(mystring.body)['query']['pages'] ?? {};
  imagedata = [];
  for (var c in imagest.keys) {
    imagedata.add({
      "src": imagest[c]["imageinfo"][0]['thumburl'] ?? "",
      "fullsrc": imagest[c]["imageinfo"][0]['url'] ?? "",
      "title": imagest[c]["title"] ?? "",
      "timestamp": imagest[c]["touched"] ?? "",
    });
  }
}

bool valid(String url, String title) {
  bool isvalid = true;
  if (url.startsWith("#") ||
      title.toLowerCase() == "the original" ||
      url == "null" ||
      url == "" ||
      url.startsWith("/") ||
      url.contains("wiki") ||
      url.contains("//doi.org") ||
      url.contains("//ui.adsabs.harvard.edu") ||
      url.contains("books.google.com/books?id=") ||
      url.contains("//search.worldcat.org/issn/") ||
      url.contains("//geohack.toolforge.org/geohack.php?pagename=") ||
      double.tryParse(title.replaceAll("/", "").replaceAll(".", "")) != null) {
    isvalid = false;
  }
  return isvalid;
}

int sortcondition(Map item1, Map item2) {
  String title2 = item2.keys.first;
  String title1 = item1.keys.first;
  int swapornot = -1;
  if (title2.toLowerCase() == "official website") {
    swapornot = 1;
  }
  return swapornot;
}

Map modified(String title, String url) {
  if (url.contains("//web.archive.org/web/")) {
    return {url.split("/")[7]: "htt${url.split("htt").last}"};
  } else {
    return {title: url};
  }
}

Future getRefs(String query) async {
  urls = [];
  title = query;
  var refs = await http.get(Uri.parse("https://en.wikipedia.org/wiki/$query"));
  parse(refs.body).getElementsByTagName("a").forEach(
    (element) async {
      var url = element.attributes['href'].toString();
      var title = parse(element.innerHtml)
          .documentElement!
          .text
          .toString()
          .replaceAll("https://", "")
          .replaceAll("http://", "");
      if (valid(url, title)) {
        urls.add(modified(title, url));
      }
    },
  );
  urls.sort((a, b) => sortcondition(a, b));
  await wikiinfosnippet(title);

}

Future wikiinfosnippet(String t) async {
  var wikidata = await http.get(Uri.parse("https://en.wikipedia.org/api/rest_v1/page/summary/${t.replaceAll(" ", "_")}"));
  Map jsondata = json.decode(wikidata.body);
  String pageId = jsondata['pageid'].toString();
  var images = await http.get(Uri.parse(
      "https://en.wikipedia.org/w/api.php?action=query&titles=$t&format=json&prop=images"));
  
  List titles = [];
  List imageurls = [];
  json.decode(images.body)['query']['pages'][pageId]['images'].toList().forEach((e) {
    titles.add(e['title']);
  });
  imageurls.add(json.decode(wikidata.body)['originalimage']['source']);
  var s = await http.get(Uri.parse("https://commons.wikimedia.org/w/api.php?action=query&format=json&prop=imageinfo&iiprop=url&titles=${titles.where((element) => element.toString().toLowerCase().startsWith("file")).toString().replaceAll(", ", "|").substring(1, titles.where((element) => element.toString().toLowerCase().startsWith("file")).toString().replaceAll(", ", "|").length - 1)}"));
  json.decode(s.body)['query']['pages'].keys.forEach((element) {
    if (json
                .decode(s.body)['query']['pages'][element]
                .containsKey("imageinfo") &&
            json
                .decode(s.body)['query']['pages'][element]
                .toString()
                .toLowerCase()
                .contains(".jpg") ||
        json
            .decode(s.body)['query']['pages'][element]
            .toString()
            .toLowerCase()
            .contains(".png")) {
      imageurls.add(json.decode(s.body)['query']['pages'][element]['imageinfo'][0]['url']);
    }
  });
  description = {
    "description" : jsondata['description'],
    "extract" : jsondata['extract'],
    "source" : jsondata['content_urls']['desktop']['page'],
    "images" : imageurls,
    "titles" : titles
  };
}
