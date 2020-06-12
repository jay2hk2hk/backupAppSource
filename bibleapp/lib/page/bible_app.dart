import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:bibleapp/page/home_page.dart';
import 'package:bibleapp/model/bible_content.dart';
import 'package:bibleapp/model/bible_title.dart';
import 'package:bibleapp/model/bible_bookmark.dart';
import 'package:bibleapp/util/common_value.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bibleapp/util/sql_helper.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter_tts/flutter_tts.dart';
//import 'package:bibleappnew/util/flutter_tts.dart';
import 'package:synchronized/synchronized.dart';
import 'package:share/share.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:percent_indicator/percent_indicator.dart';

//import 'package:ads/ads.dart';
//import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:firebase_admob/firebase_admob.dart';

import '../main.dart';
//import 'package:flutter_native_admob/native_admob_options.dart';
//import 'package:admob_flutter/admob_flutter.dart';


int timerStatus = 0;//0=init,1=stop,2=refresh,3=play
int timerCountMins = 5000;
GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class BibleApp extends StatefulWidget {
  BibleApp(GlobalKey key) {
    _scaffoldKey = key;
  }
  @override
  _BibleAppState createState() => new _BibleAppState();
}
enum TtsState { playing, stopped }
class _BibleAppState extends State<BibleApp> {
  //String _userName;
  //String _userId;
  final dbHelper = SQLHelper.instance;
  bool isInitContent = true;
  static bool isInitTitle = true;
  static String _titleId = "1";// save title id for bookmark
  static String _titleNum = "1";// save title num for bookmark
  static String _contentNum = "1";// save content num for bookmark
  static String _titleIdForDisplay = "1";// save title id for bookmark for temp title display
  
  static var bibleTitleTotalNum = [50,40,27,36,34,24,21,4,31,24,22,25,29
                ,36,10,13,10,42,150,31,12,8,66,52,5,48
                ,12,14,3,9,1,4,7,3,3,3,2,14,4
                ,28,16,24,21,28,16,16,13,6
                ,6,4,4,5,3,6,4,3,1
                ,13,5,5,3,5,1,1,1,22];
                
        
  //List<Map<String, dynamic>> temp = new List<Map<String, dynamic>>();
  //static Map<String,dynamic> bibleAll = new Map<String,dynamic>();//get from json
  static int _selectedIndex = 0;
  static int _state = 0;//0 = content, 1 title, 2 num 
  static Future<List<String>> _dataForListView;//the listview 
  static String _bibleTitleButtonText = "";//title butotn text
  static List<BibleContent> jsonBibleContentResult = new List<BibleContent>();//content display
  static List<BibleTitle> jsonBibleTitleResult = new List<BibleTitle>();//title display
  static List<String> _bibleSeletion;
  static List<String> _bibleSeletionDefault;
  static List<BibleBookmark> _bibleBookmarkList;
  static String _titleSelection;//save title selection for back button
  static String _bibleListTitle = "";
  var unescape = new HtmlUnescape();//decode th html chinese word
  static ItemScrollController _scrollController = ItemScrollController();//the scroll controller of jump to
  static ItemScrollController _scrollControllerForTitlePage = ItemScrollController();//the scroll controller of jump to
  static int listViewInitIndex = 1;
  static int bibleTitleTotal = 66;
  static int bibleTitleNew = 40;
  static int bibleTitleOld = 39;
  FlutterTts flutterTts = FlutterTts();//tts
  //tts setting
  //pitch 3.0 value - Range is from 0.5 to 2.0
  //volume 2.5 value - Range is from 0.0 to 1.0
  //rate 2.5 value - Range is from 0.0 to 1.0
  bool isPlayAll = true;
  bool isKeepPlay = false;
  dynamic languages;
  static String language = languageTextValue[0];
  static String displayLanguage = languageTextValue[0];
  //static List<String> languageVolumeValue = ["en-US","yue-HK","zh-CN","zh-TW"];
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.5;
  static double volumeMax = 1.0;
  static double pitchMax = 2.0;
  static double rateMax = 0.8;
  static double volumeMin = 0.0;
  static double pitchMin = 0.5;
  static double rateMin = 0.3;
  static double volumeNormal = 0.5;
  static double pitchNormal = 1.0;
  static double rateNormal = 0.5;
  TtsState ttsState = TtsState.stopped;
  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  int tempCountSound = 0;
  List<String> tempBible = new List<String>();//temp play bible 
  List<int> tempBibleIndexList = new List<int>();//temp play bible count index
  IconData playStopButton = FontAwesomeIcons.play;
  IconData playStopButtonInSelectionList = FontAwesomeIcons.play;
  static bool _showLoading = true;

  //font
  static double fontOfTitleButton = 55.0;
  static double fontOfContentMax = 80.0;
  static double fontOfContentMin = 50.0;
  static double fontOfContent = 60.0;
  static double sizeOfIcon = 50.0;

  //menu
  GlobalKey btnKey = GlobalKey();

  //button disabled control
  bool isButtonDisable = false;
  //hide the left right button
  bool isButtonLeftRightShow = true;
  bool isButtonOtherShow = false;

  List<String> tempPlayListBySelection = new List<String>();
  List<bool> listSelection = new List<bool>();//bible content selection
  List<bool> listBookmark = new List<bool>();//display book mark

  //save the temp bible by each title
  static List<String> tmepBibleList = new List<String>(); 

  //timer
  Timer _timer;
  
  int _start = 5000;

  //language
  static Locale currentLang;

  //true ads native adv android
  //ca-app-pub-9860072337130869/2224676926
  //true ads native adv ios
  //ca-app-pub-9860072337130869/8395140081

  /*Ads appAds;
  int _coins = 0;
  final String appId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544~3347511713'
      : 'ca-app-pub-3940256099942544~1458002511';
  final String bannerUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';
  final String screenUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';
  final String videoUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';
  */
  
  static const _adUnitID = "ca-app-pub-3940256099942544/2247696110";
  final _nativeAdController = NativeAdmobController();


  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    //testDevices: testDevice != null ? <String>[testDevice] : null,
    //keywords: <String>['foo', 'bar'],
    //contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
  );
  BannerAd _bannerAd;
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }
  /*String getBannerAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/2934735716';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-3940256099942544/6300978111';
  }
  return null;
}*/

