import 'dart:async';

import 'package:flutter/services.dart';

class FlutterUpgrade {
  static const MethodChannel _channel =
      const MethodChannel('flutter_app_upgrade');

  ///
  /// 获取apk下载路径
  ///
  static Future<String> get apkDownloadPath async {
    return await _channel.invokeMethod('getApkDownloadPath');
  }

  ///
  /// Android 安装app
  ///
  static installAppForAndroid(String path) async {
    var map = {'path': path};
    return await _channel.invokeMethod('install', map);
  }
}
