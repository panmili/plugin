import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'aliplayer_factory.dart';
import 'avpdef.dart';

typedef OnPrepared = void Function(String playerId);
typedef OnRenderingStart = void Function(String playerId);
typedef OnVideoSizeChanged = void Function(
    int width, int height, String playerId);

typedef OnSeekComplete = void Function(String playerId);
typedef OnSeiData = void Function(int type, String data, String playerId);

typedef OnLoadingBegin = void Function(String playerId);
typedef OnLoadingProgress = void Function(
    int percent, double netSpeed, String playerId);
typedef OnLoadingEnd = void Function(String playerId);

typedef OnStateChanged = void Function(int newState, String playerId);

typedef OnSubtitleExtAdded = void Function(
    int trackIndex, String url, String playerId);
typedef OnSubtitleShow = void Function(
    int trackIndex, int subtitleID, String subtitle, String playerId);
typedef OnSubtitleHide = void Function(
    int trackIndex, int subtitleID, String playerId);
typedef OnSubtitleHeader = void Function(
    int trackIndex, String head, String playerId);
typedef OnTrackReady = void Function(String playerId);

typedef OnInfo = void Function(
    int infoCode, int extraValue, String extraMsg, String playerId);
typedef OnError = void Function(
    int errorCode, String errorExtra, String errorMsg, String playerId);
typedef OnCompletion = void Function(String playerId);

typedef OnTrackChanged = void Function(dynamic value, String playerId);

typedef OnThumbnailPreparedSuccess = void Function(String playerId);
typedef OnThumbnailPreparedFail = void Function(String playerId);

typedef OnThumbnailGetSuccess = void Function(
    Uint8List bitmap, Int64List range, String playerId);
typedef OnThumbnailGetFail = void Function(String playerId);

typedef OnSeekLiveCompletion = void Function(int playTime, String playerId);
typedef OnTimeShiftUpdater = void Function(
    int currentTime, int shiftStartTime, int shiftEndTime, String playerId);

class FlutterAliplayer {
  OnLoadingBegin? onLoadingBegin;
  OnLoadingProgress? onLoadingProgress;
  OnLoadingEnd? onLoadingEnd;
  OnPrepared? onPrepared;
  OnRenderingStart? onRenderingStart;
  OnVideoSizeChanged? onVideoSizeChanged;
  OnSeekComplete? onSeekComplete;
  OnStateChanged? onStateChanged;
  OnInfo? onInfo;
  OnCompletion? onCompletion;
  OnTrackReady? onTrackReady;
  OnError? onError;
  OnSeiData? onSeiData;

  OnTrackChanged? onTrackChanged;
  OnThumbnailPreparedSuccess? onThumbnailPreparedSuccess;
  OnThumbnailPreparedFail? onThumbnailPreparedFail;

  OnThumbnailGetSuccess? onThumbnailGetSuccess;
  OnThumbnailGetFail? onThumbnailGetFail;

  //外挂字幕
  OnSubtitleExtAdded? onSubtitleExtAdded;
  OnSubtitleHide? onSubtitleHide;
  OnSubtitleShow? onSubtitleShow;
  OnSubtitleHeader? onSubtitleHeader;

  //直播时移
  OnSeekLiveCompletion? onSeekLiveCompletion;
  OnTimeShiftUpdater? onTimeShiftUpdater;

  // static MethodChannel channel = new MethodChannel('flutter_aliplayer');
  EventChannel eventChannel = EventChannel("flutter_aliplayer_event");

  String playerId = 'default';

  FlutterAliplayer.init(String? id) {
    if (id != null) {
      playerId = id;
    }
    FlutterAliPlayerFactory.instanceMap[playerId] = this;
    register();
  }

