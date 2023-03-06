import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter_super_html_viewer/flutter_super_html_viewer.dart';
import 'package:flutter_super_html_viewer/utils/app_define.dart';
import 'package:flutter_super_html_viewer/utils/color_utils.dart';
import 'package:flutter_super_html_viewer/utils/html_utils.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter_super_html_viewer/utils/shims/dart_ui.dart' as ui;

class HtmlContentViewerWidget extends StatefulWidget {
  final String htmlContent;
  final double initialContentHeight;
  final double initialContentWidth;
  final double minContentHeight;
  final double minContentWidth;
  final String? customStyleCssTag;
  final String? customScriptsTag;
  final Widget? loadingView;
  final HtmlViewerController? controller;

  /// Handler for mailto: links
  final OnMailtoDelegate? mailtoDelegate;

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
    this.mailtoDelegate,
  }) : super(key: key);

  @override
  State<HtmlContentViewerWidget> createState() =>
      _HtmlContentViewerWidgetState();
}

class _HtmlContentViewerWidgetState extends State<HtmlContentViewerWidget> {
  late String createdViewId;
  late double actualHeight;
  late double actualWidth;
  late HtmlViewerController controller;
  late String _htmlData;

  Future<bool>? webInit;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    actualHeight = widget.initialContentHeight;
    actualWidth = widget.initialContentWidth;
    controller = widget.controller ?? HtmlViewerController();

    createdViewId = _getRandString(10);
    controller.viewId = createdViewId;

