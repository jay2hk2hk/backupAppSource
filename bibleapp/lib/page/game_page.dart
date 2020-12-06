import 'dart:io';
import 'dart:math';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:bibleapp/model/bible_bookmark.dart';
import 'package:bibleapp/util/common_value.dart';
import 'package:bibleapp/util/sql_helper.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
//import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:share/share.dart';
import '../main.dart';
import 'dart:async';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:bibleapp/util/common_value.dart';

GlobalKey globalKey = new GlobalKey(debugLabel: 'btm_app_bar');

class GamePage extends StatefulWidget {
  @override
  @override
  GamePage(GlobalKey key) {
    globalKey = key;
  }
  _GamePageState createState() => new _GamePageState();
}

class _GamePageState extends State<GamePage> {
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    //testDevices: testDevice != null ? <String>[testDevice] : null,
    //keywords: <String>['foo', 'bar'],
    //contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
  );
  //String _userName;
  //String _userId;
  final dbHelper = SQLHelper.instance;
  static double fontOfContent = 60.0;//px
  double sizeOfIcon = 50.0;
  static int page = 0; //0 = more 1 = bookmark title, 2 = bookmark, 3 = style, 4 = FAQ, 5 = about, 6 = about
  static int bibleTitleTotal = 66;
  static int bibleTitleNew = 40;
  static int bibleTitleOld = 39;
  static int titleId = 0;
  var unescape = new HtmlUnescape();//decode th html chinese word
  static var bibleTitleTotalNum = [50,40,27,36,34,24,21,4,31,24,22,25,29
                ,36,10,13,10,42,150,31,12,8,66,52,5,48
                ,12,14,3,9,1,4,7,3,3,3,2,14,4
                ,28,16,24,21,28,16,16,13,6
                ,6,4,4,5,3,6,4,3,1
                ,13,5,5,3,5,1,1,1,22];
  static String nowLevel = "upgrade";
  static bool isPressNext = true;
  static bool isAnswered = false;
  static List<String> displayItem = new List<String>();
  static List<Color> displayColorMC = [bottomNavigationColor,bottomNavigationColor,bottomNavigationColor,bottomNavigationColor];
  static int numStartX = 5;
  static int numX = 2;
  static int expStart = 0;
  static int expEnd = 0;
  static bool isPlayAds = false;
  static String nextButtonText = "";
  //String rewardedVideoAdsId = RewardedVideoAd.testAdUnitId;
  String rewardedVideoAdsId = Platform.isAndroid ? "ca-app-pub-9860072337130869/5350932207" : "ca-app-pub-9860072337130869/7088766690";
  static int maxAdsRewards = 10;
  static int todayAdsRewards = 0;

  @override
  void initState() {
    BackButtonInterceptor.add(myInterceptor);
    
    
    super.initState();
    init();
    }
    @override
  void dispose() {
    super.dispose();
    BackButtonInterceptor.remove(myInterceptor);
  }
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    //print("BACK BUTTON!"); // Do some stuff.
    if(page==1 || page==2)
    {
      setState(() {
        page=0;
      });
    }
    else
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return true;
  }
  @override
    Widget build(BuildContext context) {
      Widget tempList;
      if(page==0) tempList = _myListViewGame(context);
      else if(page==1) tempList = _myListViewChapterMC(context);
      else if(page==2) tempList = _myListViewGameRules(context);
      return tempList;
    }

