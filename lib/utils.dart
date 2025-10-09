import 'dart:ffi';
import 'dart:io';


DynamicLibrary getDynamicLibrary(String libName, {String? libShortName, bool iOSStatic = false}) {
  if (Platform.isIOS && iOSStatic) {
    return DynamicLibrary.process();
  }

  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$libName.framework/$libName');
  }

  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib${libShortName ?? libName}.so');
  }

  if (Platform.isWindows) {
    return DynamicLibrary.open('$libName.dll');
  }

  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}
