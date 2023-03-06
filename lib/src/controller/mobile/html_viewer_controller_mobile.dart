import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart' as mobile;
import 'package:flutter_super_html_viewer/src/controller/html_viewer_controller_unsupported.dart'
    as unsupported;
import 'package:webview_windows/webview_windows.dart' as window;

/// Controller for mobile
class HtmlViewerController extends unsupported.HtmlViewerController {
  /// Manages the [WebViewController] for the [HtmlViewerController]
  dynamic _webViewController;

  /// Allows the [WebViewController] for the HtmlContentViewer to be accessed
  /// outside of the package itself for endless control and customization.
  @override
  dynamic get webViewController => _webViewController;

  /// Internal method to set the [WebViewController] when webview initialization
  /// is complete
  @override
  set webViewController(dynamic controller) {
    if (controller == null) {
      return;
    }

    if (Platform.isAndroid || Platform.isIOS) {
      _webViewController = controller as mobile.InAppWebViewController;
    } else if (Platform.isWindows) {
      _webViewController = controller as window.WebviewController;
    }
  }
}