@override
  void initState() {
    
    super.initState();
    //initBibleContent();
    language = prefs.getString(sharePrefSoundLanguage);
    displayLanguage = prefs.getString(sharePrefDisplayLanguage);
        
    _initTheSelectionList();
    _initTts();
    initAds();
    BackButtonInterceptor.add(myInterceptor);

  }
  void initBibleContent() async
  {
    //String data2 = await rootBundle.loadString('assets/json/bible_cuv.json');
    //bibleAll = json.decode(data2);
    //print(user["bibleTitleSelection"]["1"]["selection"]);
  }

  void initAds()
  {
    /*FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
    _bannerAd = createBannerAd()..load();
    
    _bannerAd ??= createBannerAd();
                      _bannerAd
                        ..load()
                        ..show(anchorOffset: ScreenUtil().setHeight(120),anchorType: AnchorType.bottom);
    */
    /*appAds = Ads(
      appId,
      bannerUnitId: bannerUnitId,
      screenUnitId: screenUnitId,
      //keywords: <String>['ibm', 'computers'],
      //contentUrl: 'http://www.ibm.com',
      childDirected: false,
      //testDevices: ['Samsung_Galaxy_SII_API_26:5554'],
      testing: false,
      //listener: eventListener,
      anchorType: AnchorType.top,
      //horizontalCenterOffset: 50,
      anchorOffset: ScreenUtil().setHeight(150),
    );
    appAds.showBannerAd();*/
  }

  void _initTheSelectionList()
  {
    for(int i=0;i<200; i++)
    {
      listSelection.add(false);
      listBookmark.add(false);
    }
  }

  //update the selection list
  void updateTheSelectionList(int index)
  {
    setState(() {
      listSelection[index] = !listSelection[index];
      bool isNeedOpen = false;
      for(int i=0; i <tmepBibleList.length;i++)
      {
        if(listSelection[i])
        {
            isNeedOpen = true;
        }
      }
      if(isNeedOpen)
      {
        isButtonLeftRightShow = false;
        isButtonOtherShow = true;
      }
      else
      {
        isButtonLeftRightShow = true;
        isButtonOtherShow = false;
      }
      });
    
  }

  //language
  changeLanguage(String value) async {
    displayLanguage = value;
    List<String> cl = value.split("-");
    currentLang = Locale(cl[0],cl[1]);
    
    await FlutterI18n.refresh(context, currentLang);
    setState(() {
      //_dataForListView = queryBibleContentByTitle(_titleId,_titleNum);
      if(languageTextValue[0]==value)
        language = languageVolumeValue[0];
      else if(languageTextValue[1]==value)
      {
        /*bool haveTts = false;
        for (String type in languages)
        {
          if(type.toLowerCase().indexOf('hk')>=0 || type.toLowerCase().indexOf('yue')>=0)
          {
            language = type;
            haveTts = true;
          }
        }
        if(!haveTts)*/ language = languageVolumeValue[2];
      }
        
      else if(languageTextValue[2]==value)
        language = languageVolumeValue[2];
      else if(languageTextValue[3]==value)
        language = languageVolumeValue[3];
    });
  }

  //tts handle function
  //init tts
  _initTts() {
      flutterTts = FlutterTts();

      _getLanguages();

      flutterTts.setStartHandler(() {
        setState(() {
          print("playing");
          ttsState = TtsState.playing;
        });
      });

      flutterTts.setCompletionHandler(() {
        setState(() async{
          if(tempCountSound<tempBible.length)
          {
            _scrollController.scrollTo(index: tempBibleIndexList[tempCountSound], duration: Duration(milliseconds: 1));
            var result = _startSpeak(tempBible[tempCountSound]);
            tempCountSound+=1;
            if (result == 1) ttsState = TtsState.playing;
          }
          else 
          {
            tempCountSound = 0;
            tempBibleIndexList = new List<int>();
            print("Complete");
            ttsState = TtsState.stopped;
            if(isPlayAll)
            {
              startTimer();
              showDialog(
              barrierDismissible: false,
              context: context,
              builder: (_) {
                return MyDialog();
              });
            }
            else
            {
              isPlayAll = true;
              playStopButtonInSelectionList = FontAwesomeIcons.play;
              playStopButton = FontAwesomeIcons.play;
              stopSelectList();
            }
            
          }
          
        });
      });

      flutterTts.setErrorHandler((msg) {
        setState(() {
          print("error: $msg");
          ttsState = TtsState.stopped;
        });
      });
    }

  Future _getLanguages() async {
    languages = await flutterTts.getLanguages;
    if (languages != null) 
    setState(() => languages);
  }

  void playSelectList()async
  {
    isPlayAll = false;
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);
    flutterTts.setLanguage(language);
    tempBible = new List<String>();
    tempBibleIndexList = new List<int>();
    for(int i=0; i<tmepBibleList.length;i++)
    {
      if(listSelection[i])
      {
        tempBibleIndexList.add(i);
        tempBible.add(tmepBibleList[i]);
      }
        
    }
    _scrollController.scrollTo(index: tempBibleIndexList[tempCountSound], duration: Duration(milliseconds: 1));
    setState(() {
      isButtonDisable = true;
    });
    _startSpeak(_bibleTitleButtonText);
  }

  void stopSelectList() async
  {
    setState(() {
        tempCountSound=0;
        tempBibleIndexList = new List<int>();
        //_scrollController.scrollTo(index: 0, duration: Duration(milliseconds: 1));
        isButtonDisable = false;
      });
      _stopSpeak();
  }

  void playAllContent() async
  {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);
    flutterTts.setLanguage(language);
    tempBible = (await _dataForListView);
    tempBibleIndexList = new List<int>();
    
    for(int i=0;i<tempBible.length;i++)
    {
      tempBibleIndexList.add(i);
    }
    _scrollController.scrollTo(index: 0, duration: Duration(milliseconds: 1));
    setState(() {
      isButtonDisable = true;
    });
    _startSpeak(_bibleTitleButtonText);
  }

  void stopPlayAll() async
  {
    setState(() {
        tempCountSound=0;
        tempBibleIndexList = new List<int>();
        _scrollController.scrollTo(index: 0, duration: Duration(milliseconds: 1));
        isButtonDisable = false;
      });
      _stopSpeak();
  }

  Future<dynamic> _startSpeak(String text) async {
    await flutterTts.speak(text);
  }


  Future _stopSpeak() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() { 
      ttsState = TtsState.stopped;
      });
  }

  

@override
  void dispose() {
    //为了避免内存泄露，需要调用.dispose
    super.dispose();
    flutterTts.stop();
    _bannerAd?.dispose();
    BackButtonInterceptor.remove(myInterceptor);
    //appAds.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    //print("BACK BUTTON!"); // Do some stuff.
    if(ttsState == TtsState.playing)
      _stopSpeak();
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return true;
  }

  
