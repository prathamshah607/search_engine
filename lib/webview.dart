import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Webviewer extends StatelessWidget {
  const Webviewer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: WebViewWidget(
        controller: WebViewController(),
      ),
    );
  }
}