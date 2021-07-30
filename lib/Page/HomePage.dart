import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hr_project_flutter/Utility/Logger.dart';
import 'package:webview_flutter/webview_flutter.dart';

String selectedUrl = 'https://dev.groupware.tdi9.com';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late WebViewController _controller;
  final Completer<WebViewController> _controllerComplete =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    slog.i("Flutter Sample : Web View (TDI Groupware)");
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () => _goBack(context),
          child: WebView(
            userAgent: 'random',
            initialUrl: selectedUrl,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controllerComplete.complete(webViewController);
              _controllerComplete.future.then((value) => _controller = value);
            },
            onProgress: (int progress) {
              slog.i("WebView is loading (progress : $progress%)");
            },
            javascriptChannels: <JavascriptChannel>{
              _toasterJavascriptChannel(context),
            },
          ),
        ),
      ),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  Future<bool> _goBack(BuildContext context) async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