  void register() {
    eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  void setOnPrepared(OnPrepared prepared) {
    this.onPrepared = prepared;
  }

  void setOnRenderingStart(OnRenderingStart renderingStart) {
    this.onRenderingStart = renderingStart;
  }

  void setOnVideoSizeChanged(OnVideoSizeChanged videoSizeChanged) {
    this.onVideoSizeChanged = videoSizeChanged;
  }

  void setOnSeekComplete(OnSeekComplete seekComplete) {
    this.onSeekComplete = seekComplete;
  }

  void setOnError(OnError onError) {
    this.onError = onError;
  }

  void setOnSeiData(OnSeiData seiData) {
    this.onSeiData = seiData;
  }

  void setOnLoadingStatusListener(
      {required OnLoadingBegin loadingBegin,
      required OnLoadingProgress loadingProgress,
      required OnLoadingEnd loadingEnd}) {
    this.onLoadingBegin = loadingBegin;
    this.onLoadingProgress = loadingProgress;
    this.onLoadingEnd = loadingEnd;
  }

  void setOnStateChanged(OnStateChanged stateChanged) {
    this.onStateChanged = stateChanged;
  }

  void setOnInfo(OnInfo info) {
    this.onInfo = info;
  }

  void setOnCompletion(OnCompletion completion) {
    this.onCompletion = completion;
  }

  void setOnTrackReady(OnTrackReady onTrackReady) {
    this.onTrackReady = onTrackReady;
  }

  void setOnTrackChanged(OnTrackChanged onTrackChanged) {
    this.onTrackChanged = onTrackChanged;
  }

  void setOnThumbnailPreparedListener(
      {required OnThumbnailPreparedSuccess preparedSuccess,
      required OnThumbnailPreparedFail preparedFail}) {
    this.onThumbnailPreparedSuccess = preparedSuccess;
    this.onThumbnailPreparedFail = preparedFail;
  }

  void setOnThumbnailGetListener(
      {required OnThumbnailGetSuccess onThumbnailGetSuccess,
      required OnThumbnailGetFail onThumbnailGetFail}) {
    this.onThumbnailGetSuccess = onThumbnailGetSuccess;
    this.onThumbnailGetSuccess = onThumbnailGetSuccess;
  }

  void setOnSubtitleShow(OnSubtitleShow onSubtitleShow) {
    this.onSubtitleShow = onSubtitleShow;
  }

  void setOnSubtitleHide(OnSubtitleHide onSubtitleHide) {
    this.onSubtitleHide = onSubtitleHide;
  }

  void setOnSubtitleHeader(OnSubtitleHeader onSubtitleHeader) {
    this.onSubtitleHeader = onSubtitleHeader;
  }

  void setOnSubtitleExtAdded(OnSubtitleExtAdded onSubtitleExtAdded) {
    this.onSubtitleExtAdded = onSubtitleExtAdded;
  }

  void setOnSeekLiveCompletion(OnSeekLiveCompletion seekLiveCompletion) {
    this.onSeekLiveCompletion = seekLiveCompletion;
  }

  void setOnTimeShiftUpdater(OnTimeShiftUpdater timeShiftUpdater) {
    this.onTimeShiftUpdater = timeShiftUpdater;
  }

  ///接口部分
  wrapWithPlayerId({arg = ''}) {
    var map = {"arg": arg, "playerId": this.playerId.toString()};
    return map;
  }

  Future<void> create() async {
    return FlutterAliPlayerFactory.methodChannel.invokeMethod(
        'createAliPlayer', wrapWithPlayerId(arg: PlayerType.PlayerType_Single));
  }

  Future<void> setPlayerView(int viewId) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('setPlayerView', wrapWithPlayerId(arg: viewId));
  }

