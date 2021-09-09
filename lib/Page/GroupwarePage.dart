import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hr_project_flutter/Auth/AuthManager.dart';
import 'package:hr_project_flutter/General/Common.dart';
import 'package:hr_project_flutter/General/Logger.dart';
import 'package:hr_project_flutter/General/TDIUser.dart';
import 'package:hr_project_flutter/Page/Pages.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GroupwarePage extends StatefulWidget {
  @override
  _GroupwarePageState createState() => _GroupwarePageState();
}

class _GroupwarePageState extends State<GroupwarePage> with WidgetsBindingObserver {
  late WebViewController _controller;
  final Completer<WebViewController> _controllerComplete = Completer<WebViewController>();

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    var cur = Get.currentRoute;
    if (kIsPushLink == true) {
      if (state == AppLifecycleState.resumed) {
        if (cur == Pages.nameGroupware) {
          _controller.loadUrl(kPushLinkURL);
        }
      }
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    slog.i("TDI Groupware Start ...");
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () => _goBack(context),
          child: _buildWebView(),
        ),
      ),
      floatingActionButton: _buildFloatingActionButtonOnyIOS(),
    );
  }

  Widget _buildWebView() {
    return WebView(
      // userAgent: 'random', ios에서 문제 발생 - 주석 처리 함
      initialUrl: kIsPushLink ? kPushLinkURL : URL.tdiLogin + TDIUser.token!.token,
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
        kIsPushLink = false;
      },
      navigationDelegate: (NavigationRequest request) {
        slog.i('allowing navigation to ${request.url}');
        _checkLogin(request.url);
        return NavigationDecision.navigate;
      },
    );
  }

  Widget _buildFloatingActionButtonOnyIOS() {
    return Visibility(
      visible: Platform.isIOS,
      child: Align(
        alignment: Alignment(-0.85, 1.0),
        child: FloatingActionButton(
          backgroundColor: Colors.black87,
          child: Icon(Icons.navigate_before),
          onPressed: () => _goBack(context),
        ),
      ),
    );
  }

  Future<void> loadHtmlFromAssets(String filename, controller) async {
    String fileText = await rootBundle.loadString(filename);
    controller
        .loadUrl(Uri.dataFromString(fileText, mimeType: 'text/html', encoding: Encoding.getByName('utf-8')).toString());
  }

  JavascriptChannel _javascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: '_webToAppLogout',
      onMessageReceived: (JavascriptMessage message) {
        slog.i('JavascriptChannel _webToAppLogout : ${message.message}');
        _goTitleAndLogout();
      },
    );
  }

  void _checkLogin(String urlString) {
    var url = Uri.parse(urlString);
    var error = url.queryParameters['error'];
    if (error == 'unauthenticated') {
      _goTitleAndLogout();
      showToastMessage(MESSAGES.errLoginFailed);
    }
  }

  void _goTitleAndLogout() {
    AuthManager().googleSignOut().then((value) => {
          TDIUser.clearData(),
          Get.toNamed(Pages.nameTitle),
        });
  }

  Future<bool> _goBack(BuildContext context) async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return Future.value(false);
    } else {
      Get.toNamed(Pages.nameTitle); // 더 이상 back를 할 수 없으면 title로 이동
      return Future.value(false);
    }
  }
}
