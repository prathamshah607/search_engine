import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebsiteViewer extends StatefulWidget {
  final String furl;
  final bool js;
  const WebsiteViewer({super.key, required this.furl, required this.js});

  @override
  State<WebsiteViewer> createState() => _WebsiteViewerState();
}

class _WebsiteViewerState extends State<WebsiteViewer> {
  late final WebViewController controller;
  Set<String> selection = {};

  @override
  void initState() {
    controller = WebViewController()
      ..loadRequest(Uri.parse(widget.furl))
      ..setJavaScriptMode(
          widget.js ? JavaScriptMode.unrestricted : JavaScriptMode.disabled);
    selection = {widget.js.toString()};
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SegmentedButton(
          multiSelectionEnabled: false,
          segments: const [
            ButtonSegment(value: "false", label: Text("No JS")),
            ButtonSegment(value: "true", label: Text("Full JS")),
          ],
          onSelectionChanged:(p0) async {
            selection = p0;
            if(p0.first == "false")
            {
              controller.setJavaScriptMode(JavaScriptMode.disabled);
            }
            else if (p0.first == "true") {
            controller.setJavaScriptMode(JavaScriptMode.unrestricted);
            }
            controller.currentUrl().then((value) {
              controller.loadRequest(Uri.parse(value!));
            });
            setState(() {});
          },
          selected: selection,
        ),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