    _setUpWeb();
  }

  @override
  void didUpdateWidget(covariant WebHtmlContentViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.contentHtml != oldWidget.contentHtml) {
      createdViewId = _getRandString(10);
      widget.controller.viewId = createdViewId;
      _setUpWeb();
    }

    if (widget.heightContent != oldWidget.heightContent) {
      actualHeight = widget.heightContent;
    }

    if (widget.widthContent != oldWidget.widthContent) {
      actualWidth = widget.widthContent;
    }
  }

  String _getRandString(int len) {
    var random = math.Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  void _setUpWeb() {
    final webViewActionScripts = '''
      <script type="text/javascript">
        window.parent.addEventListener('message', handleMessage, false);
        window.addEventListener('click', handleOnClickLink, true);
      
        function handleMessage(e) {
          if (e && e.data && e.data.includes("toIframe:")) {
            var data = JSON.parse(e.data);
            if (data["view"].includes("$createdViewId")) {
              if (data["type"].includes("getHeight")) {
                var height = document.body.scrollHeight;
                window.parent.postMessage(JSON.stringify({"view": "$createdViewId", "type": "toDart: htmlHeight", "height": height}), "*");
              }
              if (data["type"].includes("getWidth")) {
                var width = document.body.scrollWidth;
                window.parent.postMessage(JSON.stringify({"view": "$createdViewId", "type": "toDart: htmlWidth", "width": width}), "*");
              }
              if (data["type"].includes("execCommand")) {
                if (data["argument"] === null) {
                  document.execCommand(data["command"], false);
                } else {
                  document.execCommand(data["command"], false, data["argument"]);
                }
              }
            }
          }
        }
        
        function handleOnClickLink(e) {
           let link = e.target;
           let textContent = e.target.textContent;
           console.log("handleOnClickLink: " + link);
           console.log("handleOnClickLink: " + textContent);
           if (link && isValidUrl(link)) {
              window.parent.postMessage(JSON.stringify({"view": "$createdViewId", "type": "toDart: OpenLink", "url": "" + link}), "*");
              e.preventDefault();
           } else if (textContent && isValidUrl(textContent)) {
              window.parent.postMessage(JSON.stringify({"view": "$createdViewId", "type": "toDart: OpenLink", "url": "" + textContent}), "*");
              e.preventDefault();
           }
        }
        
        function isValidUrl(string) {
          let url;
          
          try {
            url = new URL(string);
          } catch (_) {
            return false;  
          }
        
          return url.protocol === "http:" || url.protocol === "https:" || url.protocol === "mailto:";
        }
        
        document.addEventListener('wheel', function(e) {
          e.ctrlKey && e.preventDefault();
        }, {
          passive: false,
        });
        
        window.addEventListener('keydown', function(e) {
          if (event.metaKey || event.ctrlKey) {
            switch (event.key) {
              case '=':
              case '-':
                event.preventDefault();
                break;
            }
          }
        });
      </script>
    ''';

    _htmlData = HtmlUtils.generateHtmlDocument(widget.htmlContent,
        minHeight: widget.minContentHeight,
        minWidth: widget.minContentWidth,
        customStyleCssTag: widget.customStyleCssTag,
        customScriptsTag:
            webViewActionScripts + (widget.customScriptsTag ?? ''));

    final iframe = html.IFrameElement()
      ..width = actualWidth.toString()
      ..height = actualHeight.toString()
      ..srcdoc = _htmlData
      ..style.border = 'none'
      ..style.overflow = 'hidden'
      ..style.width = '100%'
      ..style.height = '100%'
      ..onLoad.listen((event) async {
        final dataGetHeight = <String, Object>{
          'type': 'toIframe: getHeight',
          'view': createdViewId
        };
        final dataGetWidth = <String, Object>{
          'type': 'toIframe: getWidth',
          'view': createdViewId
        };

        const jsonEncoder = JsonEncoder();
        final jsonGetHeight = jsonEncoder.convert(dataGetHeight);
        final jsonGetWidth = jsonEncoder.convert(dataGetWidth);

        html.window.postMessage(jsonGetHeight, '*');
        html.window.postMessage(jsonGetWidth, '*');

        html.window.onMessage.listen((event) {
          var data = json.decode(event.data);
          if (data['type'] != null &&
              data['type'].contains('toDart: htmlHeight') &&
              data['view'] == createdViewId) {
            final docHeight = data['height'] ?? actualHeight;
            if (docHeight != null && mounted) {
              final scrollHeightWithBuffer = docHeight + 30.0;
              if (scrollHeightWithBuffer > widget.minContentHeight) {
                setState(() {
                  actualHeight = scrollHeightWithBuffer;
                  _isLoading = false;
                });
              }
            }
            if (mounted && _isLoading) {
              setState(() {
                _isLoading = false;
              });
            }
          }

          if (data['type'] != null &&
              data['type'].contains('toDart: htmlWidth') &&
              data['view'] == createdViewId) {
            final docWidth = data['width'] ?? actualWidth;
            if (docWidth != null && mounted) {
              if (docWidth > widget.minContentWidth) {
                setState(() {
                  actualWidth = docWidth;
                });
              }
            }
          }

          if (data['type'] != null &&
              data['type'].contains('toDart: onChangeContent') &&
              data['view'] == createdViewId) {
            Scrollable.of(context).position.ensureVisible(
                context.findRenderObject()!,
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeIn);
          }

          if (data['type'] != null &&
              data['type'].contains('toDart: OpenLink') &&
              data['view'] == createdViewId) {
            final link = data['url'];
            if (link != null && mounted) {
              log('_WebHtmlContentViewerState::_setUpWeb(): OpenLink: $link');
              final urlString = link as String;
              if (urlString.startsWith('mailto:')) {
                widget.mailtoDelegate?.call(Uri.parse(urlString));
              } else {
                html.window.open(urlString, '_blank');
              }
            }
          }
        });
      });

    ui.platformViewRegistry
        .registerViewFactory(createdViewId, (int viewId) => iframe);

    if (mounted) {
      setState(() {
        webInit = Future.value(true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
            height: actualHeight, width: actualWidth, child: _buildWebView()),
        if (_isLoading) widget.loadingView ?? _buildLoadingView()
      ],
    );
  }

  Widget _buildLoadingView() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.all(16),
          child:
              const CupertinoActivityIndicator(color: ColorUtils.colorLoading)),
    );
  }

  Widget _buildWebView() {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: FutureBuilder<bool>(
            future: webInit,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return HtmlElementView(
                  key: ValueKey(_htmlData),
                  viewType: createdViewId,
                );
              } else {
                return Container();
              }
            }));
  }
}