//save user settings
  setSharedPreferences() async
  {
    if(prefs!=null)
    {
        prefs.setString(sharePrefTitleId, _titleId);
        prefs.setString(sharePrefTitleNum, _titleNum);
        prefs.setDouble(sharePrefFontSize, fontOfContent);
        prefs.setDouble(sharePrefSpeechRate, rate);
        prefs.setString(sharePrefSoundLanguage, language);
        prefs.setString(sharePrefDisplayLanguage, displayLanguage);
          
    }
    
  }

  //init apps
  Future _onInit() async {

    //prefs = await SharedPreferences.getInstance();
    if(prefs.getString(sharePrefTitleId) == null)
    {
      _titleId = "1";
      await prefs.setString(sharePrefTitleId, _titleId);
    }
      
    else 
      _titleId = prefs.getString(sharePrefTitleId);

    if(prefs.getString(sharePrefTitleNum) == null)
    {
      _titleNum = "1";
      await prefs.setString(sharePrefTitleNum, _titleNum);
    }
    else 
      _titleNum = prefs.getString(sharePrefTitleNum);

    if(prefs.getDouble(sharePrefFontSize) == null)
    {
      fontOfContent = 40.0;
      await prefs.setDouble(sharePrefFontSize, fontOfContent);
    }
    else 
      fontOfContent = prefs.getDouble(sharePrefFontSize); 

    if(prefs.getDouble(sharePrefSpeechRate) == null)
    {
      rate = 0.5;
      await prefs.setDouble(sharePrefSpeechRate, rate);
    }
    else 
      rate = prefs.getDouble(sharePrefSpeechRate);   

    if(prefs.getString(sharePrefContentNum) == null)
    {
      _contentNum = "1";
      await prefs.setString(sharePrefContentNum, _contentNum);
    }
    else 
      _contentNum = prefs.getString(sharePrefContentNum);  

    if(prefs.getString(sharePrefSoundLanguage) == null)
    {
      language = languageVolumeValue[0];
      await prefs.setString(sharePrefSoundLanguage, language);
    }  
    else 
      language = prefs.getString(sharePrefSoundLanguage); 

//prefs.setString(sharePrefContentNum, _contentNum);
  }


  void startTimer() {
  const oneSec = const Duration(milliseconds: 10);
  _timer = new Timer.periodic(
    oneSec,
    (Timer timer) => setState(
      () {
        
        if (timerStatus==3) {
            timerStatus = 0;
            rightButton();
            isKeepPlay = true;
            //playAllContent();
            timer.cancel();
          }
        else if(timerStatus==2)
        {
            timerStatus = 0;
            playAllContent();
            timer.cancel();
        }   
        else if(timerStatus==1)
        {
            setState(() {
              isButtonDisable = false;
              playStopButton=FontAwesomeIcons.play;
            });
            timerStatus = 0;
            timer.cancel();
        }  
        /*else {
          setState(() {
            _start = _start - 1;
          });
          
        }*/
      },
    ),
  );
}

//load the button text for bible title
loadButtonText() async {
    if(isInitTitle)
    {
      isInitTitle = false;
      
      //String data2 = await rootBundle.loadString('assets/json/bible_title_cuv.json');
      //jsonBibleTitleResult = parseJosnBibleTitle(data2);
    }
    _bibleTitleButtonText = getBibleTitleByTitleId(_titleId)+' '+_titleNum;
    /*
    if(_state==0)
      _bibleTitleButtonText = getBibleTitleByTitleId(_titleId)+' '+_titleNum;
    else if(_state==1)
    {
      _bibleTitleButtonText = "Select Title";
    }
    else if(_state==2)
    {
      _bibleTitleButtonText = "Select Selection";
    }
    */
}

  void setBookmarkList() async
  {
    _bibleBookmarkList = await getBibleBookmarkByTitle(int.parse(_titleId),int.parse(_titleNum));
    for(int i = 0;i< listBookmark.length; i++)
      {
        listBookmark[i] = false;
        if(_bibleBookmarkList!=null)
        {
          for(BibleBookmark temp2 in _bibleBookmarkList)
          {
            if(temp2.text==(i+1))
              listBookmark[i] = true;
          }
        }
      }
  }

  //check got crown yet
  void checkGotCronw()
  {
    String tempNewBibleTodaysText = "";
    if(!prefs.getBool(sharePrefBibleTodaysGotCrown))
    {
      String tempBibleTodaysText = prefs.getString(sharePrefBibleTodaysString);
      List<String> tempTodaysList = tempBibleTodaysText.split(',');
      
      for(int i=0; i< tempTodaysList.length; i++)
      {
        if(!tempTodaysList[i].contains(_titleId+":"+_titleNum))
        {
          tempNewBibleTodaysText+=tempTodaysList[i]+",";
        }
        
      }
      if(tempNewBibleTodaysText!="")
      {
        tempNewBibleTodaysText = tempNewBibleTodaysText.substring(0,tempNewBibleTodaysText.lastIndexOf(','));
      }
      //else prefs.setBool(sharePrefBibleTodaysGotCrown, true);
        
      prefs.setString(sharePrefBibleTodaysString, tempNewBibleTodaysText);
      //print(tempNewBibleTodaysText);
    }
    
  }

  //every stat reload the list view
  Future<List<String>> loadQueryToList() async {
    
    if(isInitContent)
    {
      isInitContent = false;
      //String data = await rootBundle.loadString('assets/json/bible_cuv.json');
      //jsonBibleContentResult = parseJosnBibleContent(data);
      _onInit().whenComplete((){
          _dataForListView = queryBibleContentByTitle(_titleId,_titleNum).whenComplete((){
            setState(() {
                    
                    _showLoading = false;
                    WidgetsBinding.instance
                      .addPostFrameCallback((_) => _updateContentNum());
                  });});
      });
      
    }
    _dataForListView = queryBibleContentByTitle(_titleId,_titleNum).whenComplete((){
            setState(() {
                    setBookmarkList();
                    if(isKeepPlay)
                    {
                      playAllContent();
                      isKeepPlay = false;
                    }
                    
                  });});
    checkGotCronw();
    //await Future.delayed(const Duration(milliseconds: 100), (){setBookmarkList();});
    setSharedPreferences();
    

      return _dataForListView;
  }

  void _updateContentNum()
    {
      _scrollController.scrollTo(index: int.parse(_contentNum)-1, duration: Duration(milliseconds: 1));
      prefs.setString(sharePrefContentNum, "1");
    }

  //every stat reload the list view
  Future<List<String>> loadQueryToTitleList() async {

    if(_state==1)
    {
      _bibleSeletion = queryBibleTitleByDefault();
      //scrollTitleListWithTitleId();
    }
    /*else if(_state==1)
    {
      _bibleSeletion = queryBibleTitleByDefault();
    }    
    else if(_state==2)
    {
      //_scrollController.scrollTo(index: 0, duration: Duration(milliseconds: 1));
      listViewInitIndex = 0;
    }*/

    
      return _bibleSeletion;
  }

  //left button for next content
  leftButton()
  {
    setState(() 
    {
      if(int.parse(_titleNum)-1 <= 0)
      {
        if(int.parse(_titleId)-1 <=0)
        {
          _titleId = bibleTitleTotalNum.length.toString();
          _titleNum = bibleTitleTotalNum[int.parse(_titleId)-1].toString();
        }
        else
        {
          _titleId = (int.parse(_titleId)-1).toString();
          _titleNum = bibleTitleTotalNum[int.parse(_titleId)-1].toString();
        }
      }
      else
      {
        _titleNum = (int.parse(_titleNum)-1).toString();
      }
      
      _bibleTitleButtonText = getBibleTitleByTitleId(_titleId)+' '+_titleNum;
      //_dataForListView = queryBibleContentByTitle(_titleId,_titleNum);
    }
    );
    _scrollController.scrollTo(index: 0, duration: Duration(milliseconds: 1));
  }
  //right button for previous content
  rightButton()
  {
    setState(() 
    {
      if(int.parse(_titleNum)+1 > bibleTitleTotalNum[int.parse(_titleId)-1])
      {
        if(int.parse(_titleId)+1 > bibleTitleTotalNum.length)
        {
          _titleId = "1";
          _titleNum = "1";
        }
        else
        {
          _titleId = (int.parse(_titleId)+1).toString();
          _titleNum = "1";
        }
      }
      else
      {
        _titleNum = (int.parse(_titleNum)+1).toString();
      }
      
      _bibleTitleButtonText = getBibleTitleByTitleId(_titleId)+' '+_titleNum;
      //_dataForListView = queryBibleContentByTitle(_titleId,_titleNum);
    }
    );
    _scrollController.scrollTo(index: 0, duration: Duration(milliseconds: 1));
  }

  String copyShareReturnText()
  {
    String tempText = "";
    tempText += "$_bibleTitleButtonText\n";
    for(int i=0;i<tmepBibleList.length;i++)
    {
      if(listSelection[i])
        tempText += tmepBibleList[i]+"\n";
    }
    return tempText;
  }
  void copyToClipboard()
  {
    Clipboard.setData(new ClipboardData(text: copyShareReturnText()));
    resetSelection();
  }

  void shareToOther()
  {
    Share.share(copyShareReturnText());
  }

  void bookmarkSelection()
  {
    for(int i=0; i<listSelection.length; i++)
    {
      if(listSelection[i])
        insertBookmark(i+1);
    }
    resetSelection();
    setState(() {
      
    });
  }

  void resetSelection()
  {
    setState(() {
      for(int i=0;i<tmepBibleList.length;i++)
      {
        listSelection[i] = false;
      }
      isButtonLeftRightShow = true;
      isButtonOtherShow = false;
    });
  }

  //parseJosn for bible content
  List<BibleContent> parseJosnBibleContent(String response) {
      if(response==null){
        return [];
      }
      final parsed =
          json.decode(response.toString()).cast<Map<String, dynamic>>();
      return parsed.map<BibleContent>((json) => new BibleContent.fromJson(json)).toList();
    }
  //parseJosn for bible title
  List<BibleTitle> parseJosnBibleTitle(String response) {
      if(response==null){
        return [];
      }
      final parsed =
          json.decode(response.toString()).cast<Map<String, dynamic>>();
      return parsed.map<BibleTitle>((json) => new BibleTitle.fromJson(json)).toList();
    }

