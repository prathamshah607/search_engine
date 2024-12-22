import 'dart:convert';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

Map<dynamic, dynamic> data = {};
String query = "";
List<Map> imagedata = [];
List<Map> urls = [];

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
  imagest.keys.forEach((c) {
    imagedata.add({
      "src": imagest[c]["imageinfo"][0]['thumburl'] ?? "",
      "fullsrc": imagest[c]["imageinfo"][0]['url'] ?? "",
      "title": imagest[c]["title"] ?? "",
      "timestamp": imagest[c]["touched"] ?? "",
    });
  });
}

Future getRefs(String query) async {
  urls = [];
  bool valid(String url, String title) {
    bool isvalid = true;
    if (url.startsWith("#") ||
        url=="null" || url == "" ||
        url.startsWith("/") ||
        url.contains("wiki") ||
        url.contains("books.google.com")) {
      isvalid = false;
    }
    return isvalid;
  }
  var refs = await http.get(Uri.parse("https://en.wikipedia.org/wiki/$query"));
  parse(refs.body).getElementsByTagName("a").reversed.forEach(
    (element) async {
      print(element);
      var url = element.attributes['href'].toString();
      var title = parse(element.innerHtml)
          .documentElement!
          .text
          .toString()
          .replaceAll("https://", "")
          .replaceAll("http://", "");
      if (valid(url, title)) {
        urls.add({title: url});
      }
    },
  );
}
