import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hr_project_flutter/General/AuthManager.dart';
import 'package:hr_project_flutter/General/Common.dart';
import 'package:hr_project_flutter/General/Logger.dart';
import 'package:hr_project_flutter/General/TDIUser.dart';
import 'package:hr_project_flutter/Page/Pages.dart';
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
            onWebViewCreated: (WebViewController webViewController) {
              _controllerComplete.complete(webViewController);
              _controllerComplete.future.then((value) => _controller = value);
            },
            // javascript channel test
            // initialUrl: '',
            // onWebViewCreated: (WebViewController webViewController) async {
            //   _controllerComplete.complete(webViewController);
            //   _controllerComplete.future.then((value) => _controller = value);
            //   await loadHtmlFromAssets(
            //       'assets/javascriptChannelTest.html', webViewController);
            // },
            //
            javascriptMode: JavascriptMode.unrestricted,
            gestureNavigationEnabled: true,
            javascriptChannels: <JavascriptChannel>{
              _javascriptChannel(context),
            },
            // onProgress: (int progress) {
            //   slog.i("TDI Groupware is loading (progress : $progress%)");
            // },
            onPageStarted: (String url) {
              slog.i('page started $url');
            },
            onPageFinished: (String url) {
              slog.i('page finished $url');
            },
            navigationDelegate: (NavigationRequest request) {
              slog.i('allowing navigation to $request');
              return NavigationDecision.navigate;
            },
          ),
        ),
      ),
    );
  }

  Future<void> loadHtmlFromAssets(String filename, controller) async {
    String fileText = await rootBundle.loadString(filename);
    controller.loadUrl(Uri.dataFromString(fileText,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }

  JavascriptChannel _javascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: '_webToAppLogout',
        onMessageReceived: (JavascriptMessage message) {
          slog.i('JavascriptChannel _webToAppLogout : ${message.message}');
          authManager.googleSignOut().then((value) => {
                TDIUser.clearLoginData(),
                Get.toNamed(PAGES.title),
              });
        });
  }

  Future<bool> _goBack(BuildContext context) async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return Future.value(false);
    } else {
      Get.toNamed(PAGES.title);
      return Future.value(false);
    }
  }
}