//query title by default
List<String> queryBibleTitleByDefault() {
    //_bibleSeletionDefault = [FlutterI18n.translate(context, "bibleTitleSelection.1.selection"),FlutterI18n.translate(context, "bibleTitleSelection.2.selection")];
    //_titleSelection = _bibleSeletionDefault[1];//save title selection for back button
    //return _bibleSeletionDefault;
    List<String> tmepList = new List<String>();
    int startCount = 1;
    int endCount = bibleTitleTotal;
    //int endCount = jsonBibleTitleResult.length;
    
    /*if(text==_bibleSeletionDefault[0])
    {
      endCount = bibleTitleOld;
    }
    else if(text==_bibleSeletionDefault[1])
    {
      startCount = bibleTitleNew;
    }*/
    for(int i=startCount; i <= endCount; i++)
    {
      if(i==startCount)
        tmepList.add(FlutterI18n.translate(context, "bibleTitleSelection.1.selection")/*bibleAll["bibleTitleSelection"]["1"]["selection"]*/);
      else if(i==bibleTitleNew) 
        tmepList.add(FlutterI18n.translate(context, "bibleTitleSelection.2.selection")/*bibleAll["bibleTitleSelection"]["2"]["selection"]*/);
      tmepList.add(FlutterI18n.translate(context, "bibleTitle.$i.title")/*bibleAll["bibleTitle"][i.toString()]["title"]*/);
    }
    tmepList.add('');
    return tmepList;
  }

//query content by title
  Future<List<String>> queryBibleContentByTitle(String titleId, String titleNum) async {
    /*List<BibleContent> t = jsonBibleContentResult.where((v) => v.titleId == titleId  && v.titleNum == titleNum).toList();
    BibleContent temp;
    if(t.length>0)
      temp = t[0];
    else
      temp = jsonBibleContentResult.where((v) => v.titleId == titleId  && v.titleNum == "1").toList()[0];*/
      String temp = FlutterI18n.translate(context, "bible.$titleId.$titleNum.content")/*bibleAll["bible"][titleId][titleNum]["content"]*/;
    tmepBibleList = unescape.convert(temp).split("=.=");
    return tmepBibleList;
  }

//query title by title
String getBibleTitleIdByTitle(String title)
{
  //List<BibleTitle> temp = jsonBibleTitleResult.where((v) => v.title == title).toList();
  //return temp[0].titleId;
  String temp = FlutterI18n.translate(context, "bibleTitle.$title.titleId")/*bibleAll["bibleTitle"][title]["titleId"]*/;
  return temp;
}

//query title by titleid
String getBibleTitleByTitleId(String titleId)
{
  //List<BibleTitle> temp = jsonBibleTitleResult.where((v) => v.titleId == titleId).toList();
  //return temp[0].title;
  String temp = FlutterI18n.translate(context, "bibleTitle.$titleId.title")/*bibleAll["bibleTitle"][titleId]["title"]*/;
  return temp;
}

//query all title
  Future<List<String>> queryBibleContentAllTitle() async {
    List<String> tmepList = new List<String>();
    /*for(int i=0; i < jsonBibleTitleResult.length; i++)
    {
      tmepList.add(jsonBibleTitleResult[i].title);
    }*/
    for(int i=1; i <= bibleTitleTotal; i++)
    {
      tmepList.add(FlutterI18n.translate(context, "bibleTitle.$i.title")/*bibleAll["bibleTitle"][i.toString()]["title"]*/);
    }
    return tmepList;
  }

  List<String> queryBibleContentAllTitleBySelection(String text) {
    List<String> tmepList = new List<String>();
    int startCount = 1;
    int endCount = bibleTitleTotal;
    //int endCount = jsonBibleTitleResult.length;
    
    if(text==_bibleSeletionDefault[0])
    {
      endCount = bibleTitleOld;
    }
    else if(text==_bibleSeletionDefault[1])
    {
      startCount = bibleTitleNew;
    }
    for(int i=startCount; i <= endCount; i++)
    {
      tmepList.add(FlutterI18n.translate(context, "bibleTitle.$i.title")/*bibleAll["bibleTitle"][i.toString()]["title"]*/);
      //tmepList.add(jsonBibleTitleResult[i].title);
    }
    return tmepList;
  }

//query title by num
  List<String> queryTitleNum(String titleId) {
    int temp = bibleTitleTotalNum[int.parse(titleId)-1];
    List<String> tmepList = List.generate(temp, (i) => (i+1).toString());
    tmepList.add('');
    
    return tmepList;
  }

