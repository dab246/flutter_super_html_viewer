# Flutter Super HtmlViewer

A Flutter plugin that provides a HtmlViewer widget on multiple platforms

## Usage

Add the package to pubspec.yaml

```dart
dependencies:
  flutter_super_html_viewer: x.x.x
```

Import it

```dart
// On Mobile
import 'package:flutter_super_html_viewer/view/mobile/mobile_html_content_viewer.dart';
// On Web
import 'package:flutter_super_html_viewer/view/web/web_html_content_viewer.dart';
```

Use the widget

- On Mobile

```dart
MobileHtmlContentViewer(
    contentHtml: '<p>Here is some text</p> with a <a href="https://github.com/dab246/flutter_super_html_viewer">link</a>.',
    heightContent: MediaQuery.of(context).size.height,
    mailtoDelegate: (uri) async {},
    onScrollHorizontalEnd: (leftDirection) {},
    onWebViewLoaded: (isScrollPageViewActivated) {},
)
```

- On Web

```dart
WebHtmlContentViewer(
    widthContent: MediaQuery.of(context).size.width,
    heightContent: MediaQuery.of(context).size.height,
    contentHtml: '<p>Here is some text</p> with a <a href="https://github.com/dab246/flutter_super_html_viewer">link</a>.',
    controller: WebHtmlContentViewerController(),
    mailtoDelegate: (uri) {}
)
```