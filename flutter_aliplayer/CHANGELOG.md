## 5.4.3-dev.5
----------------------------------
1. 增加 Sei 、SubtitleHeader 接口调用 
2. 增加 FlutterAliPlayerFactory.loadRtsLibrary() 接口，(Android)
3. 修复 5.4.2 编译报错问题
4. 修复集成 Rts 低延时直播无法播放问题
5. 修复 AliPlayer、AliListPlayer、AliLiveShiftPlayer 依次创建后，先创建的对象失效问题

## 5.4.2
----------------------------------
阿里云播放器版本更新至：5.4.2.0
flutter_aliplayer_artc : ^5.4.2
flutter_rts : ^1.9.0

1. 增加直播时移功能(测试中)
2. 修复下载无法设置 region 问题
3. 重复创建 AliPlayer 对象，导致先创建的 AliPlayer 对象回调监听失效问题

## 5.4.0
----------------------------------
阿里云播放器版本更新至：5.4.0
flutter_aliplayer_artc : ^5.4.0
flutter_rts : ^1.6.0

1. 支持多个播放实例，具体可以参照demo代码`multiple_player_page.dart`
2. 播放器回调添加playerId参数，用于多实例调用的区分
3. 添加`setPlayerView`方法，创建播放器后，需要绑定view到播发器
4. 去除原列表播放器管道，在android和iOS源码层AliListPlayer与AliPlayer公用一个管道
5. `initService`、`getSDKVersion`以及log级别开关等方法改为静态方法，与原生sdk对齐

## 5.2.2
----------------------------------
1. Docking Aliyun Player SDK (PlatForm include Android、iOS)
2. RenderView: Android uses TextureView,iOS uses UIView