// when select the list
  _onSelectedList(int index, String text) {
    //Clipboard.setData(new ClipboardData(text: text));
      //_selectedIndex = index;
      updateTheSelectionList(index);

    
    //menuForSelectedContent.show(widgetKey: btnKey);
    /*
      if(_state==0)
      {
        //setState(() {_selectedIndex = index;});
        setState(() 
        {
          _dataForListView = queryBibleContentByTitle(_titleId,_titleNum);
          _state = 0;
          _selectedIndex = index;
          
        }
        );
      }
      else if(_state==1)
      {
        setState(() 
        {
          _titleId = getBibleTitleIdByTitle(text); 
          _dataForListView = queryTitleNum(_titleId);
          _state = 2;
          
        }
        );
      }
      else if(_state==2)
      {
        setState(() 
        {
          _titleNum = text; 
          _dataForListView = queryBibleContentByTitle(_titleId,_titleNum);
          _state = 0;
          _bibleTitleButtonText = getBibleTitleByTitleId(_titleId)+' '+_titleNum;
          
        }
        );
      }
      */
    }
  _resetSelectList()
  {
    setState(() 
        {
          _state = 1;
          _bibleListTitle = "";
          _bibleSeletion = queryBibleTitleByDefault();
          _titleIdForDisplay = _titleId;
          //_bibleTitleButtonText.replaceAll(new RegExp(r'$titleNum'), '');
          //_titleId = getBibleTitleIdByTitle(_bibleTitleButtonText.replaceAll(new RegExp(r' $titleNum'), '')); 
          //print(_bibleTitleButtonText.replaceAll(new RegExp(r'$titleNum'), ''));
        }
      );
  }
    // when select the list
  _onSelectedListTitle(String text,BuildContext content) {
    
      /*if(_state==0)
      {
        //setState(() {_selectedIndex = index;});_scrollControllerForTitlePage
        setState(() 
        {
          _titleSelection = text;
          _bibleListTitle = text;
          _bibleSeletion = queryBibleContentAllTitleBySelection(text);
          //String temp = getBibleTitleByTitleId(_titleId);
          //for(int i=0;i<_bibleSeletion.length;i++)
          //{
          //  if(temp==_bibleSeletion[i])
          //  {
          //    if(_scrollControllerForTitlePage.isAttached)
          //      _scrollControllerForTitlePage.scrollTo(index: i, duration: Duration(milliseconds: 1));
          //  }
          //    
          //}
          _scrollControllerForTitlePage.scrollTo(index: 0, duration: Duration(milliseconds: 1));
          _state = 1;
        }
        );
      }
      else */if(_state==1)
      {
        setState(() 
        {
          //_titleSelection = text;
          _titleIdForDisplay = getBibleTitleIdByTitle(text); 
          _bibleListTitle = text;
          _bibleSeletion = queryTitleNum(_titleIdForDisplay);
          if(_titleIdForDisplay==_titleId)
            _scrollControllerForTitlePage.scrollTo(index: int.parse(_titleNum)-1, duration: Duration(milliseconds: 1));
          else  _scrollControllerForTitlePage.scrollTo(index: 0, duration: Duration(milliseconds: 1));
          _state = 2;
        }
        );
      }
      else if(_state==2)
      {
        setState(() 
        {
          //_titleSelection = text;
          _titleId = getBibleTitleIdByTitle(_bibleListTitle); 
          _titleNum = text; 
          _bibleListTitle = "";
          //_dataForListView = queryBibleContentByTitle(_titleId,_titleNum);
          _state = 1;
          _bibleTitleButtonText = getBibleTitleByTitleId(_titleId)+' '+_titleNum;
          _scrollControllerForTitlePage.scrollTo(index: 0, duration: Duration(milliseconds: 1));
          _scrollController.scrollTo(index: 0, duration: Duration(milliseconds: 1));
          Navigator.pop(content);
        }
        );
      }
      
    }

    _onBackSelectedListTitle(BuildContext content) {

      /*if(_state==0)
      {
        _scaffoldKey.currentState.openEndDrawer();
      }
      else */if(_state==1)
      {
        _scaffoldKey.currentState.openEndDrawer();
        /*setState(() 
        {
          _state = 0;
          _bibleListTitle = "";
          _bibleSeletion = queryBibleTitleByDefault();
          _scrollControllerForTitlePage.scrollTo(index: 0, duration: Duration(milliseconds: 1));
        }
        );*/
      }
      else if(_state==2)
      {
        setState(() 
        {
          //_bibleListTitle = _titleSelection;
          //_bibleSeletion = queryBibleTitleByDefault();//queryBibleContentAllTitleBySelection(_titleSelection);
          scrollTitleListWithTitleId();
          
          _state = 1;
        }
        );
      }
      
    }

    void scrollTitleListWithTitleId()
    {
      int index = 0;
      if(int.parse(_titleIdForDisplay)<=bibleTitleOld)
            index = int.parse(_titleIdForDisplay);
      else  index = int.parse(_titleIdForDisplay)+1;
      if(_scrollControllerForTitlePage.isAttached /*&& _bibleSeletion.length>index*/)
        _scrollControllerForTitlePage.scrollTo(index: index, duration: Duration(milliseconds: 100));
    }
    
    void insertBookmark(int text) async
    {
      final fido = BibleBookmark(
        title: int.parse(_titleId),
        content: int.parse(_titleNum),
        text: text,
      );
      dbHelper.insertBookmark(fido);
    }

    Future<List<BibleBookmark>> getBibleBookmarkByTitle(int titleId, int titleNum) async
    {
      return dbHelper.getBibleBookmarkByTitle(titleId,titleNum);
    }

