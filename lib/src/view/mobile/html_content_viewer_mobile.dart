import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_super_html_viewer/flutter_super_html_viewer.dart';
import 'package:flutter_super_html_viewer/src/widgets/mobile/html_content_viewer_widget_mobile.dart'
    as mobile;
import 'package:flutter_super_html_viewer/src/widgets/desktop/html_content_viewer_widget_desktop.dart'
    as desktop;
import 'package:flutter_super_html_viewer/utils/app_define.dart';
import 'dart:io' show Platform;

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
    if (!kIsWeb) {
      print('VAO');

      if (Platform.isAndroid || Platform.isIOS) {
        return mobile.HtmlContentViewerWidget(
            htmlContent: htmlContent,
            initialContentHeight: initialContentHeight,
            minContentHeight: minContentHeight,
            maxContentHeightForAndroid: maxContentHeightForAndroid,
            customStyleCssTag: customStyleCssTag,
            customScriptsTag: customScriptsTag,
            loadingView: loadingView,
            onWebViewLoaded: onWebViewLoaded,
            onScrollHorizontalEnd: onScrollHorizontalEnd,
            urlLauncherDelegate: urlLauncherDelegate,
            mailtoDelegate: mailtoDelegate);
      } else if (Platform.isWindows) {
        print('VAO isWindows');
        return desktop.HtmlContentViewerWidget(
          htmlContent: htmlContent,
          initialContentHeight: initialContentHeight,
          initialContentWidth: initialContentWidth,
          minContentWidth: minContentWidth,
          minContentHeight: minContentHeight,
          customStyleCssTag: customStyleCssTag,
          customScriptsTag: customScriptsTag,
          loadingView: loadingView,
          controller: controller,
        );
      } else {
        return const Text('Unsupported in this environment');
      }
    } else {
      return const Text(
          'Flutter Web environment detected, please make sure you are importing package:flutter_super_html_viewer/flutter_super_html_viewer.dart');
    }
  }
}
