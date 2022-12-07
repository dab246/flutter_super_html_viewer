import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_super_html_viewer/flutter_super_html_viewer.dart'
    as html_viewer;
import 'package:flutter_super_html_viewer/utils/color_utils.dart';
import 'package:flutter_super_html_viewer/utils/html_utils.dart';
import 'package:webview_windows/webview_windows.dart';

class HtmlContentViewerWidget extends StatefulWidget {
  final String htmlContent;
  final double initialContentHeight;
  final double initialContentWidth;
  final double minContentHeight;
  final double minContentWidth;
  final String? customStyleCssTag;
  final String? customScriptsTag;
  final Widget? loadingView;
  final html_viewer.HtmlViewerController? controller;

  const HtmlContentViewerWidget({
    Key? key,
    required this.htmlContent,
    this.initialContentHeight = 400,
    this.initialContentWidth = 1000,
    this.minContentWidth = 300,
    this.minContentHeight = 100,
    this.customStyleCssTag,
    this.customScriptsTag,
    this.loadingView,
    this.controller,
  }) : super(key: key);

  @override
  State<HtmlContentViewerWidget> createState() =>
      _HtmlContentViewerWidgetState();
}

class _HtmlContentViewerWidgetState extends State<HtmlContentViewerWidget> {
  late double actualHeight;
  late double actualWidth;
  late WebviewController _controller;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    actualHeight = widget.initialContentHeight;
    actualWidth = widget.initialContentWidth;
    if (widget.controller != null) {
      _controller = widget.controller!.webViewController;
    } else {
      _controller = WebviewController();
    }
    print('VAO _controller $_controller');
    _setUpConfigWebView();
  }

  void _setUpConfigWebView() async {
    await _controller.initialize();
    await _controller.setBackgroundColor(Colors.white);

    final htmlDocument = HtmlUtils.generateHtmlDocument(widget.htmlContent,
        customScriptsTag: widget.customScriptsTag,
        customStyleCssTag: widget.customStyleCssTag,
        minHeight: widget.minContentHeight,
        minWidth: widget.minContentWidth);

    await _controller.loadStringContent(htmlDocument);

    _listenEventWebView();

    setState(() {
      _isLoading = false;
    });
  }

  void _listenEventWebView() async {
    _controller.addListener(() {
      log('_DesktopHtmlContentViewerState::_setUpConfigWebView():addListener');
    });

    _controller.loadingState.listen((event) {
      log('_DesktopHtmlContentViewerState::_setUpConfigWebView():loadingState: $event');
    });

    _controller.onLoadError.listen((event) {
      log('_DesktopHtmlContentViewerState::_setUpConfigWebView():onLoadError: $event');
    });

    _controller.webMessage.listen((event) {
      log('_DesktopHtmlContentViewerState::_setUpConfigWebView():webMessage: $event');
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          SizedBox(
            height: actualHeight,
            width: constraints.maxWidth,
            child: _buildWebView(),
          ),
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
              child:
                  CupertinoActivityIndicator(color: ColorUtils.colorLoading))),
    );
  }

  Widget _buildWebView() {
    return Webview(
      _controller,
      height: actualHeight,
      width: actualWidth,
    );
  }
}
