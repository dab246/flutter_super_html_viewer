// ignore: camel_case_types
class platformViewRegistry {
  /// Shim for registerViewFactory
  /// https://github.com/flutter/engine/blob/master/lib/web_ui/lib/ui.dart#L72
  static void registerViewFactory(
      String viewTypeId, dynamic Function(int viewId) viewFactory) {}
}

/// Signature of callbacks that have no arguments and return no data.
typedef VoidCallback = void Function();

dynamic get window => null;
