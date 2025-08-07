import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class PlatformUtils {
  static bool get isWeb => kIsWeb;

  static bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }

  static bool get isIOS {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  static bool get isAndroid {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }

  static bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }
}
