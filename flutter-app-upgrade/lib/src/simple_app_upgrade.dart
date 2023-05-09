import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_upgrade/flutter_app_upgrade.dart';
import 'liquid_progress_indicator.dart';

/// 升级提示控件
class SimpleAppUpgradeWidget extends StatefulWidget {
  const SimpleAppUpgradeWidget({
    required this.title,
    this.titleStyle,
    required this.contents,
    this.contentStyle,
    this.cancelText,
    this.cancelTextStyle,
    this.okText,
    this.okTextStyle,
    this.okBackgroundColors,
    this.progressBar,
    this.progressBarColor,
    this.borderRadius = 10,
    this.downloadUrl,
    this.force = false,
    this.onCancel,
    this.onOk,
    this.downloading,
    this.downloadProgress,
    this.downloadStatusChange,
  });

  /// 升级标题
  final String title;

  /// 标题样式
  final TextStyle? titleStyle;

  ///
  /// 升级提示内容
  ///
  final List<String> contents;

  ///
  /// 提示内容样式
  ///
  final TextStyle? contentStyle;

  ///
  /// 下载进度条
  ///
  final Widget? progressBar;

  ///
  /// 进度条颜色
  ///
  final Color? progressBarColor;

  ///
  /// 确认控件
  ///
  final String? okText;

  ///
  /// 确认控件样式
  ///
  final TextStyle? okTextStyle;

  ///
  /// 确认控件背景颜色,2种颜色左到右线性渐变
  ///
  final List<Color>? okBackgroundColors;

  ///
  /// 取消控件
  ///
  final String? cancelText;

  ///
  /// 取消控件样式
  ///
  final TextStyle? cancelTextStyle;

  ///
  /// app安装包下载url,没有下载跳转到应用宝等渠道更新
  ///
  final String? downloadUrl;

  ///
  /// 圆角半径
  ///
  final double borderRadius;

  ///
  /// 是否强制升级,设置true没有取消按钮
  ///
  final bool force;
  final VoidCallback? onCancel;
  final VoidCallback? onOk;
  final VoidCallback? downloading;
  final DownloadProgressCallback? downloadProgress;
  final DownloadStatusChangeCallback? downloadStatusChange;

  @override
  State<StatefulWidget> createState() => _SimpleAppUpgradeWidget();
}

class _SimpleAppUpgradeWidget extends State<SimpleAppUpgradeWidget> {
  static final String _downloadApkName = 'temp.apk';
  static String path = '';

  /// 下载进度
  double _downloadProgress = 0.0;

