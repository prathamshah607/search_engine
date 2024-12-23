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

bool valid(String url, String title) {
    bool isvalid = true;
    if (url.startsWith("#") ||
    title.toLowerCase() == "the original" ||
        url=="null" || url == "" ||
        url.startsWith("/") ||
        url.contains("wiki") ||
        url.contains("//doi.org") || url.contains("//ui.adsabs.harvard.edu") || url.contains("books.google.com/books?id=") || url.contains("//search.worldcat.org/issn/") || url.contains("//geohack.toolforge.org/geohack.php?pagename=") ||
        double.tryParse(title.replaceAll("/", "").replaceAll(".", "")) != null
        ) {
      isvalid = false;
    }
    return isvalid;
  }

int sortcondition (String url1, String title1, String url2, String title2, String query)
{
  return 1;
}

String modified_url (String url) {
    if(url.contains("//web.archive.org/web/")){
      return "htt${url.split("htt").last}";
    }
    else return url;
}

Future getRefs(String query) async {
  urls = [];
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
        urls.add({title: modified_url(url)});
      }
    },
  );
}
