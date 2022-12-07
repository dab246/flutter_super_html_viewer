import 'package:flutter/material.dart';
import 'package:flutter_super_html_viewer/flutter_super_html_viewer.dart';

void main() {
  runApp(const MyApp());
}

const _htmlContent =
    '''<p>Here is some text</p> with a <a href="https://github.com/dab246/flutter_super_webview" target="_blank">link</a>.
  <p>Here is <b>bold</b> text</p>
  <p>Here is <i>some italic sic</i> text</p>
  <p>Here is <i><b>bold and italic</b></i> text</p>
  <p style="text-align: center;">Here is <u><i><b>bold and italic and underline</b></i></u> text</p>
  <ul><li>one list element</li><li>another point</li></ul>
  <blockquote>Here is a quote<br/>
    that spans several lines<br/>
    <blockquote>
        Another second level blockqote 
    </blockquote>
  </blockquote>
''';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebView Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'WebView Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HtmlContentViewer(
                htmlContent: _htmlContent,
                initialContentHeight: MediaQuery.of(context).size.height,
                initialContentWidth: MediaQuery.of(context).size.width,
              )
            ],
          ),
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
