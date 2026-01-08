import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VirtualScreen extends StatefulWidget {
  const VirtualScreen({super.key});

  @override
  State<VirtualScreen> createState() => _VirtualScreenState();
}

class _VirtualScreenState extends State<VirtualScreen> {
  late final WebViewController _controller;

  bool _isLoading = true;
  bool _canGoBack = false;
  bool _canGoForward = false;

  // Mostramos algo corto y limpio en la barrita
  String _hostLabel = 'eva.pucesm.edu.ec';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) async {
            setState(() => _isLoading = true);
            await _refreshNavState(url: url);
          },
          onPageFinished: (url) async {
            setState(() => _isLoading = false);
            await _refreshNavState(url: url);
          },
          onNavigationRequest: (request) {
            // Si luego quieres bloquear dominios externos, aquí.
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://eva.pucesm.edu.ec'));
  }

  Future<void> _refreshNavState({String? url}) async {
    final canBack = await _controller.canGoBack();
    final canForward = await _controller.canGoForward();

    String host = _hostLabel;
    if (url != null && url.isNotEmpty) {
      final uri = Uri.tryParse(url);
      if (uri != null && uri.host.isNotEmpty) host = uri.host;
    } else {
      final current = await _controller.currentUrl();
      final uri = current != null ? Uri.tryParse(current) : null;
      if (uri != null && uri.host.isNotEmpty) host = uri.host;
    }

    if (!mounted) return;
    setState(() {
      _canGoBack = canBack;
      _canGoForward = canForward;
      _hostLabel = host;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // ✅ Sin Scaffold para no duplicar AppBar (BottomNav ya pone AppBar)
    return SafeArea(
      child: Column(
        children: [
          // WebView
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),

                // Loader arriba del WebView (opcional pero pro)
                if (_isLoading)
                  const Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
              ],
            ),
          ),

          // ✅ Barra blanca ABAJO (como pediste)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.black.withOpacity(0.08)),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Atrás',
                  onPressed: _canGoBack
                      ? () async {
                          await _controller.goBack();
                          await _refreshNavState();
                        }
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  tooltip: 'Adelante',
                  onPressed: _canGoForward
                      ? () async {
                          await _controller.goForward();
                          await _refreshNavState();
                        }
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
                IconButton(
                  tooltip: 'Recargar',
                  onPressed: () async {
                    await _controller.reload();
                    await _refreshNavState();
                  },
                  icon: const Icon(Icons.refresh),
                ),

                const SizedBox(width: 8),

                // “URL” / dominio en forma de pill
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_outline, size: 16, color: cs.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _hostLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
