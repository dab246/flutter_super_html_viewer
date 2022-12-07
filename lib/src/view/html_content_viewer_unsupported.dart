import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_super_html_viewer/flutter_super_html_viewer.dart';
import 'package:flutter_super_html_viewer/utils/app_define.dart';

class HtmlContentViewer extends StatelessWidget {
  final String htmlContent;
  final double initialContentHeight;
  final double initialContentWidth;
  final double minContentHeight;
  final double minContentWidth;
  final double? maxContentHeightForAndroid;
  final String? customStyleCssTag;
  final String? customScriptsTag;
  final Widget? loadingView;
  final HtmlViewerController? controller;

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

  const HtmlContentViewer(
      {Key? key,
      required this.htmlContent,
      this.controller,
      this.initialContentHeight = 400,
      this.initialContentWidth = 1000,
      this.minContentWidth = 300,
      this.minContentHeight = 100,
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
  Widget build(BuildContext context) {
    return const Text('Unsupported in this environment');
  }
}
