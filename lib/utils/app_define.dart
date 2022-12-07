import 'package:flutter_super_html_viewer/flutter_super_html_viewer.dart';

typedef OnScrollHorizontalEnd = Function(bool leftScroll);
typedef OnWebViewLoaded = Function(bool scrollHorizontalEmabled);
typedef OnWebViewCreated = Function(HtmlViewerController controller);
typedef OnUrlLauncherDelegate = Future<bool> Function(Uri uri);
typedef OnMailtoDelegate = Function(Uri? uri);
