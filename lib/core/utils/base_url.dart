import 'dart:io';

String getBaseUrl() {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:5000';
  }
  return 'http://192.168.1.5:5000'; // ← غيّره حسب جهازك
}
