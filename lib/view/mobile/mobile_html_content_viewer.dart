import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_super_html_viewer/utils/color_utils.dart';
import 'package:flutter_super_html_viewer/utils/html_event_action.dart';
import 'package:flutter_super_html_viewer/utils/html_utils.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

typedef OnScrollHorizontalEnd = Function(bool leftDirection);
typedef OnWebViewLoaded = Function(bool isScrollPageViewActivated);

class MobileHtmlContentViewer extends StatefulWidget {

  final String contentHtml;
  final double heightContent;

  /// Listen event scroll horizontal web view
  final OnScrollHorizontalEnd? onScrollHorizontalEnd;

  /// Register this callback after _onPageFinished() called
  final OnWebViewLoaded? onWebViewLoaded;

  /// Register this callback if you want a reference to the [WebViewController].
  final void Function(WebViewController controller)? onCreated;

  /// Handler for mailto: links
  final Future Function(Uri mailto)? mailtoDelegate;

  /// Handler for any non-media URLs that the user taps on the website.
  ///
  /// Returns `true` when the given `url` was handled.
  final Future<bool> Function(Uri url)? urlLauncherDelegate;

  const MobileHtmlContentViewer({
    Key? key,
    required this.contentHtml,
    this.heightContent = 400,
    this.onCreated,
    this.onWebViewLoaded,
    this.onScrollHorizontalEnd,
    this.urlLauncherDelegate,
    this.mailtoDelegate,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MobileHtmlContentViewerViewState();
}

class _MobileHtmlContentViewerViewState extends State<MobileHtmlContentViewer> {

  late double actualHeight;
  double minHeight = 100;
  double minWidth = 300;
  late double maxHeightForAndroid;
  String? _htmlData;
  late WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    actualHeight = widget.heightContent;
    maxHeightForAndroid = window.physicalSize.height;
    _htmlData = HtmlUtils.generateHtmlDocument(widget.contentHtml);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          SizedBox(
              height: actualHeight,
              width: constraints.maxWidth,
              child: _buildWebView()),
          if (_isLoading) _buildLoadingView()
        ],
      );
    });
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Padding(
          padding: EdgeInsets.all(16),
          child: SizedBox(
              width: 30,
              height: 30,
              child: CupertinoActivityIndicator(color: ColorUtils.colorLoading))),
    );
  }

  Widget _buildWebView() {
    final htmlData = _htmlData;
    if (htmlData == null || htmlData.isEmpty) {
      return Container();
    }
    return WebView(
      key: ValueKey(htmlData),
      javascriptMode: JavascriptMode.unrestricted,
      backgroundColor: Colors.white,
      onWebViewCreated: (controller) async {
        _webViewController = controller;
        await controller.loadHtmlString(htmlData, baseUrl: null);
        widget.onCreated?.call(controller);
      },
      onPageFinished: _onPageFinished,
      zoomEnabled: false,
      navigationDelegate: _onNavigation,
      gestureRecognizers: {
        Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer()),
        Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
      },
      javascriptChannels: {
        JavascriptChannel(
            name: HtmlUtils.scrollEventJSChannelName,
            onMessageReceived: _onHandleScrollEvent
        )
      },
      gestureNavigationEnabled: true,
      debuggingEnabled: true,
    );
  }

  void _onPageFinished(String url) async {
    await Future.wait([
      _webViewController.runJavascript(HtmlUtils.runScriptsHandleScrollEvent),
      _setActualHeightView(),
      _setActualWidthView(),
    ]);

    _hideLoadingProgress();
  }

  void _onHandleScrollEvent(JavascriptMessage javascriptMessage) {
    log('_HtmlContentViewState::_onHandleScrollEvent():message: ${javascriptMessage.message}');
    if (javascriptMessage.message == HtmlEventAction.scrollRightEndAction) {
      widget.onScrollHorizontalEnd?.call(false);
    } else if (javascriptMessage.message == HtmlEventAction.scrollLeftEndAction) {
      widget.onScrollHorizontalEnd?.call(true);
    }
  }

  Future<void> _setActualHeightView() async {
    final scrollHeightText = await _webViewController.runJavascriptReturningResult('document.body.scrollHeight');
    final scrollHeight = double.tryParse(scrollHeightText);
    log('_HtmlContentViewState::_setActualHeightView(): scrollHeightText: $scrollHeightText');
    if (scrollHeight != null && mounted) {
      final scrollHeightWithBuffer = scrollHeight + 30.0;
      if (scrollHeightWithBuffer > minHeight) {
        setState(() {
          // It hotfix for web_view crash on android device and waiting lib web_view update to fix this issue
          if (Platform.isAndroid && scrollHeightWithBuffer > maxHeightForAndroid){
            actualHeight = maxHeightForAndroid;
          } else {
            actualHeight = scrollHeightWithBuffer;
          }
          _isLoading = false;
        });
      }
    }

    return Future.value(null);
  }

  Future<void> _setActualWidthView() async {
    final result = await Future.wait([
      _webViewController.runJavascriptReturningResult('document.getElementsByClassName("tmail-content")[0].scrollWidth'),
      _webViewController.runJavascriptReturningResult('document.getElementsByClassName("tmail-content")[0].offsetWidth')
    ]);

    if (result.length == 2) {
      final scrollWidth = double.tryParse(result[0]);
      final offsetWidth = double.tryParse(result[1]);
      log('_HtmlContentViewState::_setActualWidthView():scrollWidth: $scrollWidth');
      log('_HtmlContentViewState::_setActualWidthView():offsetWidth: $offsetWidth');

      if (scrollWidth != null && offsetWidth != null && mounted) {
        final isScrollActivated = scrollWidth.round() == offsetWidth.round();
        log('_HtmlContentViewState::_setActualWidthView():isScrollActivated: $isScrollActivated');
        widget.onWebViewLoaded?.call(isScrollActivated);
      }
    }

    return Future.value(null);
  }

  void _hideLoadingProgress() {
    if (mounted && _isLoading) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  FutureOr<NavigationDecision> _onNavigation(NavigationRequest navigation) async {
    if (navigation.isForMainFrame && navigation.url == 'about:blank') {
      return NavigationDecision.navigate;
    }
    final requestUri = Uri.parse(navigation.url);
    final mailtoHandler = widget.mailtoDelegate;
    if (mailtoHandler != null && requestUri.isScheme('mailto')) {
      await mailtoHandler(requestUri);
      return NavigationDecision.prevent;
    }
    final url = navigation.url;
    final urlDelegate = widget.urlLauncherDelegate;
    if (urlDelegate != null) {
      await urlDelegate(Uri.parse(url));
      return NavigationDecision.prevent;
    }
    if (await launcher.canLaunchUrl(Uri.parse(url))) {
      await launcher.launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication
      );
    }
    return NavigationDecision.prevent;
  }
}