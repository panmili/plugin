package com.alibaba.fplayer.flutter_aliplayer;

import android.content.Context;
import android.graphics.Bitmap;
import android.text.TextUtils;

import com.aliyun.player.AliListPlayer;
import com.aliyun.player.AliPlayerFactory;
import com.aliyun.player.IPlayer;
import com.aliyun.player.bean.ErrorInfo;
import com.aliyun.player.bean.InfoBean;
import com.aliyun.player.nativeclass.CacheConfig;
import com.aliyun.player.nativeclass.MediaInfo;
import com.aliyun.player.nativeclass.PlayerConfig;
import com.aliyun.player.nativeclass.Thumbnail;
import com.aliyun.player.nativeclass.TrackInfo;
import com.aliyun.player.source.StsInfo;
import com.aliyun.player.source.UrlSource;
import com.aliyun.player.source.VidAuth;
import com.aliyun.player.source.VidMps;
import com.aliyun.player.source.VidSts;
import com.aliyun.thumbnail.ThumbnailBitmapInfo;
import com.aliyun.thumbnail.ThumbnailHelper;
import com.aliyun.utils.ThreadManager;
import com.google.gson.Gson;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class FlutterAliListPlayer extends FlutterPlayerBase implements EventChannel.StreamHandler{

    private FlutterPlugin.FlutterPluginBinding mFlutterPluginBinding;

    private final Gson mGson;
    private Context mContext;
    private EventChannel.EventSink mEventSink;
    private EventChannel mEventChannel;
    private AliListPlayer mAliListPlayer;
    private ThumbnailHelper mThumbnailHelper;
    private Map<Integer, FlutterAliPlayerView> mFlutterAliPlayerViewMap;

    public FlutterAliListPlayer(FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        this.mFlutterPluginBinding = flutterPluginBinding;
        this.mContext = flutterPluginBinding.getApplicationContext();
        mGson = new Gson();
        mAliListPlayer = AliPlayerFactory.createAliListPlayer(flutterPluginBinding.getApplicationContext());
//        MethodChannel mAliListPlayerMethodChannel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(),"flutter_alilistplayer");
//        mAliListPlayerMethodChannel.setMethodCallHandler(this);
        mEventChannel = new EventChannel(mFlutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutter_aliplayer_event");
        mEventChannel.setStreamHandler(this);
        initListener(mAliListPlayer);
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        this.mEventSink = events;
    }

    @Override
    public void onCancel(Object arguments) {
    }

    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        switch (methodCall.method) {
            case "setPreloadCount":
                Integer count = (Integer) methodCall.argument("arg");
                setPreloadCount(count);
                result.success(null);
                break;
            case "setPlayerView":
//                Integer viewId = (Integer) methodCall.argument("arg");
//                FlutterAliPlayerView flutterAliPlayerView = mFlutterAliPlayerViewMap.get(viewId);
//                if(flutterAliPlayerView != null){
//                    flutterAliPlayerView.setPlayer(mAliListPlayer);
//                }
                break;
            case "prepare":
                prepare();
                result.success(null);
                break;
            case "play":
                start();
                result.success(null);
                break;
            case "pause":
                pause();
                result.success(null);
                break;
            case "stop":
                stop();
                result.success(null);
                break;
            case "destroy":
                release();
                result.success(null);
                break;
            case "seekTo":
            {
                Map<String,Object> seekToMap = (Map<String,Object>)methodCall.argument("arg");
                Integer position = (Integer) seekToMap.get("position");
                Integer seekMode = (Integer) seekToMap.get("seekMode");
                seekTo(position,seekMode);
                result.success(null);
            }
            break;
            case "getMediaInfo":
            {
                MediaInfo mediaInfo = getMediaInfo();
                if(mediaInfo != null){
                    Map<String,Object> getMediaInfoMap = new HashMap<>();
                    getMediaInfoMap.put("title",mediaInfo.getTitle());
                    getMediaInfoMap.put("status",mediaInfo.getStatus());
                    getMediaInfoMap.put("mediaType",mediaInfo.getMediaType());
                    getMediaInfoMap.put("duration",mediaInfo.getDuration());
                    getMediaInfoMap.put("transcodeMode",mediaInfo.getTransCodeMode());
                    getMediaInfoMap.put("coverURL",mediaInfo.getCoverUrl());
                    List<Thumbnail> thumbnail = mediaInfo.getThumbnailList();
                    List<Map<String,Object>> thumbailList = new ArrayList<>();
                    for (Thumbnail thumb : thumbnail) {
                        Map<String,Object> map = new HashMap<>();
                        map.put("url",thumb.mURL);
                        thumbailList.add(map);
                        getMediaInfoMap.put("thumbnails",thumbailList);
                    }
                    List<TrackInfo> trackInfos = mediaInfo.getTrackInfos();
                    List<Map<String,Object>> trackInfoList = new ArrayList<>();
                    for (TrackInfo trackInfo : trackInfos) {
                        Map<String,Object> map = new HashMap<>();
                        map.put("vodFormat",trackInfo.getVodFormat());
                        map.put("videoHeight",trackInfo.getVideoHeight());
                        map.put("videoWidth",trackInfo.getVideoWidth());
                        map.put("subtitleLanguage",trackInfo.getSubtitleLang());
                        map.put("trackBitrate",trackInfo.getVideoBitrate());
                        map.put("vodFileSize",trackInfo.getVodFileSize());
                        map.put("trackIndex",trackInfo.getIndex());
                        map.put("trackDefinition",trackInfo.getVodDefinition());
                        map.put("audioSampleFormat",trackInfo.getAudioSampleFormat());
                        map.put("audioLanguage",trackInfo.getAudioLang());
                        map.put("vodPlayUrl",trackInfo.getVodPlayUrl());
                        map.put("trackType",trackInfo.getType().ordinal());
                        map.put("audioSamplerate",trackInfo.getAudioSampleRate());
                        map.put("audioChannels",trackInfo.getAudioChannels());
                        trackInfoList.add(map);
                        getMediaInfoMap.put("tracks",trackInfoList);
                    }
                    result.success(getMediaInfoMap);
                }
            }
            break;
            case "snapshot":
                mSnapShotPath = methodCall.argument("arg").toString();
                snapshot();
                result.success(null);
                break;
            case "setLoop":
                setLoop((Boolean)methodCall.argument("arg"));
                result.success(null);
                break;
            case "isLoop":
                result.success(isLoop());
                break;
            case "setAutoPlay":
                setAutoPlay((Boolean)methodCall.argument("arg"));
                result.success(null);
                break;
            case "isAutoPlay":
                result.success(isAutoPlay());
                break;
            case "setMuted":
                setMuted((Boolean)methodCall.argument("arg"));
                result.success(null);
                break;
            case "isMuted":
                result.success(isMuted());
                break;
            case "setEnableHardwareDecoder":
                Boolean setEnableHardwareDecoderArgumnt = (Boolean) methodCall.argument("arg");
                setEnableHardWareDecoder(setEnableHardwareDecoderArgumnt);
                result.success(null);
                break;
            case "setScalingMode":
                setScaleMode((Integer) methodCall.argument("arg"));
                result.success(null);
                break;
            case "getScalingMode":
                result.success(getScaleMode());
                break;
            case "setMirrorMode":
                setMirrorMode((Integer) methodCall.argument("arg"));
                result.success(null);
                break;
            case "getMirrorMode":
                result.success(getMirrorMode());
                break;
            case "setRotateMode":
                setRotateMode((Integer) methodCall.argument("arg"));
                result.success(null);
                break;
            case "getRotateMode":
                result.success(getRotateMode());
                break;
            case "setRate":
                setSpeed((Double) methodCall.argument("arg"));
                result.success(null);
                break;
            case "getRate":
                result.success(getSpeed());
                break;
            case "setVideoBackgroundColor":
                setVideoBackgroundColor((Integer) methodCall.argument("arg"));
                result.success(null);
                break;
            case "setVolume":
                setVolume((Double) methodCall.argument("arg"));
                result.success(null);
                break;
            case "getVolume":
                result.success(getVolume());
                break;
            case "getDuration":
                result.success(getDuration());
                break;
            case "getVideoWidth":
                result.success(getVideoWidth());
                break;
            case "getVideoHeight":
                result.success(getVideoHeight());
                break;
            case "setConfig":
            {
                Map<String,Object> setConfigMap = (Map<String, Object>) methodCall.argument("arg");
                PlayerConfig config = getConfig();
                if(config != null){
                    String configJson = mGson.toJson(setConfigMap);
                    config = mGson.fromJson(configJson,PlayerConfig.class);
                    setConfig(config);
                }
                result.success(null);
            }
            break;
            case "getConfig":
                PlayerConfig config = getConfig();
                String json = mGson.toJson(config);
                Map<String,Object> configMap = mGson.fromJson(json,Map.class);
                result.success(configMap);
                break;
            case "getCacheConfig":
                CacheConfig cacheConfig = getCacheConfig();
                String cacheConfigJson = mGson.toJson(cacheConfig);
                Map<String,Object> cacheConfigMap = mGson.fromJson(cacheConfigJson,Map.class);
                result.success(cacheConfigMap);
                break;
            case "setCacheConfig":
                Map<String,Object> setCacheConnfigMap = (Map<String, Object>) methodCall.argument("arg");
                String setCacheConfigJson = mGson.toJson(setCacheConnfigMap);
                CacheConfig setCacheConfig = mGson.fromJson(setCacheConfigJson,CacheConfig.class);
                setCacheConfig(setCacheConfig);
                result.success(null);
                break;
            case "getCurrentTrack":
                Integer currentTrackIndex = (Integer) methodCall.argument("arg");
                TrackInfo currentTrack = getCurrentTrack(currentTrackIndex);
                if(currentTrack != null){
                    Map<String,Object> map = new HashMap<>();
                    map.put("vodFormat",currentTrack.getVodFormat());
                    map.put("videoHeight",currentTrack.getVideoHeight());
                    map.put("videoWidth",currentTrack.getVideoWidth());
                    map.put("subtitleLanguage",currentTrack.getSubtitleLang());
                    map.put("trackBitrate",currentTrack.getVideoBitrate());
                    map.put("vodFileSize",currentTrack.getVodFileSize());
                    map.put("trackIndex",currentTrack.getIndex());
                    map.put("trackDefinition",currentTrack.getVodDefinition());
                    map.put("audioSampleFormat",currentTrack.getAudioSampleFormat());
                    map.put("audioLanguage",currentTrack.getAudioLang());
                    map.put("vodPlayUrl",currentTrack.getVodPlayUrl());
                    map.put("trackType",currentTrack.getType().ordinal());
                    map.put("audioSamplerate",currentTrack.getAudioSampleRate());
                    map.put("audioChannels",currentTrack.getAudioChannels());
                    result.success(map);
                }
                break;
            case "selectTrack":
                Map<String,Object> selectTrackMap = (Map<String, Object>) methodCall.argument("arg");
                Integer trackIdx = (Integer) selectTrackMap.get("trackIdx");
                Integer accurate = (Integer) selectTrackMap.get("accurate");
                selectTrack(trackIdx, accurate == 1);
                result.success(null);
                break;
            case "addExtSubtitle":
                String extSubtitlUrl = (String) methodCall.arguments;
                addExtSubtitle(extSubtitlUrl);
                result.success(null);
                break;
            case "selectExtSubtitle":
                Map<String,Object> selectExtSubtitleMap = (Map<String, Object>) methodCall.argument("arg");
                Integer trackIndex = (Integer) selectExtSubtitleMap.get("trackIndex");
                Boolean selectExtSubtitlEnable = (Boolean) selectExtSubtitleMap.get("enable");
                selectExtSubtitle(trackIndex,selectExtSubtitlEnable);
                result.success(null);
                break;
            case "addVidSource":
                Map<String,Object> addVidSourceMap = methodCall.argument("arg");
                String addSourceVid = (String) addVidSourceMap.get("vid");
                String vidUid = (String) addVidSourceMap.get("uid");
                addVidSource(addSourceVid,vidUid);
                result.success(null);
                break;
            case "addUrlSource":
                Map<String,Object> addSourceUrlMap = methodCall.argument("arg");
                String addSourceUrl = (String) addSourceUrlMap.get("url");
                String urlUid = (String) addSourceUrlMap.get("uid");
                addUrlSource(addSourceUrl,urlUid);
                result.success(null);
                break;
            case "removeSource":
                // String removeUid = methodCall.arguments("arg");
                removeSource((String) methodCall.argument("arg"));
                result.success(null);
                break;
            case "clear":
                clear();
                result.success(null);
                break;
            case "moveToNext":
                Map<String,Object> moveToNextMap = methodCall.argument("arg");
                String moveToNextAccessKeyId = (String) moveToNextMap.get("accId");
                String moveToNextAccessKeySecret = (String) moveToNextMap.get("accKey");
                String moveToNextSecurityToken = (String) moveToNextMap.get("token");
                String moveToNextRegion = (String) moveToNextMap.get("region");
                StsInfo moveToNextStsInfo = new StsInfo();
                moveToNextStsInfo.setAccessKeyId(moveToNextAccessKeyId);
                moveToNextStsInfo.setAccessKeySecret(moveToNextAccessKeySecret);
                moveToNextStsInfo.setSecurityToken(moveToNextSecurityToken);
                moveToNextStsInfo.setRegion(moveToNextRegion);
                moveToNext(moveToNextStsInfo);
                result.success(null);
                break;
            case "moveToPre":
                Map<String,Object> moveToPreMap = methodCall.argument("arg");
                String moveToPreAccessKeyId = (String) moveToPreMap.get("accId");
                String moveToPreAccessKeySecret = (String) moveToPreMap.get("accKey");
                String moveToPreSecurityToken = (String) moveToPreMap.get("token");
                String moveToPreRegion = (String) moveToPreMap.get("region");
                StsInfo moveToPreStsInfo = new StsInfo();
                moveToPreStsInfo.setAccessKeyId(moveToPreAccessKeyId);
                moveToPreStsInfo.setAccessKeySecret(moveToPreAccessKeySecret);
                moveToPreStsInfo.setSecurityToken(moveToPreSecurityToken);
                moveToPreStsInfo.setRegion(moveToPreRegion);
                moveToPre(moveToPreStsInfo);
                result.success(null);
                break;
            case "moveTo":
                Map<String,Object> moveToMap = methodCall.argument("arg");
                String moveToAccessKeyId = (String) moveToMap.get("accId");
                String moveToAccessKeySecret = (String) moveToMap.get("accKey");
                String moveToSecurityToken = (String) moveToMap.get("token");
                String moveToRegion = (String) moveToMap.get("region");
                String moveToUid = (String) moveToMap.get("uid");
                if(!TextUtils.isEmpty(moveToAccessKeyId)){
                    StsInfo moveToStsInfo = new StsInfo();
                    moveToStsInfo.setAccessKeyId(moveToAccessKeyId);
                    moveToStsInfo.setAccessKeySecret(moveToAccessKeySecret);
                    moveToStsInfo.setSecurityToken(moveToSecurityToken);
                    moveToStsInfo.setRegion(moveToRegion);
                    moveTo(moveToUid,moveToStsInfo);
                }else{
                    moveTo(moveToUid);
                }
                result.success(null);

                break;
            case "createThumbnailHelper":
                String thhumbnailUrl = (String) methodCall.argument("arg");
                createThumbnailHelper(thhumbnailUrl);
                result.success(null);
                break;
            case "requestBitmapAtPosition":
                Integer requestBitmapProgress = (Integer) methodCall.argument("arg");
                requestBitmapAtPosition(requestBitmapProgress);
                result.success(null);
                break;
            default:
                result.notImplemented();
        }
    }

    public IPlayer getAliPlayer(){
        return mAliListPlayer;
    }

    private void setPreloadCount(int count){
        if(mAliListPlayer != null){
            mAliListPlayer.setPreloadCount(count);
        }
    }

    private void setDataSource(String url){
        if(mAliListPlayer != null){
            UrlSource urlSource = new UrlSource();
            urlSource.setUri(url);
            mAliListPlayer.setDataSource(urlSource);
        }
    }

    private void setDataSource(VidSts vidSts){
        if(mAliListPlayer != null){
            mAliListPlayer.setDataSource(vidSts);
        }
    }

    private void setDataSource(VidAuth vidAuth){
        if(mAliListPlayer != null){
            mAliListPlayer.setDataSource(vidAuth);
        }
    }

    private void setDataSource(VidMps vidMps){
        if(mAliListPlayer != null){
            mAliListPlayer.setDataSource(vidMps);
        }
    }

    private void prepare(){
        if(mAliListPlayer != null){
            mAliListPlayer.prepare();
        }
    }

    private void start(){
        if(mAliListPlayer != null){
            mAliListPlayer.start();
        }
    }

    private void pause(){
        if(mAliListPlayer != null){
            mAliListPlayer.pause();
        }
    }

    private void stop(){
        if(mAliListPlayer != null){
            mAliListPlayer.stop();
        }
    }

    private void release(){
        if(mAliListPlayer != null){
            mAliListPlayer.release();
            mAliListPlayer = null;
        }
    }

    private void seekTo(long position,int seekMode){
        if(mAliListPlayer != null){
            IPlayer.SeekMode mSeekMode;
            if(seekMode == IPlayer.SeekMode.Accurate.getValue()){
                mSeekMode = IPlayer.SeekMode.Accurate;
            }else{
                mSeekMode = IPlayer.SeekMode.Inaccurate;
            }
            mAliListPlayer.seekTo(position,mSeekMode);
        }
    }

    private MediaInfo getMediaInfo(){
        if(mAliListPlayer != null){
            return mAliListPlayer.getMediaInfo();
        }
        return null;
    }

    private void snapshot(){
        if(mAliListPlayer != null){
            mAliListPlayer.snapshot();
        }
    }

    private void setLoop(Boolean isLoop){
        if(mAliListPlayer != null){
            mAliListPlayer.setLoop(isLoop);
        }
    }

    private Boolean isLoop(){
        return mAliListPlayer != null && mAliListPlayer.isLoop();
    }

    private void setAutoPlay(Boolean isAutoPlay){
        if(mAliListPlayer != null){
            mAliListPlayer.setAutoPlay(isAutoPlay);
        }
    }

    private Boolean isAutoPlay(){
        if (mAliListPlayer != null) {
            mAliListPlayer.isAutoPlay();
        }
        return false;
    }

    private void setMuted(Boolean muted){
        if(mAliListPlayer != null){
            mAliListPlayer.setMute(muted);
        }
    }

    private Boolean isMuted(){
        if (mAliListPlayer != null) {
            mAliListPlayer.isMute();
        }
        return false;
    }

    private void setEnableHardWareDecoder(Boolean mEnableHardwareDecoder){
        if(mAliListPlayer != null){
            mAliListPlayer.enableHardwareDecoder(mEnableHardwareDecoder);
        }
    }

    private void setScaleMode(int model){
        if(mAliListPlayer != null){
            IPlayer.ScaleMode mScaleMode = IPlayer.ScaleMode.SCALE_ASPECT_FIT;
            if(model == IPlayer.ScaleMode.SCALE_ASPECT_FIT.getValue()){
                mScaleMode = IPlayer.ScaleMode.SCALE_ASPECT_FIT;
            }else if(model == IPlayer.ScaleMode.SCALE_ASPECT_FILL.getValue()){
                mScaleMode = IPlayer.ScaleMode.SCALE_ASPECT_FILL;
            }else if(model == IPlayer.ScaleMode.SCALE_TO_FILL.getValue()){
                mScaleMode = IPlayer.ScaleMode.SCALE_TO_FILL;
            }
            mAliListPlayer.setScaleMode(mScaleMode);
        }
    }

    private int getScaleMode(){
        int scaleMode = IPlayer.ScaleMode.SCALE_ASPECT_FIT.getValue();
        if (mAliListPlayer != null) {
            scaleMode =  mAliListPlayer.getScaleMode().getValue();
        }
        return scaleMode;
    }

    private void setMirrorMode(int mirrorMode){
        if(mAliListPlayer != null){
            IPlayer.MirrorMode mMirrorMode;
            if(mirrorMode == IPlayer.MirrorMode.MIRROR_MODE_HORIZONTAL.getValue()){
                mMirrorMode = IPlayer.MirrorMode.MIRROR_MODE_HORIZONTAL;
            }else if(mirrorMode == IPlayer.MirrorMode.MIRROR_MODE_VERTICAL.getValue()){
                mMirrorMode = IPlayer.MirrorMode.MIRROR_MODE_VERTICAL;
            }else{
                mMirrorMode = IPlayer.MirrorMode.MIRROR_MODE_NONE;
            }
            mAliListPlayer.setMirrorMode(mMirrorMode);
        }
    }

    private int getMirrorMode(){
        int mirrorMode = IPlayer.MirrorMode.MIRROR_MODE_NONE.getValue();
        if (mAliListPlayer != null) {
            mirrorMode = mAliListPlayer.getMirrorMode().getValue();
        }
        return mirrorMode;
    }

    private void setRotateMode(int rotateMode){
        if(mAliListPlayer != null){
            IPlayer.RotateMode mRotateMode;
            if(rotateMode == IPlayer.RotateMode.ROTATE_90.getValue()){
                mRotateMode = IPlayer.RotateMode.ROTATE_90;
            }else if(rotateMode == IPlayer.RotateMode.ROTATE_180.getValue()){
                mRotateMode = IPlayer.RotateMode.ROTATE_180;
            }else if(rotateMode == IPlayer.RotateMode.ROTATE_270.getValue()){
                mRotateMode = IPlayer.RotateMode.ROTATE_270;
            }else{
                mRotateMode = IPlayer.RotateMode.ROTATE_0;
            }
            mAliListPlayer.setRotateMode(mRotateMode);
        }
    }

    private int getRotateMode(){
        int rotateMode = IPlayer.RotateMode.ROTATE_0.getValue();
        if(mAliListPlayer != null){
            rotateMode =  mAliListPlayer.getRotateMode().getValue();
        }
        return rotateMode;
    }

    private void setSpeed(double speed){
        if(mAliListPlayer != null){
            mAliListPlayer.setSpeed((float) speed);
        }
    }

    private double getSpeed(){
        double speed = 0;
        if(mAliListPlayer != null){
            speed = mAliListPlayer.getSpeed();
        }
        return speed;
    }

    private void setVideoBackgroundColor(int color){
        if(mAliListPlayer != null){
            mAliListPlayer.setVideoBackgroundColor(color);
        }
    }

    private void setVolume(double volume){
        if(mAliListPlayer != null){
            mAliListPlayer.setVolume((float)volume);
        }
    }

    private double getVolume(){
        double volume = 1.0;
        if(mAliListPlayer != null){
            volume = mAliListPlayer.getVolume();
        }
        return volume;
    }

    private int getDuration(){
        int duration = 0;
        if(mAliListPlayer != null){
            duration = (int) mAliListPlayer.getDuration();
        }
        return duration;
    }

    private int getVideoWidth(){
        int videoWidth = 0;
        if(mAliListPlayer != null){
            videoWidth = (int) mAliListPlayer.getVideoWidth();
        }
        return videoWidth;
    }

    private int getVideoHeight(){
        int videoHeight = 0;
        if(mAliListPlayer != null){
            videoHeight = (int) mAliListPlayer.getVideoHeight();
        }
        return videoHeight;
    }

    private void setConfig(PlayerConfig playerConfig){
        if(mAliListPlayer != null){
            mAliListPlayer.setConfig(playerConfig);
        }
    }

    private PlayerConfig getConfig(){
        if(mAliListPlayer != null){
            return mAliListPlayer.getConfig();
        }
        return null;
    }

    private CacheConfig getCacheConfig(){
        return new CacheConfig();
    }

    private void setCacheConfig(CacheConfig cacheConfig){
        if(mAliListPlayer != null){
            mAliListPlayer.setCacheConfig(cacheConfig);
        }
    }

    private TrackInfo getCurrentTrack(int currentTrackIndex){
        if(mAliListPlayer != null){
            return mAliListPlayer.currentTrack(currentTrackIndex);
        }else{
            return null;
        }
    }

    private void selectTrack(int trackId,boolean accurate){
        if(mAliListPlayer != null){
            mAliListPlayer.selectTrack(trackId,accurate);
        }
    }

    private void addExtSubtitle(String url){
        if(mAliListPlayer != null){
            mAliListPlayer.addExtSubtitle(url);
        }
    }

    private void selectExtSubtitle(int trackIndex,boolean enable){
        if(mAliListPlayer != null){
            mAliListPlayer.selectExtSubtitle(trackIndex,enable);
        }
    }

    private void createThumbnailHelper(String url){
        mThumbnailHelper = new ThumbnailHelper(url);
        mThumbnailHelper.setOnPrepareListener(new ThumbnailHelper.OnPrepareListener() {
            @Override
            public void onPrepareSuccess() {
                Map<String,Object> map = new HashMap<>();
                map.put("method","thumbnail_onPrepared_Success");
                mEventSink.success(map);
            }

            @Override
            public void onPrepareFail() {
                Map<String,Object> map = new HashMap<>();
                map.put("method","thumbnail_onPrepared_Fail");
                mEventSink.success(map);
            }
        });

        mThumbnailHelper.setOnThumbnailGetListener(new ThumbnailHelper.OnThumbnailGetListener() {
            @Override
            public void onThumbnailGetSuccess(long l, ThumbnailBitmapInfo thumbnailBitmapInfo) {
                if(thumbnailBitmapInfo != null && thumbnailBitmapInfo.getThumbnailBitmap() != null){
                    Map<String,Object> map = new HashMap<>();

                    Bitmap thumbnailBitmap = thumbnailBitmapInfo.getThumbnailBitmap();
                    ByteArrayOutputStream stream = new ByteArrayOutputStream();
                    thumbnailBitmap.compress(Bitmap.CompressFormat.JPEG, 100, stream);
                    thumbnailBitmap.recycle();
                    long[] positionRange = thumbnailBitmapInfo.getPositionRange();

                    map.put("method","onThumbnailGetSuccess");
                    map.put("thumbnailbitmap",stream.toByteArray());
                    map.put("thumbnailRange",positionRange);
                    mEventSink.success(map);
                }
            }

            @Override
            public void onThumbnailGetFail(long l, String s) {
                Map<String,Object> map = new HashMap<>();
                map.put("method","onThumbnailGetFail");
                mEventSink.success(map);
            }
        });
        mThumbnailHelper.prepare();
    }

    private void requestBitmapAtPosition(int position){
        if(mThumbnailHelper != null){
            mThumbnailHelper.requestBitmapAtPosition(position);
        }
    }


    /** ========================================================= */

    private void addVidSource(String vid,String uid){
        if(mAliListPlayer != null){
            mAliListPlayer.addVid(vid,uid);
        }
    }
    private void addUrlSource(String url,String uid){
        if(mAliListPlayer != null){
            mAliListPlayer.addUrl(url,uid);
        }
    }

    private void removeSource(String uid){
        if(mAliListPlayer != null){
            mAliListPlayer.removeSource(uid);
        }
    }

    private void clear(){
        if(mAliListPlayer != null){
            mAliListPlayer.clear();
        }
    }

    private void moveToNext(StsInfo stsInfo) {
        if(mAliListPlayer != null){
            mAliListPlayer.moveToNext(stsInfo);
        }
    }

    private void moveToPre(StsInfo stsInfo){
        if(mAliListPlayer != null){
            mAliListPlayer.moveToPrev(stsInfo);
        }
    }

    private void moveTo(String uid,StsInfo stsInfo){
        if(mAliListPlayer != null){
            mAliListPlayer.moveTo(uid,stsInfo);
        }
    }

    private void moveTo(String uid){
        if(mAliListPlayer != null){
            mAliListPlayer.moveTo(uid);
        }
    }

    public void setViewMap(Map<Integer, FlutterAliPlayerView> flutterAliPlayerViewMap) {
        this.mFlutterAliPlayerViewMap = flutterAliPlayerViewMap;
    }
}
