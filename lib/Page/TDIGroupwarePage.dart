import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hr_project_flutter/General/Common.dart';
import 'package:hr_project_flutter/General/Logger.dart';
import 'package:hr_project_flutter/General/TDIUser.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TDIGroupwarePage extends StatefulWidget {
  @override
  TDIGroupwarePageState createState() => TDIGroupwarePageState();
}

class TDIGroupwarePageState extends State<TDIGroupwarePage> {
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
    slog.i("TDI Groupware Start ...");
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () => _goBack(context),
          child: WebView(
            userAgent: 'random',
            initialUrl: URL.tdiLogin + TDIUser.token!.token,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              webViewController
                  .currentUrl()
                  .then((value) => slog.i('web view url : $value'));
              _controllerComplete.complete(webViewController);
              _controllerComplete.future.then((value) => _controller = value);
            },
            javascriptChannels: <JavascriptChannel>{
              _toasterJavascriptChannel(context),
            },
            // onProgress: (int progress) {
            //   slog.i("TDI Groupware is loading (progress : $progress%)");
            // },
            // onPageStarted: (String url) {
            //   slog.i('page started $url');
            // },
            // onPageFinished: (String url) {
            //   slog.i('page finished $url');
            // },
            // navigationDelegate: (NavigationRequest request) {
            //   slog.i('allowing navigation to $request');
            //   return NavigationDecision.navigate;
            // },
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
