# Flutter Super HtmlViewer

A Flutter plugin that provides a HtmlViewer widget on multiple platforms

## Supported Platform
- Android
- iOS
- Web
- Windows

## Screen Shoot
<table>
  <tr>
    <th>Web</th>
    <th>Desktop</th>
    <th>Mobile</th>
  </tr>
  <tr>
    <td><img src="https://user-images.githubusercontent.com/80730648/206114683-998ae664-e7fd-43f3-874b-0e03992edb4f.PNG" /></td>
    <td><img src="https://user-images.githubusercontent.com/80730648/206119645-065ddb63-9f99-400b-a479-97ccfef6b78e.PNG" /></td>
    <td><img src="https://user-images.githubusercontent.com/80730648/206131975-a8012951-3107-4d2f-8bbf-9e5a730be101.png" /></td>
  </tr>
</table>

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