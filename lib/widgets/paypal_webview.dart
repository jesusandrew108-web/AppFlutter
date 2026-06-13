import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayPalWebView extends StatefulWidget {
  final String approvalUrl;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const PayPalWebView({
    super.key,
    required this.approvalUrl,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<PayPalWebView> createState() => _PayPalWebViewState();
}

class _PayPalWebViewState extends State<PayPalWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (nav) {
            if (nav.url.contains('success.com')) {
              widget.onSuccess();
              Navigator.pop(context);
              return NavigationDecision.prevent;
            } else if (nav.url.contains('cancel.com')) {
              widget.onCancel();
              Navigator.pop(context);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.approvalUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pago con PayPal')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
