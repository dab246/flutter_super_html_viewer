library flutter_super_html_viewer;

export 'package:flutter_super_html_viewer/src/controller/html_viewer_controller_unsupported.dart'
    if (dart.library.html) 'package:flutter_super_html_viewer/src/controller/web/html_viewer_controller_web.dart'
    if (dart.library.io) 'package:flutter_super_html_viewer/src/controller/mobile/html_viewer_controller_mobile.dart';

export 'package:flutter_super_html_viewer/src/view/html_content_viewer_unsupported.dart'
    if (dart.library.html) 'package:flutter_super_html_viewer/src/view/web/html_content_viewer_web.dart'
    if (dart.library.io) 'package:flutter_super_html_viewer/src/view/mobile/html_content_viewer_mobile.dart';
