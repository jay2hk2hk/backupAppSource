import 'dart:io';
import 'dart:math';

import 'package:bibleapp/model/bible_crown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:bibleapp/util/common_value.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bibleapp/util/sql_helper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'dart:async';


import '../main.dart';

GlobalKey globalKey = new GlobalKey(debugLabel: 'btm_app_bar');

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => new _MainPageState();
  @override
  MainPage(GlobalKey key) {
    globalKey = key;
  }
  

}

class _MainPageState extends State<MainPage>{
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    //testDevices: testDevice != null ? <String>[testDevice] : null,
    //keywords: <String>['foo', 'bar'],
    //contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
  );
  final dbHelper = SQLHelper.instance;
  final dateFormat = new DateFormat('yyyy-MM-dd');
  static double fontOfContent = 60.0;//px
  static int crownNum = 0;
  static double sizeOfIcon = 50.0;
  static String displayLanguage = languageTextValue[0];
  var unescape = new HtmlUnescape();//decode th html chinese word
  //String rewardedVideoAdsId = RewardedVideoAd.testAdUnitId;
  //String firebaseAdId = FirebaseAdMob.testAppId;
  String rewardedVideoAdsId = Platform.isAndroid ? "ca-app-pub-9860072337130869/5350932207" : "ca-app-pub-9860072337130869/7088766690";
  String firebaseAdId = Platform.isAndroid ? "ca-app-pub-9860072337130869~8212800236" : "ca-app-pub-9860072337130869~3480731194";
  int latestUpdateVersionNum = 2;//check is display the latest update box or not
  

  @override
  void initState()
  {
    super.initState();
    displayLanguage = prefs.getString(sharePrefDisplayLanguage);
    FirebaseAdMob.instance.initialize(appId: firebaseAdId);
    //_bannerAd = createBannerAd()..load();
    RewardedVideoAd.instance.listener =
        (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      print("RewardedVideoAd event $event");
      if (event == RewardedVideoAdEvent.rewarded) {
        setState(() {
          var now = DateTime.parse(dateFormat.format(DateTime.now()));
          insertCrown(1, now.toString());
          //totalOfCrown();
          crownNum+=1;
          prefs.setInt(sharePrefBibleTodaysGotCrownTotal,crownNum);
          prefs.setBool(sharePrefBibleTodaysGotCrown, true);
        });
      }
    };
    RewardedVideoAd.instance.load(
                        adUnitId: rewardedVideoAdsId,
                        targetingInfo: targetingInfo);
    
    totalOfCrown();
    crownNum = prefs.getInt(sharePrefBibleTodaysGotCrownTotal);

    if(prefs.getInt(sharePrefUpdateVersionNum)<latestUpdateVersionNum)
    {
      prefs.setInt(sharePrefUpdateVersionNum, latestUpdateVersionNum); 
      WidgetsBinding.instance.addPostFrameCallback((_) => 
      showDialog(
                barrierDismissible: true,
                context: context,
                builder: (_) {
                  return MyDialog();
                })
      );
    }
    
    
  }

  @override
  void dispose() {
    //为了避免内存泄露，需要调用.dispose
    super.dispose();
    /*_bannerAd?.dispose();
    _nativeAd?.dispose();
    _interstitialAd?.dispose();*/
  }

  /*
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    //testDevices: testDevice != null ? <String>[testDevice] : null,
    //keywords: <String>['foo', 'bar'],
    //contentUrl: 'http://foo.com/bar.html',
    childDirected: false,
    nonPersonalizedAds: true,
  );
  BannerAd _bannerAd;
  NativeAd _nativeAd;
  InterstitialAd _interstitialAd;
  int _coins = 0;
  BannerAd createBannerAd() {
    //print(BannerAd.testAdUnitId);
    return BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
      adUnitId: InterstitialAd.testAdUnitId,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("InterstitialAd event $event");
      },
    );
  }

  NativeAd createNativeAd() {
    return NativeAd(
      adUnitId: NativeAd.testAdUnitId,
      factoryId: 'adFactoryExample',
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("$NativeAd event $event");
      },
    );
  }*/


  @override
  Widget build(BuildContext context) {
    //ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return /*MaterialApp(
      theme:prefs.getInt(sharePrefLightDark) ==0 ? ThemeData.light(): ThemeData.dark(),
      title: FlutterI18n.translate(context, "appName"),
      home: */Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, "appName")
          ,style: TextStyle(/*color: buttonTextColor,*/fontSize: ScreenUtil().setSp(fontOfContent-5, allowFontScalingSelf: true),),),
        actions: <Widget>[
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
                
            new PopupMenuDivider(height: 1.0),
            new PopupMenuItem<String>(
                value: languageTextValue[2], child: new Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: new Text(chnageLanguageList[2],style: TextStyle(/*color: fontTextColor,*/ fontSize: ScreenUtil().setSp(sizeOfIcon-10, allowFontScalingSelf: true),
                  ),)),
                ),
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
      }),
      SizedBox(width:20),
        ],
        ),
        body: Center(
          child: new Container(
              margin: new EdgeInsets.all(4.0),
              constraints: new BoxConstraints.expand(),
              child: ListView(
                children: <Widget>[
                  new Column(
                    children: <Widget>[
                      new Container(height: 5.0),
                      new Container(
                        padding: const EdgeInsets.symmetric(vertical: 14.0,horizontal: 14.0),
                        //height: 100.0,
                        width: MediaQuery.of(context).size.width,//screen size
                        /*decoration: BoxDecoration(
                          //color: backgroundColor,
                          shape: BoxShape.rectangle,
                          borderRadius: new BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: boxShadowColor,
                              blurRadius: 10.0,
                            offset: new Offset(0.0, 10.0),
                            ),
                          ]
                        ),*/
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: bibleSentenceItem(context),
                        ),
                      ),
                      //new box style
                      new Container(height: 5.0),
                      new Container(
                        padding: const EdgeInsets.symmetric(vertical: 14.0,horizontal: 14.0),
                        //height: 100.0,
                        width: MediaQuery.of(context).size.width,//screen size
                        /*decoration: BoxDecoration(
                          //color: backgroundColor,
                          shape: BoxShape.rectangle,
                          borderRadius: new BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: boxShadowColor,
                              blurRadius: 10.0,
                            offset: new Offset(0.0, 10.0),
                            ),
                          ]
                        ),*/
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: bibleTodaysItem(context),
                        ),
                      ),
                      new Container(height: 5.0),
                      new Container(
                        padding: const EdgeInsets.symmetric(vertical: 14.0,horizontal: 14.0),
                        //height: 100.0,
                        width: MediaQuery.of(context).size.width,//screen size
                        /*decoration: BoxDecoration(
                          //color: backgroundColor,
                          shape: BoxShape.rectangle,
                          borderRadius: new BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: boxShadowColor,
                              blurRadius: 10.0,
                            //offset: new Offset(0.0, 10.0),
                            ),
                          ]
                        ),*/
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: bibleCrownItem(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
          ),
          
          
        ),
      //),
    );
  }

  //language
  changeLanguage(String value) async {
    displayLanguage = value;
    prefs.setString(sharePrefDisplayLanguage, displayLanguage);
    String language = "";
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
        if(!haveTts) language = languageVolumeValue[2];*/
        Platform.isAndroid ? language = languageVolumeValue[1] : language = languageTextValue[1];
      }
        
      else if(languageTextValue[2]==value)
        language = languageVolumeValue[2];
      else if(languageTextValue[3]==value)
        language = languageVolumeValue[3];
      prefs.setString(sharePrefSoundLanguage, language);  
      RestartWidget.restartApp(context);
    });
  }

  void insertCrown(int type, String date) async
    {
      final fido = BibleCrown(
        type: type,
        date: date,
      );
      dbHelper.insertCrown(fido);
    }

  void totalOfCrown() async
  {
    List<BibleCrown> temp = await dbHelper.getAllBibleCrown();
    prefs.setInt(sharePrefBibleTodaysGotCrownTotal, temp.length);
     
    //return temp.length>=0 ? 0 : temp.length;
  }  

  List<Widget> bibleCrownItem(BuildContext context)
  {
    List<Widget> tempList = new List<Widget>();
    
    
    tempList.add(
      Text(FlutterI18n.translate(context, "totalCrownText"),
                                  style: new TextStyle(fontWeight: FontWeight.bold
                                  ,fontSize: ScreenUtil().setSp(fontOfContent, /*allowFontScalingSelf: true*/)
                                  //,color: fontTextColor
                                  )
                              ),
    );
    
    tempList.add(
      Row(
          children: <Widget>[
        Icon(FontAwesomeIcons.crown,color: Colors.yellowAccent[700],size: ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),),
        new Text("  "+FlutterI18n.translate(context, "totalCrownCount") +" "+crownNum.toString(),style:new TextStyle(fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true)
                            ,//color: fontTextColor
                            ),),
          ],
          ),
      
    );                          

    return tempList;
  }


  List<Widget> bibleSentenceItem(BuildContext context)
  {
    List<Widget> tempList = new List<Widget>();
    int titleNum = new Random().nextInt(saveAllBibleSentence.length-1);
    int contentNum = new Random().nextInt(saveAllBibleSentence[titleNum].length-1);
    String temp = saveAllBibleSentence[titleNum][contentNum];
    List<String> tempTitleList = temp.split(':');
    List<String> tempContentList = tempTitleList[2].split('-');
    
    
    tempList.add(
      Row(children: [
        Text(FlutterI18n.translate(context, "mainPageBibleSentenceTitle"),
                                  style: new TextStyle(fontWeight: FontWeight.bold
                                  ,fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true)
                                  //,color: fontTextColor
                                  )
                              ),
        IconButton(icon: FaIcon(FontAwesomeIcons.redo, size: ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),), onPressed: () {setState(() {});}),
      ],),
      
    );
    
    String tempDisplayContent = "";
    String tempTitle = "";
    if(tempContentList.length>1)
      tempTitle+=tempContentList[0]+"-"+tempContentList[tempContentList.length-1]+"";
     else  tempTitle+=tempContentList[0];
    tempTitle+=" ";   

    for(int i=0;i<tempContentList.length;i++)
    {
      String temp1 = FlutterI18n.translate(context, "bible."+tempTitleList[0]+"."+tempTitleList[1]+".content").split('=.=')[int.parse(tempContentList[i])-1];
      tempDisplayContent+=unescape.convert(temp1).substring(temp1.indexOf('.')+1).trim();
    }
    
    tempList.add(
      RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
            color:bottomNavigationColor,
            textColor: buttonTextColor,
            child: Text(FlutterI18n.translate(context, "bibleTitle."+tempTitleList[0]+".title")+" " + tempTitleList[1]+":"+ tempTitle
            ,style:new TextStyle(fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true)
            ,//color: buttonTextColor
            ),),
                onPressed: (){
                  if(prefs!=null)
                  {
                      prefs.setString(sharePrefTitleId, tempTitleList[0]);
                      prefs.setString(sharePrefTitleNum, tempTitleList[1]);
                      prefs.setString(sharePrefContentNum, tempContentList[0].toString());
                  }
                  final BottomNavigationBar navigationBar = globalKey.currentWidget;
                  navigationBar.onTap(1);
                },
                //color: raisedButtonColor,
                //textColor: buttonTextColor,
                //padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                //splashColor: splashColor,
          ),
    );
    

    tempList.add(
      new Text(tempDisplayContent,style:new TextStyle(fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true)
                            ,//color: fontTextColor
                            ),),
    );                          

    return tempList;
  }
  /*
  String bibleSentenceText(BuildContext context)
  {
    int titleNum = new Random().nextInt(saveAllBibleSentence.length-1);
    int contentNum = new Random().nextInt(saveAllBibleSentence[titleNum].length-1);
    String temp = saveAllBibleSentence[titleNum][contentNum];
    List<String> tempTitleList = temp.split(':');
    List<String> tempContentList = tempTitleList[2].split('-');
    String tempDisplayContent = FlutterI18n.translate(context, "bibleTitle."+tempTitleList[0]+".title")+" " + tempTitleList[1] + ":";
    
    if(tempContentList.length>1)
      tempDisplayContent+=tempContentList[0]+"-"+tempContentList[tempContentList.length-1]+"";
     else  tempDisplayContent+=tempContentList[0];
    tempDisplayContent+="\n";                            
    for(int i=0;i<tempContentList.length;i++)
    {
      String temp1 = FlutterI18n.translate(context, "bible."+tempTitleList[0]+"."+tempTitleList[1]+".content").split('=.=')[int.parse(tempContentList[i])-1];
      tempDisplayContent+=temp1.substring(temp1.indexOf('.')+1).trim();
    }                            

    return tempDisplayContent;
  }
  */
  List<Widget>bibleTodaysItem(BuildContext context)
  {
    List<Widget> tempList = new List<Widget>();
    /*DateTime todayDate = new DateTime.now();
    int todayDay = todayDate.day;
    int todayMonth = todayDate.month;*/
    String temp = prefs.getString(sharePrefBibleTodaysString);
    String temp2 = prefs.getString(sharePrefBibleTodaysReadString);
    //String temp = "19:1,"+"40:1,"+"1:1,"+"1:2";
    //String temp = saveAllBibleTodaysSentence[todayMonth-1][todayDay-1];
    //String temp = "19:30,"+"52:2,"+"23:13-14";
    List<String> tempTodaysList = temp.split(',');
    List<String> tempTodaysList2 = temp2.split(',');
    String tempDisplayContent = "";

    tempList.add(
      new Text(FlutterI18n.translate(context, "mainPageBibleTodaysTitle"),
                                  style: new TextStyle(fontWeight: FontWeight.bold,
                                  fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true)
                                  ,//color: fontTextColor
                                  )
                              ),
    );
    //print(prefs.getBool(sharePrefBibleTodaysGotCrown));
    if(tempTodaysList.length>0)
    {
      for(int i=0;i<tempTodaysList.length;i++)
      {
        List<String> tempTitleList = tempTodaysList[i].split(':');
        //List<String> tempContentList = tempTitleList[1].split('-');
        tempDisplayContent = FlutterI18n.translate(context, "bibleTitle."+tempTitleList[0]+".title");
        List<String> tempContentTitleList = tempTitleList[1].split('-');
        for(int j=0;j<tempContentTitleList.length;j++)
        {
          tempList.add(
            !temp2.contains(tempTodaysList[i]) ?
            Text(FlutterI18n.translate(context, "bibleTitle."+tempTitleList[0]+".title")+" " + tempContentTitleList[j]
              ,style:new TextStyle(fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true)
              ,//color: buttonTextColor
              ),) :
              RaisedButton(
                color:bottomNavigationColor,
            textColor: buttonTextColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              child: Text(FlutterI18n.translate(context, "bibleTitle."+tempTitleList[0]+".title")+" " + tempContentTitleList[j]
              ,style:new TextStyle(fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true)
              ,//color: buttonTextColor
              ),),
                  onPressed: (){
                    if(prefs!=null)
                    {
                        prefs.setString(sharePrefTitleId, tempTitleList[0]);
                        prefs.setString(sharePrefTitleNum, tempContentTitleList[j]);
                        
                    }
                    final BottomNavigationBar navigationBar = globalKey.currentWidget;
                    navigationBar.onTap(1);
                  },
                  //color: raisedButtonColor,
                  //textColor: buttonTextColor,
                  //padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                  //splashColor: splashColor,
            ),
          );
          tempList.add(SizedBox(height: ScreenUtil().setSp(10, allowFontScalingSelf: true),));
        }
      }
    }
    if(!prefs.getBool(sharePrefBibleTodaysGotCrown) && tempTodaysList2.length<=1 && tempTodaysList2[0]=="")
    {
      tempList.add(
              RaisedButton(
                color:bottomNavigationColor,
            textColor: buttonTextColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              child: Text(FlutterI18n.translate(context, "wantGetCrownText")
              ,style:new TextStyle(fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true)
              ,//color: buttonTextColor
              ),),
                  onPressed: (){
                    
                    RewardedVideoAd.instance.show();
                  },
                  //color: raisedButtonColor,
                  //textColor: buttonTextColor,
                  //padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                  //splashColor: splashColor,
            ),
          );
    }
    else if(prefs.getBool(sharePrefBibleTodaysGotCrown))
    {
      tempList.add(
        Row(
          children: <Widget>[
        Icon(FontAwesomeIcons.crown,color: Colors.yellowAccent[700],size: ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),),
        new Text("  "+FlutterI18n.translate(context, "gotCrownText"),style:new TextStyle(fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true)
                            ,//color: fontTextColor
                            ),),
          ],
          ),
      );
    }

    

    return tempList;
  }
  /*
  String bibleTodaysText(BuildContext context)
  {
    DateTime todayDate = new DateTime.now();
    int todayDay = todayDate.day;
    int todayMonth = todayDate.month;

    String temp = saveAllBibleTodaysSentence[todayMonth-1][todayDay-1];
    //String temp = "19:30,"+"52:2,"+"23:13-14";
    List<String> tempTodaysList = temp.split(',');
    String tempDisplayContent = "";
    for(int i=0;i<tempTodaysList.length;i++)
    {
      List<String> tempTitleList = tempTodaysList[i].split(':');
      //List<String> tempContentList = tempTitleList[1].split('-');
      tempDisplayContent += FlutterI18n.translate(context, "bibleTitle."+tempTitleList[0]+".title")+" " + tempTitleList[1];
      if(i!=tempTodaysList.length-1) tempDisplayContent+= ", ";
    }

    return tempDisplayContent;
  }
  */
}

class MyDialog extends StatefulWidget {
    @override
    _MyDialogState createState() => new _MyDialogState();
  }

  class _MyDialogState extends State<MyDialog> {
    @override
    void initState() {
      super.initState();
      
    }



    @override
    Widget build(BuildContext context) {
      return ButtonBarTheme(
      data: ButtonBarThemeData(alignment: MainAxisAlignment.center),
      child: AlertDialog(
        shape: RoundedRectangleBorder(//Alert Dialog with Rounded corners in flutter
          borderRadius: BorderRadius.all(Radius.circular(20.0))
      ),
        title: Text(FlutterI18n.translate(context, "latestUpdates"),textAlign: TextAlign.center,
        style: TextStyle(/*color: iconAlertDialogColor,*/fontWeight: FontWeight.bold),),
        content: Text(FlutterI18n.translate(context,"latestUpdatesText")),
        actions: <Widget>[
          Row (
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
                IconButton(icon: FaIcon(FontAwesomeIcons.times,/*color: iconAlertDialogColor,*/), onPressed: () {
                  Navigator.pop(context);
                }),
                
            ]
        ),
        ],
      ),
      );
    }
  }