Widget _myListViewGame(BuildContext context) {
      final europeanCountries = [FlutterI18n.translate(context, "gameMenuChapterMC"),FlutterI18n.translate(context, "gameMenuGameRules")];
      return new Scaffold(
      appBar: AppBar( 
        title: Text(FlutterI18n.translate(context, "bottomBarGame"),style: TextStyle(fontSize: ScreenUtil().setSp(fontOfContent-5, allowFontScalingSelf: true),),),
      ),
      body: new Center(
        child: ListView.separated(
        itemCount: europeanCountries.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            child:ListTile(
            title: Text(europeanCountries[index],style: TextStyle(fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true),),),
            ),
            onTap: () {
              setState(() {
                if(index==0)
                  page = 1;
                else if(index==1)
                  page = 2;  
              });
            }
            /*=> Scaffold
                    .of(context)
                    .showSnackBar(SnackBar(content: Text(index.toString()))),*/
          );
           
        }, //itemBuilder
        separatorBuilder: (context, index) {
        return Divider();
        }, //separatorBuilder
      ),
      ),
    );
      // backing data

    }


    void shareToOther()
    {
      Share.share(copyShareReturnText());
    }

    String copyShareReturnText()
    {
      String tempText = FlutterI18n.translate(context, "shareAppText");
      
      return tempText;
    }

    Widget _myListViewChapterMC(BuildContext context) {

      // backing data
      //var europeanCountries = queryBibleTitleByDefault();
      nowLevel = FlutterI18n.translate(context,"displayCurrectLevel")+" "+prefs.getInt(sharePrefGameLevel).toString()+"\n"+FlutterI18n.translate(context,"nextLevelText")+" "+expStart.toString()+"/"+expEnd.toString();
      if(todayAdsRewards<maxAdsRewards) nextButtonText = isPlayAds ? FlutterI18n.translate(context,"adsToQuestionButton") : FlutterI18n.translate(context,"buttonNext");
      return 
      new Scaffold(
      appBar: AppBar( 
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),),
          onPressed: () => {
            setState(() {
                page = 0;
              })
          },
        ), 
        title: Text(FlutterI18n.translate(context, "gameMenuChapterMC"),style: TextStyle(fontSize: ScreenUtil().setSp(fontOfContent-5, allowFontScalingSelf: true),),),
      ),
      body: new Center(
        child:new Container(
              margin: new EdgeInsets.all(4.0),
              constraints: new BoxConstraints.expand(),
              child: ListView(
                children: <Widget>[
                  new Column(
                    children: <Widget>[
                      //new Container(height: 5.0),
                      new Container(
                        padding: const EdgeInsets.symmetric(vertical: 14.0,horizontal: 14.0),
                        //height: 100.0,
                        width: MediaQuery.of(context).size.width,//screen size
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(nowLevel,style: new TextStyle(fontWeight: FontWeight.bold,fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true))),
                            LinearProgressIndicator(
                            backgroundColor: Colors.cyanAccent,
                            valueColor: new AlwaysStoppedAnimation<Color>(Colors.green[300]),
                            value: (expStart/expEnd),
                          ),
                          ],
                        ),
                      ),
                      //new Container(height: 5.0),
                      new Container(
                        padding: const EdgeInsets.symmetric(vertical: 14.0,horizontal: 14.0),
                        //height: 100.0,
                        width: MediaQuery.of(context).size.width,//screen size

                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: gameLogicMC(context),
                        ),
                      ),
                      //new box style
                      new Container(height: 5.0),
                      
                      
                    ],
                  ),
                ],
              ),
              
          ),
      )
      );

    }

    Widget _myListViewGameRules(BuildContext context) {

      // backing data
      var europeanCountries = [FlutterI18n.translate(context, "gameRulesText")];

      return 
      new Scaffold(
      appBar: AppBar( 
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),),
          onPressed: () => {
            setState(() {
                page = 0;
              })
          },
        ), 
        title: Text(FlutterI18n.translate(context, "gameMenuGameRules"),style: TextStyle(fontSize: ScreenUtil().setSp(fontOfContent-5, allowFontScalingSelf: true),),),
        
      ),
      body: new Center(
        child:ListView.separated(
        itemCount: europeanCountries.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            child:ListTile(
            title: Text(europeanCountries[index],style: TextStyle(fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true),),),
            ),
          );
           
        }, //itemBuilder
        separatorBuilder: (context, index) {
        return Divider();
        }, //separatorBuilder
      ),
      )
      );

    }

  List<Widget> gameLogicMC(BuildContext context)
  {
    
    if(isPressNext)    
        displayItem = gameLogicCode();

    List<Widget> tempList = new List<Widget>();

    /*tempList.add(
      Row(children: [
        Text(displayItem[0],
                                  style: new TextStyle(fontWeight: FontWeight.bold
                                  ,fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true)
                                  //,color: fontTextColor
                                  )
                              ),
      ],),
      
    );*/
    
    //tempList.add(new Container(height: 5.0),);

    tempList.add(
      new Text(displayItem[1],
      style:new TextStyle(fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true)
                            ,//color: fontTextColor
                            ),),
    ); 
    
    for(int i=2;i<6;i++)
    {
      tempList.add(
              RaisedButton(
                color:displayColorMC[i-2],
                textColor: buttonTextColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Text(displayItem[i]
                  ,style:new TextStyle(fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true)
                  ,//color: buttonTextColor
                  ),),
                      onPressed: (){
                        /*if(prefs!=null)
                        {
                            
                        }*/
                        if(!isAnswered && !isPlayAds)
                        {
                          setState(() {
                          nextButtonText = FlutterI18n.translate(context,"buttonNext");
                          isAnswered = true;
                          if(displayItem[6]==displayItem[i])
                          {
                            displayColorMC[i-2]=correctAnswerColor;
                            int tempInt = prefs.getInt(sharePrefCorrectQuestionNum)+1;
                            prefs.setInt(sharePrefCorrectQuestionNum, tempInt);
                            if(prefs.getInt(sharePrefCorrectQuestionNum)>=expEnd)
                            {
                              prefs.setInt(sharePrefGameLevel, prefs.getInt(sharePrefGameLevel)+1);
                              prefs.setInt(sharePrefCorrectQuestionNum, 0);
                            }
                            
                            
                          }
                          else
                          {
                            displayColorMC[i-2]=weekEndTextColor;
                            if(displayItem[6]==displayItem[2])
                              displayColorMC[0]=correctAnswerColor;
                            else if(displayItem[6]==displayItem[3])
                              displayColorMC[1]=correctAnswerColor;
                            else if(displayItem[6]==displayItem[4])
                              displayColorMC[2]=correctAnswerColor;
                            else if(displayItem[6]==displayItem[5])
                              displayColorMC[3]=correctAnswerColor;
                            
                          }
                          
                          int tempInt2 = prefs.getInt(sharePrefTotalAnsweredNum)+1;
                          prefs.setInt(sharePrefTotalAnsweredNum, tempInt2);
                          if(tempInt2%10==0)
                          {
                            if(todayAdsRewards>maxAdsRewards)
                            {
                              nextButtonText = FlutterI18n.translate(context,"buttonOutToday");
                            }
                            else nextButtonText = FlutterI18n.translate(context,"adsToQuestionButton");
                            isPlayAds = true;
                          }
                          
                          
                            

                          setLevelExp();
                              
                          });
                        }
                        
                        
                      },
                ),
              );     
              tempList.add(SizedBox(height: ScreenUtil().setSp(10, allowFontScalingSelf: true),));
    }
    tempList.add(new Container(height: 5.0),);         
    tempList.add(
      Visibility(
                  visible: isAnswered || isPlayAds,
                  child: RaisedButton(
                color:bottomNavigationColor,
                textColor: buttonTextColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Text(nextButtonText
                  ,style:new TextStyle(fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true)
                  ,//color: buttonTextColor
                  ),),
                      onPressed: (){
                        /*if(prefs!=null)
                        {
                            
                        }*/
                        setState(() {
                          if(isPlayAds && todayAdsRewards<=maxAdsRewards)
                          {
                            RewardedVideoAd.instance.show().catchError((e) => print("error in loading 1st time"));
                          }
                          else if(!isPlayAds)
                          {
                            reSetTheQuestion();
                          }
                          

                          });
                        
                      },
                ),
                ),
              
              );
      
                          

    return tempList;
  }

  void reSetTheQuestion()
  {
    todayAdsRewards = prefs.getInt(sharePrefTodayRewardAdsGameMC);
    if(todayAdsRewards==0)
      isPlayAds = false;
    isPressNext = true;
    isAnswered = false;
    displayColorMC = [bottomNavigationColor,bottomNavigationColor,bottomNavigationColor,bottomNavigationColor];
  }

  void init()
  {
    RewardedVideoAd.instance.listener =
        (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      print("RewardedVideoAd event $event");
      if (event == RewardedVideoAdEvent.rewarded) {
        setState(() {
          todayAdsRewards = prefs.getInt(sharePrefTodayRewardAdsGameMC)+1;
          prefs.setInt(sharePrefTodayRewardAdsGameMC, todayAdsRewards);
          nextButtonText = FlutterI18n.translate(context,"buttonNext");
          isPlayAds = false;
          reSetTheQuestion();
          
        });
      }
      else if(event == RewardedVideoAdEvent.closed)
      {
          RewardedVideoAd.instance.load(
                        adUnitId: rewardedVideoAdsId,
                        targetingInfo: targetingInfo).catchError((e) => print("error in loading 1st time"));
      }
    };
    RewardedVideoAd.instance.load(
                        adUnitId: rewardedVideoAdsId,
                        targetingInfo: targetingInfo).catchError((e) => print("error in loading again"));
    //prefs.setInt(sharePrefCorrectQuestionNum, 9); 
    //prefs.setInt(sharePrefTotalAnsweredNum, 9); 
    //prefs.setInt(sharePrefGameLevel, 1);
    //prefs.setInt(sharePrefTodayRewardAdsGameMC, 9);
    reSetTheQuestion();
    
    setLevelExp();
    
  }

  void setLevelExp()
  {
    expEnd = numStartX;
    int tempEnd = prefs.getInt(sharePrefGameLevel);
    for(int i=0;i<tempEnd;i++)
    {
        expEnd *= numX;
    }
    
    expStart = prefs.getInt(sharePrefCorrectQuestionNum);
  }

  List<String> gameLogicCode()
  {
    
    String questionNo = FlutterI18n.translate(context,"questionText")+" 1";
    int titleIdMC = new Random().nextInt(bibleTitleTotalNum.length-1);
    int titleNumMC = new Random().nextInt(bibleTitleTotalNum[titleIdMC]);
    //titleIdMC=63;
    //titleNumMC=0;
    List<String> tempBibleList = queryBibleContentByTitle((titleIdMC+1).toString(),(titleNumMC+1).toString());
    int titleNumCharNumMC = new Random().nextInt(tempBibleList.length-1);
    //titleNumCharNumMC = 14;

    String theQuestion = "";
    int titleIdMCWrong1 = 0;
    int titleNumMCCWrong1 = 0;
    int titleIdMCWrong2 = 0;
    int titleNumMCCWrong2 = 0;
    int titleIdMCWrong3 = 0;
    int titleNumMCCWrong3 = 0;

    do
    {
      titleIdMCWrong1 = new Random().nextInt(bibleTitleTotalNum.length-1);
    }
    while(titleIdMCWrong1==titleIdMC);
    titleNumMCCWrong1 = new Random().nextInt(bibleTitleTotalNum[titleIdMCWrong1]);

    do
    {
      titleIdMCWrong2 = new Random().nextInt(bibleTitleTotalNum.length-1);
    }
    while(titleIdMCWrong2==titleIdMC || titleIdMCWrong2==titleIdMCWrong1);
    titleNumMCCWrong2 = new Random().nextInt(bibleTitleTotalNum[titleIdMCWrong2]);

    do
    {
      titleIdMCWrong3 = new Random().nextInt(bibleTitleTotalNum.length-1);
    }
    while(titleIdMCWrong3==titleIdMC || titleIdMCWrong3==titleIdMCWrong1 || titleIdMCWrong3==titleIdMCWrong2);
    titleNumMCCWrong3 = new Random().nextInt(bibleTitleTotalNum[titleIdMCWrong3]);

    titleIdMC+=1;
    titleNumMC+=1;
    titleIdMCWrong1 += 1;
    titleNumMCCWrong1 += 1;
    titleIdMCWrong2 += 1;
    titleNumMCCWrong2 += 1;
    titleIdMCWrong3 += 1;
    titleNumMCCWrong3 += 1;

    do{
      titleNumCharNumMC = new Random().nextInt(tempBibleList.length-1);
      //titleNumCharNumMC = 14;
      theQuestion = tempBibleList[titleNumCharNumMC].substring(tempBibleList[titleNumCharNumMC].indexOf('.')+1);
    }while(theQuestion == "");

    theQuestion =  /*FlutterI18n.translate(context, "bibleTitle.$titleIdMC.title")+" "+titleNumMC.toString() + " " + */tempBibleList[titleNumCharNumMC];

    List<String> tempAnswer = [
      FlutterI18n.translate(context, "bibleTitle.$titleIdMC.title")+" "+titleNumMC.toString()
      ,FlutterI18n.translate(context, "bibleTitle.$titleIdMCWrong1.title")+" "+titleNumMCCWrong1.toString()
      ,FlutterI18n.translate(context, "bibleTitle.$titleIdMCWrong2.title")+" "+titleNumMCCWrong2.toString()
      ,FlutterI18n.translate(context, "bibleTitle.$titleIdMCWrong3.title")+" "+titleNumMCCWrong3.toString()
      ];
      tempAnswer.shuffle();

      List<String> temp = new List<String>();
      String correctAnswer = FlutterI18n.translate(context, "bibleTitle.$titleIdMC.title")+" "+titleNumMC.toString();
      temp.add(questionNo);
      temp.add(theQuestion);
      temp.add(tempAnswer[0]);
      temp.add(tempAnswer[1]);
      temp.add(tempAnswer[2]);
      temp.add(tempAnswer[3]);
      temp.add(correctAnswer);
      isPressNext = false;
      return temp;

  }

  List<String> queryBibleContentByTitle(String titleId, String titleNum) {
      String temp = FlutterI18n.translate(context, "bible.$titleId.$titleNum.content");
    List<String>tmepBibleList = unescape.convert(temp).split("=.=");
    
    return tmepBibleList;
  }


    Future<List<String>> getBibleBookmarkByTitleId(int titleId) async
    {
      List<BibleBookmark> temp = await dbHelper.getBibleBookmarkByTitleId(titleId);
      List<String> tmepList = new List<String>();
      if(temp.length!=0)
      {
        for(BibleBookmark tempBookmark in temp)
        {
          String temp = titleId.toString() + ":"+ tempBookmark.content.toString()+":"+tempBookmark.text.toString();
          List<String> tempTitleList = temp.split(':');
          List<String> tempContentList = tempTitleList[2].split('-');
          String tempDisplayContent = FlutterI18n.translate(context, "bibleTitle."+tempTitleList[0]+".title")+" " + tempTitleList[1] + ":";
          if(tempContentList.length>1)
            tempDisplayContent+=tempContentList[0]+"-"+tempContentList[tempContentList.length-1]+"";
          else  tempDisplayContent+=tempContentList[0];
          tempDisplayContent+="+";                            
          for(int i=0;i<tempContentList.length;i++)
          {
            String temp1 = FlutterI18n.translate(context, "bible."+tempTitleList[0]+"."+tempTitleList[1]+".content").split('=.=')[int.parse(tempContentList[i])-1];
            tempDisplayContent+=temp1.substring(temp1.indexOf('.')+1).trim();
          }   
          tmepList.add(unescape.convert(tempDisplayContent));
          //tmepList.add(titleId.toString() + ":"+ tempBookmark.content.toString()+":"+tempBookmark.text.toString());
        }
      }
      //else
      //  tmepList.add('No');
      
      return tmepList;
    }


  }