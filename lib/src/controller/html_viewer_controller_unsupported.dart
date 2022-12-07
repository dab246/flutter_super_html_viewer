class HtmlViewerController {
  /// Manages the view ID for the [HtmlViewerControllerForWeb] on web
  String? _viewId;

  set viewId(String? viewId) => _viewId = viewId;

  dynamic get webViewController => null;

  set webViewController(dynamic controller) => {};

  /// A function to quickly call a document.execCommand function in a readable format
  void execCommand(String command, {String? argument}) {}

  /// A function to execute JS passed as a [WebScript] to the editor. This should
  /// only be used on Flutter Web.
  Future<dynamic> evaluateJavascriptWeb(String name,
          {bool hasReturnValue = false}) =>
      Future.value(null);
}
