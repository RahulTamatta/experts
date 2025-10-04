// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../widget/commonAppbar.dart';

class TermAndConditionScreen extends StatelessWidget {
  TermAndConditionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: CommonAppBar(
            title: 'Terms and Condition',
          )),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
            url: WebUri('https://astroway.diploy.in/terms-condition')),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          transparentBackground: true,
        ),
        onProgressChanged: (controller, progress) {
          debugPrint('Terms condition progress: $progress');
        },
        onReceivedError: (controller, request, error) {
          debugPrint('Terms condition error: $error');
        },
        onLoadStop: (controller, url) {},
        onWebViewCreated: (controller) {
          // Here you can access the InAppWebViewController instance
        },
        onConsoleMessage: (controller, consoleMessage) {
          debugPrint('console web $consoleMessage');
        },
      ),
    );
  }
}
