# Flutter Super HtmlViewer

A Flutter plugin that provides a HtmlViewer widget on multiple platforms

## Supported Platform
- Android
- iOS
- Web
- Windows

## Usage

Add the package to pubspec.yaml

```dart
dependencies:
  flutter_super_html_viewer: x.x.x
```

Import it

```dart
import 'package:flutter_super_html_viewer/flutter_super_html_viewer.dart';
```

Use the widget

```dart
HtmlContentViewer(
    htmlContent: '<p>Here is some text</p> with a <a href="https://github.com/dab246/flutter_super_html_viewer">link</a>.',
    initialContentHeight: MediaQuery.of(context).size.height,
    initialContentWidth: MediaQuery.of(context).size.width,
)
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.