/*
void _insert(Map<String, dynamic> row) async {
    // row to insert
    final id = await dbHelper.insert(row);
    //print('inserted row id: $id');
  }
  void insrtContent(Map<String, dynamic> row)
  {
    if(row!=null)
    temp.add(row);
  }

  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    //print('query all rows:');
    //allRows.forEach((row) => print(row));
    
  }
    void deleteAll() async
  {
    await dbHelper.deleteAll();
  }
*/

  Widget _buildWidget()
  {
      return new Scaffold(
      key: _scaffoldKey,
      appBar: AppBar( //导航栏
      automaticallyImplyLeading: false, // Don't show the leading button
      title: InkWell(
        onTap: () {
            if(!isButtonDisable)
            {
              _scaffoldKey.currentState.openDrawer();
              resetSelection();
              _resetSelectList();
              WidgetsBinding.instance
              .addPostFrameCallback((_) => scrollTitleListWithTitleId());
              
            }
        },
        child: _buttonTitle(),
    ),
      /*FlatButton(
      textColor: buttonTextColor,
      onPressed: () {
        if(!isButtonDisable)
        {
          _scaffoldKey.currentState.openDrawer();
          resetSelection();
          _resetSelectList();
          WidgetsBinding.instance
           .addPostFrameCallback((_) => scrollTitleListWithTitleId());
          
        }
        
      },
      child: _buttonTitle(),
      //label: _buttonTitle(),
      //icon: FaIcon(FontAwesomeIcons.bible,color: Colors.white,),
      shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
    ),*/
    //leading: new Container(width:1),
      /*leading: Builder(builder: (context) {
      return IconButton(
        icon: Icon(Icons.note, color: Colors.white), //自定义图标
        onPressed: () {
          // 打开抽屉菜单  
          //Scaffold.of(context).openDrawer(); 
          //_scaffoldKey.currentState.openDrawer();
          //Clipboard.setData(new ClipboardData(text: "your text"));
          //Share.share('check out my website https://example.com');
        },
      );
    }),*///导航栏右侧菜单
      /*leading: Builder(builder: (context) {
      return FlatButton(
      textColor: Colors.white,
      onPressed: () {
        //_queryForListViewForButton(_bibleTitleButtonText);
        //Scaffold.of(context).openDrawer(); 
        _scaffoldKey.currentState.openDrawer();
      },
      child: _buttonTitle(),
      shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
    );
    }),*/
        actions: <Widget>[
          
          //IconButton(icon: Icon(Icons.share), onPressed: () {}),
          /*IconButton(icon: Icon(playStopButton,color: iconColor,), onPressed: () 
          {
            resetSelection();
            if(playStopButton == FontAwesomeIcons.play)
            {
              setState((){playStopButton=FontAwesomeIcons.stop;});
              playAllContent();
            }
            else
            {
              setState((){playStopButton=FontAwesomeIcons.play;});
              stopPlayAll();
            }
              
          }),*/
          InkWell(
            child: Container(
              child: Icon(
                playStopButton,
                color: iconColor,
                size: ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),
              ),
            ),
            onTap: () {
              resetSelection();
              if(playStopButton == FontAwesomeIcons.play)
              {
                setState((){playStopButton=FontAwesomeIcons.stop;});
                playAllContent();
              }
              else
              {
                setState((){playStopButton=FontAwesomeIcons.play;});
                stopPlayAll();
              }
            }),
            /*SizedBox(width:ScreenUtil().setSp(5, allowFontScalingSelf: true),),
          new PopupMenuButton<String>(
            //offset: Offset(500, 500),
            //elevation: 20,
            icon: FaIcon(FontAwesomeIcons.language,color: iconColor,size: ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            new PopupMenuItem<String>(
                value: languageTextValue[0], child: new Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: new Text(chnageLanguageList[0],style: TextStyle(/*color: fontTextColor,*/ fontSize: ScreenUtil().setSp(sizeOfIcon-10, allowFontScalingSelf: true),
                  ),)),
                ),
            new PopupMenuDivider(height: 1.0),
            new PopupMenuItem<String>(
                value: languageTextValue[1], child: new Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: new Text(chnageLanguageList[1],style: TextStyle(/*color: fontTextColor,*/ fontSize: ScreenUtil().setSp(sizeOfIcon-10, allowFontScalingSelf: true),
                  ),)),
                ),
                
            /*new PopupMenuDivider(height: 1.0),
            new PopupMenuItem<String>(
                value: languageTextValue[2], child: new Container(
                  alignment: Alignment.center,
                  child: new Text(chnageLanguageList[2],style: TextStyle(color: fontTextColor),)),
                ),*/
            new PopupMenuDivider(height: 1.0),
            new PopupMenuItem<String>(
                value: languageTextValue[3], child: new Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: new Text(chnageLanguageList[3],style: TextStyle(/*color: fontTextColor,*/ fontSize: ScreenUtil().setSp(sizeOfIcon-10, allowFontScalingSelf: true),
                  ),)),
                ),
                
            new PopupMenuDivider(height: 1.0),
            new PopupMenuItem<String>(
                value: 'cancel', child: new Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: new Text(FlutterI18n.translate(context, "cancel"),style: TextStyle(/*color: fontTextColor,*/ fontSize: ScreenUtil().setSp(sizeOfIcon-10, allowFontScalingSelf: true),
                  ),)),
                ),
          ],
      
      onSelected: (String value) {
        if(value!='cancel')changeLanguage(value);
      }),*/
      SizedBox(width:ScreenUtil().setSp(5, allowFontScalingSelf: true),),
          !isButtonDisable ? 
          new PopupMenuButton<String>(
            icon: FaIcon(FontAwesomeIcons.ellipsisV,color: iconColor,size: ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  new PopupMenuItem<String>(
                      value: 'font', child: new Container(
                        width: double.infinity,
                        child: new Column(
                          children: <Widget>[
                            new Text(FlutterI18n.translate(context, "fontSize"),style: TextStyle(/*color: fontTextColor,*/fontSize: ScreenUtil().setSp(sizeOfIcon-10, allowFontScalingSelf: true),),),
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                IconButton(icon: FaIcon(FontAwesomeIcons.plus,color: iconAlertDialogColor, size: ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),), onPressed: () 
                                {
                                  setState(()
                                  {
                                    if(fontOfContent<=fontOfContentMax)
                                      fontOfContent+=1;
                                  });
                                }),
                                IconButton(icon: FaIcon(FontAwesomeIcons.font,color: iconAlertDialogColor, size: ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),), onPressed: () {}),
                                IconButton(icon: FaIcon(FontAwesomeIcons.minus,color: iconAlertDialogColor, size: ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),), onPressed: () 
                                {
                                  setState(()
                                  {
                                    if(fontOfContent>=fontOfContentMin)
                                    fontOfContent-=1;
                                  });
                                  
                                }),
                              ],
                              ),
                          ],
                        )
                      ),
                  ),
            new PopupMenuDivider(height: 1.0),
            new PopupMenuItem<String>(
                value: 'rate', child: new Column(
                  children: <Widget>[
                    new Text(FlutterI18n.translate(context, "speechRate"),style: TextStyle(/*color: fontTextColor,*/fontSize: ScreenUtil().setSp(sizeOfIcon-10, allowFontScalingSelf: true),),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        IconButton(icon: FaIcon(FontAwesomeIcons.biking,color: iconAlertDialogColor, size: ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),), onPressed: () 
                        {
                          setState(()
                          {
                            rate=rateMax;
                          });
                          Navigator.pop(context);
                        }),
                        IconButton(icon: FaIcon(FontAwesomeIcons.running,color: iconAlertDialogColor, size: ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),), onPressed: () 
                        {
                          setState(()
                          {
                            /*if(prefs.getInt(sharePrefLightDark)==0)
                              prefs.setInt(sharePrefLightDark, 1);
                            else prefs.setInt(sharePrefLightDark, 0);  
                            RestartWidget.restartApp(context);*/
                            rate=rateNormal;
                          });
                          Navigator.pop(context);
                        }),
                        IconButton(icon: FaIcon(FontAwesomeIcons.walking,color: iconAlertDialogColor, size: ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),), onPressed: () 
                        {
                          setState(()
                          {
                            rate=rateMin;
                          });
                          Navigator.pop(context);
                        }),
                      ],
                      ),
                  ],
                  )
                ),
            new PopupMenuDivider(height: 1.0),
            /*new PopupMenuItem<String>(
                value: 'value03', child: new Text('Item Three')),
                
            new PopupMenuDivider(height: 1.0),*/
            new PopupMenuItem<String>(
                value: 'cancel', child: new Container(
                  alignment: Alignment.center,
                  child: new Text(FlutterI18n.translate(context, "cancel"),style: TextStyle(/*color: fontTextColor,*/fontSize: ScreenUtil().setSp(sizeOfIcon-10, allowFontScalingSelf: true),),)),
                ),
                
            /*new PopupMenuItem<String>(
                value: 'value03', child: new Text('Item Three')),
            new PopupMenuItem<String>(
                value: 'value04', child: new Text('I am Item Four'))
                */
          ],
      
      onSelected: (String value) {
        
      })
      : new IconButton(icon: FaIcon(FontAwesomeIcons.ellipsisV,color: iconColor,),onPressed: null,),
        ],
      ),
      drawer: Container(
      width: ScreenUtil().setSp(650, allowFontScalingSelf: true),
      child: myDrawer(context),
      ),
      
      //endDrawer: myDrawer2(context),
      body: new Column(
        children: <Widget>[ 
          /*Expanded(
                  flex: 2,
                  child: NativeAdmob(
                  // Your ad unit id
                  adUnitID: _adUnitID,
                  controller: _nativeAdController,
                  type: NativeAdmobType.banner,
                ),
                  ),*/
          Expanded(
                  flex: 9,
                  child: _myListView(context),
                ),  
          /*Expanded(
                  flex: 1,
                  child: Text(''),
                ),*/ 
        ],
      ),
      
      floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
            padding: /*const EdgeInsets.all(4.0),*/const EdgeInsets.fromLTRB(4.0,.0,4.0,4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Visibility(
                  visible: isButtonLeftRightShow,
                  child: FloatingActionButton(
                    heroTag: "leftBtn",
                  onPressed: () {
                    if(!isButtonDisable) leftButton();
                    },
                  child: FaIcon(FontAwesomeIcons.arrowLeft),
                  ),
                ),
                Visibility(
                  visible: isButtonOtherShow,
                  child: FloatingActionButton(
                    heroTag: "copyToBtn",
                  onPressed: () {
                    if(!isButtonDisable) copyToClipboard();
                    },
                  child: FaIcon(FontAwesomeIcons.copy),
                  ),
                ),
                Visibility(
                  visible: isButtonOtherShow,
                  child: FloatingActionButton(
                    heroTag: "shareBtn",
                  onPressed: () {
                    if(!isButtonDisable) shareToOther();
                    },
                  child: FaIcon(FontAwesomeIcons.share),
                  ),
                ),
                Visibility(
                  visible: isButtonOtherShow,
                  child: FloatingActionButton(
                    heroTag: "bookmarkBtn",
                  onPressed: () {
                    if(!isButtonDisable)
                    {
                      bookmarkSelection();
                    }
                    
                    },
                  child: FaIcon(FontAwesomeIcons.bookmark),
                  ),
                ),
                Visibility(
                  visible: isButtonOtherShow,
                  child: FloatingActionButton(
                    heroTag: "playBtn",
                  onPressed: () {
                    //if(!isButtonDisable)
                    //{
                      if(playStopButtonInSelectionList == FontAwesomeIcons.play)
                      {
                        setState((){
                          playStopButtonInSelectionList=FontAwesomeIcons.stop;
                          playStopButton=FontAwesomeIcons.stop;
                          });
                        playSelectList();
                      }
                      else
                      {
                        setState((){
                          playStopButtonInSelectionList=FontAwesomeIcons.play;
                          playStopButton=FontAwesomeIcons.play;
                          });
                        stopSelectList();
                      }
                    //}
                  },
                  child: Icon(playStopButtonInSelectionList),
                  ),
                ),
                Visibility(
                  visible: isButtonOtherShow,
                  child: FloatingActionButton(
                    heroTag: "resetBtn",
                  onPressed: () {
                    if(!isButtonDisable) resetSelection();
                    },
                  child: FaIcon(FontAwesomeIcons.times),
                  ),
                ),
                Visibility(
                  visible: isButtonLeftRightShow,
                  child: FloatingActionButton(
                    heroTag: "rightBtn",
                  onPressed: () {
                    if(!isButtonDisable) rightButton();
                    },
                  child: FaIcon(FontAwesomeIcons.arrowRight),
                  ),
                ),
                
          ],
      ),
      ),
      /*bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Color(0xff344955),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 0.0),
          height: 56.0,
          child: Row(children: <Widget>[
            IconButton(
              onPressed: showMenu,
              icon: Icon(Icons.menu),
              color: Colors.white,
            ),
            Spacer(),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.add),
              color: Colors.white,
            )
          ]),
        ),
      ),*/
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
    Widget build(BuildContext context) {
      //设置适配尺寸 (填入设计稿中设备的屏幕尺寸) 此处假如设计稿是按iPhone6的尺寸设计的(iPhone6 750*1334)
      //ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
      return ModalProgressHUD(child: _buildWidget(), inAsyncCall: _showLoading);
    }
