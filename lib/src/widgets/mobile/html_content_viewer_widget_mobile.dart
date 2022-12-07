import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_super_html_viewer/flutter_super_html_viewer.dart';
import 'package:flutter_super_html_viewer/utils/app_define.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_super_html_viewer/utils/color_utils.dart';
import 'package:flutter_super_html_viewer/utils/html_event_action.dart';
import 'package:flutter_super_html_viewer/utils/html_utils.dart';
import 'package:flutter_super_html_viewer/utils/javascript_utils.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HtmlContentViewerWidget extends StatefulWidget {
  final String htmlContent;
  final double initialContentHeight;
  final double minContentHeight;
  final double? maxContentHeightForAndroid;
  final String? customStyleCssTag;
  final String? customScriptsTag;
  final Widget? loadingView;

  /// Register this callback after onWebViewCreated() called.
  final OnWebViewCreated? onWebViewCreated;

  /// Register this callback after onPageFinished() called
  final OnWebViewLoaded? onWebViewLoaded;

  /// Handler for mailto: links
  final OnMailtoDelegate? mailtoDelegate;

  /// Handler for any non-media URLs that the user taps on the website.
  /// Returns `true` when the given `url` was handled.
  final OnUrlLauncherDelegate? urlLauncherDelegate;

  /// Listen event scroll horizontal web view
  final OnScrollHorizontalEnd? onScrollHorizontalEnd;

  const HtmlContentViewerWidget(
      {Key? key,
      required this.htmlContent,
      this.initialContentHeight = 400,
      this.minContentHeight = 100,
      // It hotfix for web_view crash on android device and waiting lib web_view update to fix this issue
      this.maxContentHeightForAndroid,
      this.customStyleCssTag,
      this.customScriptsTag,
      this.loadingView,
      this.onWebViewCreated,
      this.onWebViewLoaded,
      this.onScrollHorizontalEnd,
      this.urlLauncherDelegate,
      this.mailtoDelegate})
      : super(key: key);

  @override
  State<HtmlContentViewerWidget> createState() =>
      _HtmlContentViewerWidgetState();
}

class _HtmlContentViewerWidgetState extends State<HtmlContentViewerWidget> {
  late double actualHeight;
  late double maxHeightForAndroid;
  late WebViewController _webViewController;
  late String _htmlData;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    actualHeight = widget.initialContentHeight;
    maxHeightForAndroid =
        widget.maxContentHeightForAndroid ?? window.physicalSize.height;

    _htmlData = HtmlUtils.generateHtmlDocument(
      widget.htmlContent,
      customScriptsTag: widget.customScriptsTag,
      customStyleCssTag: widget.customStyleCssTag,
    );
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
          if (_isLoading) widget.loadingView ?? _buildLoadingView()
        ],
      );
    });
  }

  Widget _buildLoadingView() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.all(16),
          child:
              const CupertinoActivityIndicator(color: ColorUtils.colorLoading)),
    );
  }

  Widget _buildWebView() {
    return WebView(
      key: ValueKey(_htmlData),
      javascriptMode: JavascriptMode.unrestricted,
      backgroundColor: Colors.white,
      onWebViewCreated: _onWebViewCreated,
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
            onMessageReceived: _onHandleScrollEvent)
      },
      gestureNavigationEnabled: true,
      debuggingEnabled: true,
    );
  }

  void _onWebViewCreated(WebViewController controller) async {
    _webViewController = controller;
    await controller.loadHtmlString(_htmlData, baseUrl: null);
    final htmlViewerController = HtmlViewerController();
    htmlViewerController.webViewController = _webViewController;
    widget.onWebViewCreated?.call(htmlViewerController);
  }

  void _onPageFinished(String url) async {
    await Future.wait([
      _webViewController
          .runJavascript(JavascriptUtils.scriptsHandleScrollEventOnRunTime),
      _setActualHeightView(),
      _setActualWidthView(),
    ]);

    _hideLoadingProgress();
  }

  void _onHandleScrollEvent(JavascriptMessage javascriptMessage) {
    if (javascriptMessage.message == HtmlEventAction.scrollRightEndAction) {
      widget.onScrollHorizontalEnd?.call(false);
    } else if (javascriptMessage.message ==
        HtmlEventAction.scrollLeftEndAction) {
      widget.onScrollHorizontalEnd?.call(true);
    }
  }

  Future<void> _setActualHeightView() async {
    final scrollHeightText = await _webViewController
        .runJavascriptReturningResult('document.body.scrollHeight');
    final scrollHeight = double.tryParse(scrollHeightText);
    if (scrollHeight != null && mounted) {
      final scrollHeightWithBuffer = scrollHeight + 30.0;
      if (scrollHeightWithBuffer > widget.minContentHeight) {
        setState(() {
          if (Platform.isAndroid &&
              scrollHeightWithBuffer > maxHeightForAndroid) {
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
      _webViewController.runJavascriptReturningResult(
          'document.getElementsByClassName("tmail-content")[0].scrollWidth'),
      _webViewController.runJavascriptReturningResult(
          'document.getElementsByClassName("tmail-content")[0].offsetWidth')
    ]);

    if (result.length == 2) {
      final scrollWidth = double.tryParse(result[0]);
      final offsetWidth = double.tryParse(result[1]);

      if (scrollWidth != null && offsetWidth != null && mounted) {
        final isScrollActivated = scrollWidth.round() == offsetWidth.round();
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

  FutureOr<NavigationDecision> _onNavigation(
      NavigationRequest navigation) async {
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
      await launcher.launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication);
    }
    return NavigationDecision.prevent;
  }
}
