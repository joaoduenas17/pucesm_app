import 'package:webview_flutter/webview_flutter.dart';

abstract final class EvaSessionService {
  static Future<void> clear() async {
    await WebViewCookieManager().clearCookies();

    final controller = WebViewController();
    await controller.clearCache();
    await controller.clearLocalStorage();
  }
}