//list view setup
Widget _myListView(BuildContext context) {
      setBookmarkList();
      //appAds.showBannerAd(state: this, anchorOffset: null);
      
      return new FutureBuilder<List>(
        //key: btnKey,
        future: loadQueryToList()/*.whenComplete(()=>{setBookmarkList()})*/,
        initialData: List(),
        builder: (context, snapshot) {
        return new ScrollablePositionedList.separated(
          //initialScrollIndex: 20,
        itemScrollController: _scrollController,
        itemCount: snapshot.data==null ? 0 : snapshot.data.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1.0, color: splashColor),
        itemBuilder: (context, index) {
          
          if(index==(snapshot.data==null ? 0 : snapshot.data.length)-1)
          {
              return Column(
                children: <Widget>[
                  Container(
                    //color: containerColor,
                    child:ListTile(
                    title: Text(snapshot.data.length == 0 ? "" : snapshot.data[index]
                    ,style: new TextStyle(
                    fontSize: ScreenUtil().setSp(fontOfTitleButton, allowFontScalingSelf: true),
                    //color: fontTextColor,
                      ),),
                    ),
                  ),
                ],
              );
              
          }
          /*else if((index+1) >= 10 && (index+1) % 10 == 0)
          {
            return Column(
                children: <Widget>[
                  Container(
                    color: listSelection[index]
                          ? lightlineListColor
                          : containerColor,
                    child:ListTile(
                    title: Text(snapshot.data==null || snapshot.data.length == 0 ? "" : snapshot.data[index]
                    ,style: new TextStyle(decoration: listBookmark.length!=0 && listBookmark[index] ? TextDecoration.underline : TextDecoration.none,
                    fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true),
                      //color: fontTextColor,
                      ),),
                    onTap: () => !isButtonDisable ? _onSelectedList(index,snapshot.data[index]) : null,
                    ),
                  ),
                  Container(
                    height: 90,
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(bottom: 20.0),
                    child: NativeAdmob(
                      // Your ad unit id
                      adUnitID: _adUnitID,
                      controller: _nativeAdController,
                      type: NativeAdmobType.banner,
                    ),
                  ),
                  
                ],
              );
            
          }*/
          else
          {
            if(listSelection[index])
            {
              return Column(
                children: <Widget>[
                  Container(
                      
                    color: //listSelection[index]?
                          lightlineListColor,
                          //: containerColor,
                    child:ListTile(
                    title: Text(snapshot.data==null || snapshot.data.length == 0 ? "" : snapshot.data[index]
                    ,style: new TextStyle(decoration: listBookmark.length!=0 && listBookmark[index] ? TextDecoration.underline : TextDecoration.none,
                    fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true),
                      //color: fontTextColor,
                      ),),
                    onTap: () => !isButtonDisable ? _onSelectedList(index,snapshot.data[index]) : null,
                    ),
                  ),
                  
                ],
              );
            }
            else
            {
              return Column(
                children: <Widget>[
                  Container(
                    child:ListTile(
                    title: Text(snapshot.data==null || snapshot.data.length == 0 ? "" : snapshot.data[index]
                    ,style: new TextStyle(decoration: listBookmark.length!=0 && listBookmark[index] ? TextDecoration.underline : TextDecoration.none,
                    fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true),
                      //color: fontTextColor,
                      ),),
                    onTap: () => !isButtonDisable ? _onSelectedList(index,snapshot.data[index]) : null,
                    ),
                  ),
                  
                ],
              );
            }
              
              
          }
          
           
        }, //itemBuilder
      );
    },
        );
        
    }
    //button title setup
    Widget _buttonTitle() {

      return FutureBuilder(
        future: loadButtonText(),
        builder: (context, snapshot) {
        return Row(
    //mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
      Text(_bibleTitleButtonText,
      style: new TextStyle(
      fontSize: ScreenUtil().setSp(fontOfTitleButton, allowFontScalingSelf: true),
        color:buttonTextColor),),
      Icon(Icons.arrow_drop_down, color: iconColor,size: ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),),
              ],
            );
          },
        );
    }

  //list view for  setup
  Widget _myListViewForTitle(BuildContext context) {
        
        return new FutureBuilder<List>(
          future: loadQueryToTitleList(),
          initialData: List(),
          builder: (context, snapshot) {
          return new ScrollablePositionedList.separated(
          itemScrollController: _scrollControllerForTitlePage,
          itemCount: snapshot.data==null ? 0 : snapshot.data.length,
          separatorBuilder: (context, index) =>
              Divider(height: 1.0, color: splashColor),
          itemBuilder: (context, index) {
            if(snapshot.data.length > index)
            {
              if(snapshot.data[index] =='' || (( (index==0 && snapshot.data[index] == FlutterI18n.translate(context, "bibleTitleSelection.1.selection")/*bibleAll["bibleTitleSelection"]["1"]["selection"]*/) || (index==bibleTitleNew && snapshot.data[index] == FlutterI18n.translate(context, "bibleTitleSelection.2.selection")/*bibleAll["bibleTitleSelection"]["2"]["selection"]*/) ) && _state==1))
              {
                return Container(
                    child:ListTile(
                    title: Text(snapshot.data.length == 0 ? "" : snapshot.data[index] =='' ? '' : snapshot.data[index]+":"
                      ,style: new TextStyle(
                      fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true),
                      //color:fontTextColor
                    ),),
                    onTap: () => null,
                    ),
                  );
              }
              else
              {
                return Container(
                    /*color: _selectedIndex != null && _selectedIndex == index
                          ? Colors.red
                          : Colors.white,*/
                    
                    child:ListTile(
                    title: Text(snapshot.data.length == 0 ? "" : snapshot.data[index]
                      ,style: new TextStyle(
                      fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true),
                      //color:fontTextColor
                      ),),
                    onTap: () => _onSelectedListTitle(snapshot.data[index],context),
                    ),
                  );
              }
            }
            
                
            
          }, //itemBuilder
        );
      },
          );
      }

    Widget myDrawer(BuildContext context) {
    return Drawer(
      child: MediaQuery.removePadding(
        context: context,
        //移除抽屉菜单顶部默认留白
        removeTop: true,
        child: new Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0), // here the desired height
          child: AppBar(
            automaticallyImplyLeading: false,
            title: Column(
              children: <Widget>[
                Text(''),//empty row
                Row(children: <Widget>[
                  IconButton(
                            //alignment: Alignment.bottomCenter,
                            icon: Icon(Icons.arrow_back, size: ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),),
                            onPressed: () => !isButtonDisable ? _onBackSelectedListTitle(context) : null,
                          ),
                  Text(
                      _bibleListTitle, 
                      style: new TextStyle(
                        fontSize: ScreenUtil().setSp(fontOfTitleButton, allowFontScalingSelf: true),
                        //color:buttonTextColor
                        ), 
                    ),
                  ],
                ),
              ]),
                
            /*Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            _bibleListTitle, 
                            style: new TextStyle(
                              fontSize: 15.0,
                            ),                      
                          ),
                        ),*///new Text(_bibleListTitle,textAlign: TextAlign.center,),
        //backgroundColor: titleColor,
        /*leading: new IconButton(
          //alignment: Alignment.bottomCenter,
          icon: new Icon(Icons.arrow_back),
          onPressed: () => _onBackSelectedListTitle(context),
        ),*/
      ),
      ),
        body:_myListViewForTitle(context)
        ),
      )
    );
  }

  Widget myDrawer2(BuildContext context) {
    return Drawer(
      child: Row(
        children: <Widget>[
          IconButton(icon: FaIcon(FontAwesomeIcons.ellipsisV,color: iconColor,),onPressed: null,)
        ],
      )
    );
  }


  }

  class MyDialog extends StatefulWidget {
    @override
    _MyDialogState createState() => new _MyDialogState();
  }

  class _MyDialogState extends State<MyDialog> {
    //timer
    Timer _timer;
    int _start = 5000;
    @override
    void initState() {
      super.initState();
      startTimer();
    }

    void startTimer() {
      const oneSec = const Duration(milliseconds: 50);
      _timer = new Timer.periodic(
        oneSec,
        (Timer timer) => setState(
          () {
            
            if (_start <= 50) {
                setState(() {
                timerStatus = 3;
              });
                timer.cancel();
                Navigator.pop(context);
              }
            else {
              setState(() {
                _start = _start - 50;
              });
              
            }
          },
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return ButtonBarTheme(
      data: ButtonBarThemeData(alignment: MainAxisAlignment.center),
      child: AlertDialog(
        shape: RoundedRectangleBorder(//Alert Dialog with Rounded corners in flutter
          borderRadius: BorderRadius.all(Radius.circular(20.0))
      ),
        title: Text(FlutterI18n.translate(context, "pleaseSelect"),textAlign: TextAlign.center,
        style: TextStyle(/*color: iconAlertDialogColor,*/fontWeight: FontWeight.bold),),
        content: new CircularPercentIndicator(
                  radius: 60.0,
                  lineWidth: 5.0,
                  percent: _start*0.0002,
                  progressColor: themeColor,
                ),
        actions: <Widget>[
          Row (
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
                IconButton(icon: FaIcon(FontAwesomeIcons.stop,/*color: iconAlertDialogColor,*/), onPressed: () {
                  setState(() {
                    _start = timerCountMins;
                    timerStatus = 1;
                  });
                  _timer.cancel();
                  Navigator.pop(context);
                }),
                IconButton(icon: FaIcon(FontAwesomeIcons.sync,/*color: iconAlertDialogColor,*/), onPressed: () {
                  setState(() {
                    _start = timerCountMins;
                    timerStatus = 2;
                  });
                  _timer.cancel();
                  Navigator.pop(context);
                }),
                IconButton(icon: FaIcon(FontAwesomeIcons.play,/*color: iconAlertDialogColor,*/), onPressed: () {
                  setState(() {
                    _start = timerCountMins;
                    timerStatus = 3;
                  });
                  _timer.cancel();
                  Navigator.pop(context);
                }),
            ]
        ),
        ],
      ),
      );
    }
  }
  
