import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key, required this.link_url});

  final String? link_url;

  @override
  State<WebViewPage> createState() {
    return _WebViewPageState(link_url ?? "");
  }
}

class _WebViewPageState extends State<WebViewPage> {
  final String link_url;
  _WebViewPageState(this.link_url);

  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
      isInspectable: kDebugMode,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true);

  PullToRefreshController? pullToRefreshController;

  late ContextMenu contextMenu;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    pullToRefreshController = kIsWeb ||
        ![TargetPlatform.iOS, TargetPlatform.android]
            .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          webViewController?.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS) {
          webViewController?.loadUrl(
              urlRequest:
              URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
          child: Column(children: <Widget>[
        Expanded(child: Stack(
          children: [
            InAppWebView(
              key: webViewKey,
             // initialUrlRequest:  URLRequest(url: WebUri('https://modules.bsbiggie.com/frontend-about-biggie/?card_id=1')),
              initialUrlRequest: URLRequest(url:WebUri(link_url)),
              initialUserScripts: UnmodifiableListView<UserScript>([]),
              initialSettings: settings,
              pullToRefreshController: pullToRefreshController,
              onWebViewCreated: (controller) async {
                webViewController = controller;
                controller.addJavaScriptHandler(handlerName: 'handleBackButton', callback: (args) {
                  backToMainApp();
                });
                controller.addJavaScriptHandler(handlerName: 'openExternalBrowser', callback: (args) {
                  // Handle opening external browser here
                  var message = json.decode(args[0]);
                  _openExternalBrowser(message['url']);
                });
              },
              onLoadStart: (controller, url) async {

                setState(() {
                  this.url = url.toString();
                  urlController.text = this.url;
                });
              },
              onPermissionRequest: (controller, request) async {
                return PermissionResponse(
                    resources: request.resources,
                    action: PermissionResponseAction.GRANT);
              },
              shouldOverrideUrlLoading:
                  (controller, navigationAction) async {
                var uri = navigationAction.request.url!;
                print("test-url");
                print(uri);
                if (![
                  "http",
                  "https",
                  "file",
                  "chrome",
                  "data",
                  "javascript",
                  "about"
                ].contains(uri.scheme)) {
                  print("test-url");
                  if (await canLaunchUrl(uri)) {
                    // Launch the App
                    await launchUrl(
                      uri,
                    );
                    // and cancel the request
                    return NavigationActionPolicy.CANCEL;
                  }
                }

                return NavigationActionPolicy.ALLOW;
              },
              onLoadStop: (controller, url) async {
                pullToRefreshController?.endRefreshing();
                setState(() {
                  this.url = url.toString();
                  urlController.text = this.url;
                });
              },
              onReceivedError: (controller, request, error) {
                pullToRefreshController?.endRefreshing();
              },
              onProgressChanged: (controller, progress) {
                if (progress == 100) {
                  pullToRefreshController?.endRefreshing();
                }
                setState(() {
                  this.progress = progress / 100;
                  urlController.text = this.url;
                });
              },
              onUpdateVisitedHistory: (controller, url, isReload) {
                setState(() {
                  this.url = url.toString();
                  urlController.text = this.url;
                });
              },
              onConsoleMessage: (controller, consoleMessage) {
                print(consoleMessage);
              },

            ),
            progress < 1.0
                ? LinearProgressIndicator(value: progress)
                : Container(),
          ],
        ),flex: 1,),
      ],
          )
      )
    );
  }

  Future<void> backToMainApp() async{
    Navigator.of(context).pop();
  }

  void _openExternalBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}