import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_super_html_viewer/flutter_super_html_viewer.dart';
import 'package:flutter_super_html_viewer/utils/app_define.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_super_html_viewer/utils/color_utils.dart';
import 'package:flutter_super_html_viewer/utils/html_event_action.dart';
import 'package:flutter_super_html_viewer/utils/html_utils.dart';
import 'package:flutter_super_html_viewer/utils/javascript_utils.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:url_launcher/url_launcher_string.dart';

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
  late InAppWebViewController _webViewController;
  late String _htmlData;

  bool _isLoading = true;
  bool horizontalGestureActivated = false;

  @override
  void initState() {
    super.initState();
    actualHeight = widget.initialContentHeight;
    _htmlData = HtmlUtils.generateHtmlDocument(
      widget.htmlContent,
      customScriptsTag: widget.customScriptsTag,
      customStyleCssTag: widget.customStyleCssTag,
    );
  }

  @override
  void didUpdateWidget(covariant HtmlContentViewerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    final htmlData = _htmlData;
    if (htmlData.isEmpty) {
      return Container();
    }
    return InAppWebView(
        key: ValueKey(htmlData),
        onWebViewCreated: (controller) async {
          _webViewController = controller;
          controller.loadData(data: htmlData);
          final htmlViewerController = HtmlViewerController();
          htmlViewerController.webViewController = _webViewController;
          widget.onWebViewCreated?.call(htmlViewerController);
        },
        onLoadStop: _onLoadStop,
        shouldOverrideUrlLoading: _shouldOverrideUrlLoading,
        gestureRecognizers: {
          Factory<LongPressGestureRecognizer>(
              () => LongPressGestureRecognizer()),
          if (Platform.isIOS && horizontalGestureActivated)
            Factory<HorizontalDragGestureRecognizer>(
                () => HorizontalDragGestureRecognizer()),
          if (Platform.isAndroid)
            Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
        },
        onScrollChanged: (controller, x, y) => controller.scrollTo(x: 0, y: 0));
  }

  void _onLoadStop(InAppWebViewController controller, WebUri? webUri) async {
    await Future.wait([
      _setActualHeightView(),
      _setActualWidthView(),
    ]);

    _hideLoadingProgress();

    controller.addJavaScriptHandler(
        handlerName: HtmlUtils.scrollEventJSChannelName,
        callback: _onHandleScrollEvent);
  }

  void _onHandleScrollEvent(List<dynamic> parameters) {
    log('_HtmlContentViewState::_onHandleScrollRightEvent():parameters: $parameters');
    final message = parameters.first;
    log('_HtmlContentViewState::_onHandleScrollRightEvent():message: $message');
    if (message == HtmlEventAction.scrollLeftEndAction) {
      widget.onScrollHorizontalEnd?.call(true);
    } else if (message == HtmlEventAction.scrollRightEndAction) {
      widget.onScrollHorizontalEnd?.call(false);
    }
  }

  Future<void> _setActualHeightView() async {
    final scrollHeight = await _webViewController.evaluateJavascript(
        source: 'document.body.scrollHeight');
    log('_HtmlContentViewState::_setActualHeightView(): scrollHeight: $scrollHeight');
    if (scrollHeight != null && mounted) {
      final scrollHeightWithBuffer = scrollHeight + 30.0;
      if (scrollHeightWithBuffer > widget.minContentHeight) {
        setState(() {
          actualHeight = scrollHeightWithBuffer;
          _isLoading = false;
        });
      } else {
        actualHeight = widget.minContentHeight;
      }
    }

    return Future.value(null);
  }

  Future<void> _setActualWidthView() async {
    final result = await Future.wait([
      _webViewController.evaluateJavascript(
          source:
              'document.getElementsByClassName("tmail-content")[0].scrollWidth'),
      _webViewController.evaluateJavascript(
          source:
              'document.getElementsByClassName("tmail-content")[0].offsetWidth')
    ]);

    if (result.length == 2) {
      final scrollWidth = result[0];
      final offsetWidth = result[1];
      log('_HtmlContentViewState::_setActualWidthView():scrollWidth: $scrollWidth');
      log('_HtmlContentViewState::_setActualWidthView():offsetWidth: $offsetWidth');

      if (scrollWidth != null && offsetWidth != null && mounted) {
        final isScrollActivated = scrollWidth.round() == offsetWidth.round();
        log('_HtmlContentViewState::_setActualWidthView():isScrollActivated: $isScrollActivated');
        if (isScrollActivated) {
          setState(() {
            horizontalGestureActivated = false;
          });
        } else {
          setState(() {
            horizontalGestureActivated = true;
          });

          await _webViewController.evaluateJavascript(
              source: JavascriptUtils.scriptsHandleScrollEventOnRunTime);
        }

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

  Future<NavigationActionPolicy?> _shouldOverrideUrlLoading(
      InAppWebViewController controller,
      NavigationAction navigationAction) async {
    final url = navigationAction.request.url?.toString();

    if (url == null) {
      return NavigationActionPolicy.CANCEL;
    }

    if (navigationAction.isForMainFrame && url == 'about:blank') {
      return NavigationActionPolicy.ALLOW;
    }

    final requestUri = Uri.parse(url);
    final mailtoHandler = widget.mailtoDelegate;
    if (mailtoHandler != null && requestUri.isScheme('mailto')) {
      await mailtoHandler(requestUri);
      return NavigationActionPolicy.CANCEL;
    }

    final urlDelegate = widget.urlLauncherDelegate;
    if (urlDelegate != null) {
      await urlDelegate(Uri.parse(url));
      return NavigationActionPolicy.CANCEL;
    }
    if (await launcher.canLaunchUrl(Uri.parse(url))) {
      await launcher.launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication);
    }

    return NavigationActionPolicy.CANCEL;
  }
}