  Future<void> setUrl(String url) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('setUrl', wrapWithPlayerId(arg: url));
  }

  Future<void> prepare() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('prepare', wrapWithPlayerId());
  }

  Future<void> play() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('play', wrapWithPlayerId());
  }

  Future<void> pause() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('pause', wrapWithPlayerId());
  }

  Future<dynamic> snapshot(String path) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('snapshot', wrapWithPlayerId(arg: path));
  }

  Future<void> stop() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('stop', wrapWithPlayerId());
  }

  Future<void> destroy() async {
    FlutterAliPlayerFactory.instanceMap.remove(playerId);
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('destroy', wrapWithPlayerId());
  }

  Future<void> seekTo(int position, int seekMode) async {
    var map = {"position": position, "seekMode": seekMode};
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("seekTo", wrapWithPlayerId(arg: map));
  }

  Future<dynamic> isLoop() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('isLoop', wrapWithPlayerId());
  }

  Future<void> setLoop(bool isloop) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('setLoop', wrapWithPlayerId(arg: isloop));
  }

  Future<dynamic> isAutoPlay() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('isAutoPlay', wrapWithPlayerId());
  }

  Future<void> setAutoPlay(bool isAutoPlay) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('setAutoPlay', wrapWithPlayerId(arg: isAutoPlay));
  }

  Future<dynamic> isMuted() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('isMuted', wrapWithPlayerId());
  }

  Future<void> setMuted(bool isMuted) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('setMuted', wrapWithPlayerId(arg: isMuted));
  }

  Future<dynamic> enableHardwareDecoder() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('enableHardwareDecoder', wrapWithPlayerId());
  }

  Future<void> setEnableHardwareDecoder(bool isHardWare) async {
    return FlutterAliPlayerFactory.methodChannel.invokeMethod(
        'setEnableHardwareDecoder', wrapWithPlayerId(arg: isHardWare));
  }

  Future<void> setVidSts(
      {String? vid,
      String? region,
      String? accessKeyId,
      String? accessKeySecret,
      String? securityToken,
      String? previewTime,
      List<String>? definitionList,
      playerId}) async {
    Map<String, dynamic> stsInfo = {
      "vid": vid,
      "region": region,
      "accessKeyId": accessKeyId,
      "accessKeySecret": accessKeySecret,
      "securityToken": securityToken,
      "definitionList": definitionList,
      "previewTime": previewTime
    };
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setVidSts", wrapWithPlayerId(arg: stsInfo));
  }

  Future<void> setVidAuth(
      {String? vid,
      String? region,
      String? playAuth,
      String? previewTime,
      List<String>? definitionList,
      playerId}) async {
    Map<String, dynamic> authInfo = {
      "vid": vid,
      "region": region,
      "playAuth": playAuth,
      "definitionList": definitionList,
      "previewTime": previewTime
    };
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setVidAuth", wrapWithPlayerId(arg: authInfo));
  }

  Future<void> setVidMps(Map<String, dynamic> mpsInfo) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setVidMps", wrapWithPlayerId(arg: mpsInfo));
  }

  Future<dynamic> getRotateMode() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getRotateMode', wrapWithPlayerId());
  }

  Future<void> setRotateMode(int mode) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('setRotateMode', wrapWithPlayerId(arg: mode));
  }

  Future<dynamic> getScalingMode() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getScalingMode', wrapWithPlayerId());
  }

  Future<void> setScalingMode(int mode) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('setScalingMode', wrapWithPlayerId(arg: mode));
  }

  Future<dynamic> getMirrorMode() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getMirrorMode', wrapWithPlayerId());
  }

  Future<void> setMirrorMode(int mode) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('setMirrorMode', wrapWithPlayerId(arg: mode));
  }

  Future<dynamic> getRate() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getRate', wrapWithPlayerId());
  }

  Future<void> setRate(double mode) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('setRate', wrapWithPlayerId(arg: mode));
  }

  Future<void> setVideoBackgroundColor(var color) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('setVideoBackgroundColor', wrapWithPlayerId(arg: color));
  }

  Future<void> setVolume(double volume) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('setVolume', wrapWithPlayerId(arg: volume));
  }

  Future<dynamic> getVolume() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getVolume', wrapWithPlayerId());
  }

  Future<dynamic> getDuration() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getDuration', wrapWithPlayerId());
  }

  Future<dynamic> getVideoWidth() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getVideoWidth', wrapWithPlayerId());
  }

  Future<dynamic> getVideoHeight() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getVideoHeight', wrapWithPlayerId());
  }

  Future<dynamic> getConfig() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("getConfig", wrapWithPlayerId());
  }

  Future<void> setConfig(Map map) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setConfig", wrapWithPlayerId(arg: map));
  }

  Future<dynamic> getCacheConfig() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("getCacheConfig", wrapWithPlayerId());
  }

  Future<void> setCacheConfig(Map map) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setCacheConfig", wrapWithPlayerId(arg: map));
  }

  Future<dynamic> getMediaInfo() {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("getMediaInfo", wrapWithPlayerId());
  }

  Future<dynamic> getCurrentTrack(int trackIdx) {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("getCurrentTrack", wrapWithPlayerId(arg: trackIdx));
  }

  Future<dynamic> createThumbnailHelper(String thumbnail) {
    return FlutterAliPlayerFactory.methodChannel.invokeMethod(
        "createThumbnailHelper", wrapWithPlayerId(arg: thumbnail));
  }

  Future<dynamic> requestBitmapAtPosition(int position) {
    return FlutterAliPlayerFactory.methodChannel.invokeMethod(
        "requestBitmapAtPosition", wrapWithPlayerId(arg: position));
  }

  Future<void> addExtSubtitle(String url) {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("addExtSubtitle", wrapWithPlayerId(arg: url));
  }

  Future<void> selectExtSubtitle(int trackIndex, bool enable) {
    var map = {'trackIndex': trackIndex, 'enable': enable};
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("selectExtSubtitle", wrapWithPlayerId(arg: map));
  }

  // accurate 0 为不精确  1 为精确  不填为忽略
  Future<void> selectTrack(
    int trackIdx, {
    int accurate = -1,
  }) {
    var map = {
      'trackIdx': trackIdx,
      'accurate': accurate,
    };
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("selectTrack", wrapWithPlayerId(arg: map));
  }

  Future<void> setPrivateService(Int8List data) {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setPrivateService", data);
  }

  Future<void> setPreferPlayerName(String playerName) {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setPreferPlayerName", wrapWithPlayerId(arg: playerName));
  }

  Future<dynamic> getPlayerName() {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("getPlayerName", wrapWithPlayerId());
  }

  Future<void> setStreamDelayTime(int trackIdx, int time) {
    var map = {'index': trackIdx, 'time': time};
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setStreamDelayTime", map);
  }

  ///静态方法
  static Future<dynamic> getSDKVersion() async {
    return FlutterAliPlayerFactory.methodChannel.invokeMethod("getSDKVersion");
  }

  static Future<void> enableMix(bool enable) {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("enableMix", {'arg': enable});
  }

  static Future<void> enableConsoleLog(bool enable) {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("enableConsoleLog", {'arg': enable});
  }

  static Future<void> setLogLevel(int level) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setLogLevel", {'arg': level});
  }

  static Future<dynamic> getLogLevel() {
    return FlutterAliPlayerFactory.methodChannel.invokeMethod(
      "getLogLevel",
    );
  }

  ///return deviceInfo
  static Future<dynamic> createDeviceInfo() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("createDeviceInfo");
  }

  ///type : {FlutterAvpdef.BLACK_DEVICES_H264 / FlutterAvpdef.BLACK_DEVICES_HEVC}
  static Future<void> addBlackDevice(String type, String model) async {
    var map = {
      'black_type': type,
      'black_device': model,
    };
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("addBlackDevice", map);
  }

  ///回调分发
  void _onEvent(dynamic event) {
    String method = event[EventChanneldef.TYPE_KEY];
    String playerId = event['playerId'] ?? '';
    FlutterAliplayer player =
        FlutterAliPlayerFactory.instanceMap[playerId] ?? this;
    switch (method) {
      case "onPrepared":
        if (player.onPrepared != null) {
          player.onPrepared!(playerId);
        }
        break;
      case "onRenderingStart":
        if (player.onRenderingStart != null) {
          player.onRenderingStart!(playerId);
        }
        break;
      case "onVideoSizeChanged":
        if (player.onVideoSizeChanged != null) {
          int width = event['width'];
          int height = event['height'];
          player.onVideoSizeChanged!(width, height, playerId);
        }
        break;
      case "onChangedSuccess":
        break;
      case "onChangedFail":
        break;
      case "onSeekComplete":
        if (player.onSeekComplete != null) {
          player.onSeekComplete!(playerId);
        }
        break;
      case "onSeiData":
        if (player.onSeiData != null) {
          String data = event['data'];
          int type = event['type'];
          player.onSeiData!(type, data, playerId);
        }
        break;
      case "onLoadingBegin":
        if (player.onLoadingBegin != null) {
          player.onLoadingBegin!(playerId);
        }
        break;
      case "onLoadingProgress":
        int percent = event['percent'];
        double netSpeed = event['netSpeed'] ?? 0;
        if (player.onLoadingProgress != null) {
          player.onLoadingProgress!(percent, netSpeed, playerId);
        }
        break;
      case "onLoadingEnd":
        if (player.onLoadingEnd != null) {
          player.onLoadingEnd!(playerId);
        }
        break;
      case "onStateChanged":
        if (player.onStateChanged != null) {
          int newState = event['newState'] ?? -1;
          player.onStateChanged!(newState, playerId);
        }
        break;
      case "onInfo":
        if (player.onInfo != null) {
          int infoCode = event['infoCode'] ?? -1;
          int extraValue = event['extraValue'] ?? 0;
          String extraMsg = event['extraMsg'] ?? '';
          player.onInfo!(infoCode, extraValue, extraMsg, playerId);
        }
        break;
      case "onError":
        if (player.onError != null) {
          int errorCode = event['errorCode'];
          String errorExtra = event['errorExtra'] ?? '';
          String errorMsg = event['errorMsg'];
          player.onError!(errorCode, errorExtra, errorMsg, playerId);
        }
        break;
      case "onCompletion":
        if (player.onCompletion != null) {
          player.onCompletion!(playerId);
        }
        break;
      case "onTrackReady":
        if (player.onTrackReady != null) {
          player.onTrackReady!(playerId);
        }
        break;
      case "onTrackChanged":
        if (player.onTrackChanged != null) {
          dynamic info = event['info'];
          player.onTrackChanged!(info, playerId);
        }
        break;
      case "thumbnail_onPrepared_Success":
        if (player.onThumbnailPreparedSuccess != null) {
          player.onThumbnailPreparedSuccess!(playerId);
        }
        break;
      case "thumbnail_onPrepared_Fail":
        if (player.onThumbnailPreparedFail != null) {
          player.onThumbnailPreparedFail!(playerId);
        }
        break;
      case "onThumbnailGetSuccess":
        dynamic bitmap = event['thumbnailbitmap'];
        dynamic range = event['thumbnailRange'];
        if (player.onThumbnailGetSuccess != null) {
          if (Platform.isIOS) {
            range = Int64List.fromList(range.cast<int>());
          }
          player.onThumbnailGetSuccess!(bitmap, range, playerId);
        }
        break;
      case "onThumbnailGetFail":
        if (player.onThumbnailGetFail != null) {
          player.onThumbnailGetFail!(playerId);
        }
        break;
      case "onSubtitleExtAdded":
        if (player.onSubtitleExtAdded != null) {
          int trackIndex = event['trackIndex'];
          String url = event['url'];
          player.onSubtitleExtAdded!(trackIndex, url, playerId);
        }
        break;
      case "onSubtitleShow":
        if (player.onSubtitleShow != null) {
          int trackIndex = event['trackIndex'];
          int subtitleID = event['subtitleID'];
          String subtitle = event['subtitle'];
          player.onSubtitleShow!(trackIndex, subtitleID, subtitle, playerId);
        }
        break;
      case "onSubtitleHide":
        if (player.onSubtitleHide != null) {
          int trackIndex = event['trackIndex'];
          int subtitleID = event['subtitleID'];
          player.onSubtitleHide!(trackIndex, subtitleID, playerId);
        }
        break;
      case "onSubtitleHeader":
        if (player.onSubtitleHeader != null) {
          int trackIndex = event['trackIndex'];
          String header = event['header'];
          player.onSubtitleHeader!(trackIndex, header, playerId);
        }
        break;
      case "onUpdater":
        if (player.onTimeShiftUpdater != null) {
          var currentTime = event['currentTime'];
          var shiftStartTime = event['shiftStartTime'];
          var shiftEndTime = event['shiftEndTime'];
          player.onTimeShiftUpdater!(
              currentTime, shiftStartTime, shiftEndTime, playerId);
        }
        break;
      case "onSeekLiveCompletion":
        if (player.onSeekLiveCompletion != null) {
          var playTime = event['playTime'];
          player.onSeekLiveCompletion!(playTime, playerId);
        }
    }
  }

  void _onError(dynamic error) {}
}

typedef void AliPlayerViewCreatedCallback(int viewId);

class AliPlayerView extends StatefulWidget {
  final AliPlayerViewCreatedCallback? onCreated;
  final x;
  final y;
  final width;
  final height;

  AliPlayerView({
    Key? key,
    @required required this.onCreated,
    @required this.x,
    @required this.y,
    @required this.width,
    @required this.height,
  });

  @override
  State<StatefulWidget> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<AliPlayerView> {
  @override
  void initState() {
    super.initState();
    // print("abc : create PlatFormView initState");
  }

  @override
  Widget build(BuildContext context) {
    // print("abc : create PlatFormView build");
    return nativeView();
  }

  nativeView() {
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: 'flutter_aliplayer_render_view',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: <String, dynamic>{
          "x": widget.x,
          "y": widget.y,
          "width": widget.width,
          "height": widget.height,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return UiKitView(
        viewType: 'plugins.flutter_aliplayer',
        // viewType: 'flutter_aliplayer_render_view',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: <String, dynamic>{
          "x": widget.x,
          "y": widget.y,
          "width": widget.width,
          "height": widget.height,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
  }

  Future<void> _onPlatformViewCreated(id) async {
    if (widget.onCreated != null) {
      widget.onCreated!(id);
    }
  }
}
