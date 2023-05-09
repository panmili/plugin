import 'aliplayer.dart';
import 'aliplayer_factory.dart';
import 'avpdef.dart';

class FlutterAliLiveShiftPlayer extends FlutterAliplayer {
  String playerId = 'liveShiftPlayerDefault';

  FlutterAliLiveShiftPlayer.init(String? id) : super.init(id);

  @override
  Future<void> create() {
    return FlutterAliPlayerFactory.methodChannel.invokeMethod('createAliPlayer',
        wrapWithPlayerId(arg: PlayerType.PlayerType_LiveShift));
  }

  Future<dynamic> getCurrentLiveTime() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getCurrentLiveTime', wrapWithPlayerId());
  }

  Future<dynamic> getCurrentTime() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getCurrentTime', wrapWithPlayerId());
  }

  Future<void> seekToLiveTime(int liveTime) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('seekToLiveTime', wrapWithPlayerId(arg: liveTime));
  }

  Future<void> setDataSource(String timeLineUrl, String url,
      {String? coverPath, String? format, String? title}) async {
    Map<String, dynamic> dataSourceMap = {
      'timeLineUrl': timeLineUrl,
      'url': url,
      'coverPath': coverPath,
      'format': format,
      'title': title
    };
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('setDataSource', wrapWithPlayerId(arg: dataSourceMap));
  }
}
