import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../models/news_item.dart';

class NewsDetailScreen extends StatefulWidget {
  final NewsItem item;
  const NewsDetailScreen({super.key, required this.item});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    final html = _wrapHtml(widget.item.title, widget.item.descriptionHtml);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(html);
  }

  String _wrapHtml(String title, String bodyHtml) {
    return '''
<!doctype html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
  body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif; padding: 16px; }
  h1 { font-size: 18px; margin: 0 0 12px 0; }
  img { max-width: 100%; height: auto; }
</style>
</head>
<body>
  <h1>${_escape(title)}</h1>
  $bodyHtml
</body>
</html>
''';
  }

  String _escape(String s) =>
      s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