  /// 下载状态
  DownloadStatus _downloadStatus = DownloadStatus.none;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _buildInfoWidget(context),
        _downloadProgress > 0 && _downloadProgress != 1
            ? Positioned.fill(
                child: GestureDetector(
                  onTap: () async {
                    if (_downloadStatus == DownloadStatus.downloading) {
                      widget.downloading?.call();
                    }
                  },
                  child: _buildDownloadProgress(),
                ),
              )
            : const SizedBox()
      ],
    );
  }

  ///
  /// 信息展示widget
  ///
  Widget _buildInfoWidget(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          //标题
          _buildTitle(),
          //更新信息
          _buildAppInfo(),
          //操作按钮
          _buildAction()
        ],
      ),
    );
  }

  ///
  /// 构建标题
  ///
  _buildTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: Text(
          _downloadStatus == DownloadStatus.done ? '下载完成' : widget.title,
          style: widget.titleStyle ?? TextStyle(fontSize: 20)),
    );
  }

  ///
  /// 构建版本更新信息
  ///
  _buildAppInfo() {
    return Container(
        padding: EdgeInsets.only(left: 15, right: 15, bottom: 10),
        constraints: BoxConstraints(maxHeight: 200, minHeight: 120),
        child: ListView(
          children: widget.contents.map((f) {
            return Text(
              f,
              style: widget.contentStyle ?? TextStyle(),
            );
          }).toList(),
        ));
  }

  ///
  /// 构建取消或者升级按钮
  ///
  _buildAction() {
    return Column(
      children: <Widget>[
        Divider(height: 1, color: Colors.grey),
        Row(
          children: <Widget>[
            widget.force
                ? const SizedBox()
                : Expanded(child: _buildCancelActionButton()),
            Expanded(child: _buildOkActionButton()),
          ],
        ),
      ],
    );
  }

  ///
  /// 取消按钮
  ///
  _buildCancelActionButton() {
    return Ink(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(widget.borderRadius))),
      child: InkWell(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(widget.borderRadius)),
          child: Container(
            height: 45,
            alignment: Alignment.center,
            child: Text(widget.cancelText ?? '以后再说',
                style: widget.cancelTextStyle ?? TextStyle()),
          ),
          onTap: () {
            widget.onCancel?.call();
            Navigator.of(context).pop();
          }),
    );
  }

  ///
  /// 确定按钮
  ///
  _buildOkActionButton() {
    var borderRadius =
        BorderRadius.only(bottomRight: Radius.circular(widget.borderRadius));
    if (widget.force) {
      borderRadius = BorderRadius.only(
        bottomRight: Radius.circular(widget.borderRadius),
        bottomLeft: Radius.circular(widget.borderRadius),
      );
    }
    var _okBackgroundColors = widget.okBackgroundColors;
    if (_okBackgroundColors == null || _okBackgroundColors.length != 2) {
      _okBackgroundColors = [
        Theme.of(context).primaryColor,
        Theme.of(context).primaryColor
      ];
    }
    return Ink(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_okBackgroundColors[0], _okBackgroundColors[1]],
        ),
        borderRadius: borderRadius,
      ),
      child: InkWell(
        borderRadius: borderRadius,
        child: Container(
          height: 45,
          alignment: Alignment.center,
          child: Text(
              widget.okText ??
                  (_downloadStatus == DownloadStatus.done ? '立即安装' : '立即体验'),
              style: widget.okTextStyle ?? TextStyle(color: Colors.white)),
        ),
        onTap: () => _clickOk(),
      ),
    );
  }

  /// 下载进度widget
  Widget _buildDownloadProgress() {
    return widget.progressBar ??
        LiquidLinearProgressIndicator(
          value: _downloadProgress,
          direction: Axis.vertical,
          valueColor: AlwaysStoppedAnimation(widget.progressBarColor ??
              Theme.of(context).primaryColor.withOpacity(0.4)),
          borderRadius: widget.borderRadius,
          borderColor: Colors.transparent,
          borderWidth: 0,
        );
  }

  /// 点击确定按钮
  _clickOk() async {
    widget.onOk?.call();
    if (Platform.isAndroid) {
      path = await FlutterUpgrade.apkDownloadPath;
      _downloadApk(widget.downloadUrl!, '$path/$_downloadApkName');
    }
  }

  /// 下载apk包
  _downloadApk(String url, String path) async {
    if (_downloadStatus == DownloadStatus.start ||
        _downloadStatus == DownloadStatus.downloading) {
      print('当前下载状态：$_downloadStatus,不能重复下载。');
    } else if (_downloadStatus == DownloadStatus.done) {
      FlutterUpgrade.installAppForAndroid(path);
    } else {
      _updateDownloadStatus(DownloadStatus.start);
      try {
        var dio = Dio();
        await dio.download(url, path,
            onReceiveProgress: (int count, int total) {
          if (total == -1) {
            _downloadProgress = 0.01;
          } else {
            widget.downloadProgress?.call(count, total);
            _downloadProgress = count / total.toDouble();
            _updateDownloadStatus(DownloadStatus.downloading);
          }
          setState(() {});
          //下载完成，跳转到程序安装界面
          if (_downloadProgress == 1) {
            _updateDownloadStatus(DownloadStatus.done);
            // Navigator.pop(context);
            FlutterUpgrade.installAppForAndroid(path);
          }
        });
      } catch (e) {
        print('$e');
        _downloadProgress = 0;
        Navigator.pop(context);
        _updateDownloadStatus(DownloadStatus.error, error: e);
      }
    }
  }

  _updateDownloadStatus(DownloadStatus downloadStatus, {dynamic error}) {
    _downloadStatus = downloadStatus;
    widget.downloadStatusChange?.call(_downloadStatus, error: error);
  }
}
