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
          segments: [
            ButtonSegment(value: "false", label: Text("No JS")),
            ButtonSegment(value: "true", label: Text("Full JS")),
          ],
          onSelectionChanged:(p0) {
            print(p0);
          },
          selected: selection,
        ),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
