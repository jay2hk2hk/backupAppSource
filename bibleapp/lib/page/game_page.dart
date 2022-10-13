import 'dart:io';
import 'dart:math';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:bibleapp/model/bible_bookmark.dart';
import 'package:bibleapp/util/common_value.dart';
import 'package:bibleapp/util/sql_helper.dart';
//import 'package:firebase_admob/firebase_admob.dart';
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
import 'package:google_mobile_ads/google_mobile_ads.dart';
//import 'package:native_admob_flutter/native_admob_flutter.dart';

GlobalKey globalKey = new GlobalKey(debugLabel: 'btm_app_bar');

class GamePage extends StatefulWidget {
  @override
  @override
  GamePage(GlobalKey key) {
    globalKey = key;
  }
  _GamePageState createState() => new _GamePageState();
}

const int maxFailedLoadAttempts = 3;

class _GamePageState extends State<GamePage> {
  /*static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    //testDevices: testDevice != null ? <String>[testDevice] : null,
    //keywords: <String>['foo', 'bar'],
    //contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
  );*/
  static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );
  //String _userName;
  //String _userId;
  final dbHelper = SQLHelper.instance;
  static double fontOfContent = 60.0; //px
  double sizeOfIcon = 50.0;
  static int page =
      0; //0 = more 1 = bookmark title, 2 = bookmark, 3 = style, 4 = FAQ, 5 = about, 6 = about
  static int bibleTitleTotal = 66;
  static int bibleTitleNew = 40;
  static int bibleTitleOld = 39;
  static int titleId = 0;
  var unescape = new HtmlUnescape(); //decode th html chinese word
  static var bibleTitleTotalNum = [
    50,
    40,
    27,
    36,
    34,
    24,
    21,
    4,
    31,
    24,
    22,
    25,
    29,
    36,
    10,
    13,
    10,
    42,
    150,
    31,
    12,
    8,
    66,
    52,
    5,
    48,
    12,
    14,
    3,
    9,
    1,
    4,
    7,
    3,
    3,
    3,
    2,
    14,
    4,
    28,
    16,
    24,
    21,
    28,
    16,
    16,
    13,
    6,
    6,
    4,
    4,
    5,
    3,
    6,
    4,
    3,
    1,
    13,
    5,
    5,
    3,
    5,
    1,
    1,
    1,
    22
  ];
  static String nowLevel = "upgrade";
  static bool isPressNext = true;
  static bool isAnswered = false;
  static List<String> displayItem = new List<String>();
  static List<Color> displayColorMC = [
    bottomNavigationColor,
    bottomNavigationColor,
    bottomNavigationColor,
    bottomNavigationColor
  ];
  static int numStartX = 5;
  static int numX = 2;
  static int expStart = 0;
  static int expEnd = 0;
  static bool isPlayAds = false;
  static String nextButtonText = "";
  //String rewardedVideoAdsId = RewardedVideoAd.testAdUnitId;
  String rewardedVideoAdsId = Platform.isAndroid
      ? "ca-app-pub-9860072337130869/5350932207"
      : "ca-app-pub-9860072337130869/7088766690";
  static int maxAdsRewards = 900000;
  static int todayAdsRewards = 0;
  static bool todayCanAd = true;
  static int totalTodayAnswerNumMax = 100;
  static int totalTodayCorrectAnswerNum = 0;
  static int todayNextButtonStatus = 0; //0 = next, 1 = ads, 2 = end

  //BQA thing
  static List<String> displayBQAItem = new List<String>();
  static List<Color> displayColorBQAMC = [
    bottomNavigationColor,
    bottomNavigationColor,
    bottomNavigationColor,
    bottomNavigationColor
  ];
  static bool isBQAPressNext = true;
  static bool isBQAAnswered = false;
  static bool isBQAPlayAds = false;
  static int todayBQANextButtonStatus = 0; //0 = next, 1 = ads, 2 = end
  static int numBQAStartX = 5;
  static int numBQAX = 2;
  static int expBQAStart = 0;
  static int expBQAEnd = 0;
  static int totalTodayBQACorrectAnswerNum = 0;
  static int maxBQAAdsRewards = 9;
  static int todayBQAAdsRewards = 0;
  static bool todayBQACanAd = true;
  static int totalTodayBQAAnswerNumMax = 100;
  static String nextBQAButtonText = "";
  static String nowBQALevel = "upgrade";
  RewardedAd _rewardedAd;
  //int _numRewardedLoadAttempts = 0;
  // rewardedAd;

  @override
  void initState() {
    BackButtonInterceptor.add(myInterceptor);
    //rewardedAd = RewardedAd(unitId: rewardedVideoAdsId);
    //MobileAds.instance.initialize();
    _createRewardedAd();
    super.initState();
    /*.onEvent.listen((e) {
      final event = e.keys.first;
      switch (event) {
        case RewardedAdEvent.loading:
          //print('loading');
          break;
        case RewardedAdEvent.loaded:
          //print('loaded');
          break;
        case RewardedAdEvent.loadFailed:
          //final errorCode = e.values.first;
          //print('load failed $errorCode');
          break;
        case RewardedAdEvent.showed:
          if (Platform.isIOS) {
            setState(() {
            if (page == 1) {
                todayNextButtonStatus = 0;
                prefs.setInt(
                    sharePrefTodayNextButtonStatus, todayNextButtonStatus);
                isPlayAds = false;
                prefs.setBool(sharePrefTodayPlayAds, isPlayAds);
                reSetTheQuestion();
              } else if (page == 2) {
                todayBQANextButtonStatus = 0;
                prefs.setInt(
                    sharePrefTodayBQANextButtonStatus, todayBQANextButtonStatus);
                isBQAPlayAds = false;
                prefs.setBool(sharePrefTodayBQAPlayAds, isBQAPlayAds);
                reSetTheBQAQuestion();
              }
            });

          }
          //print('ad opened');
          break;
        case RewardedAdEvent.closed:
          //print('ad closed');
          break;
        case RewardedAdEvent.earnedReward:
          //final reward = e.values.first;
          //print('earned reward: $reward');
          setState(() {
            if (page == 1) {
              todayNextButtonStatus = 0;
              prefs.setInt(
                  sharePrefTodayNextButtonStatus, todayNextButtonStatus);
              isPlayAds = false;
              prefs.setBool(sharePrefTodayPlayAds, isPlayAds);
              reSetTheQuestion();
            } else if (page == 2) {
              todayBQANextButtonStatus = 0;
              prefs.setInt(
                  sharePrefTodayBQANextButtonStatus, todayBQANextButtonStatus);
              isBQAPlayAds = false;
              prefs.setBool(sharePrefTodayBQAPlayAds, isBQAPlayAds);
              reSetTheBQAQuestion();
            }
          });
          break;
        case RewardedAdEvent.showFailed:
          //final errorCode = e.values.first;
          //print('show failed $errorCode');
          break;
        default:
          break;
      }
    */
    init();
  }

  @override
  void dispose() {
    super.dispose();
    _rewardedAd?.dispose();
    BackButtonInterceptor.remove(myInterceptor);
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    //print("BACK BUTTON!"); // Do some stuff.
    if (page == 1 || page == 2 || page == 3) {
      setState(() {
        page = 0;
      });
    } else
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return true;
  }

  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: rewardedVideoAdsId,
        request: request,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            //print('$ad loaded.');
            _rewardedAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            //print('RewardedAd failed to load: $error');
            _rewardedAd = null;
          },
        ));
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {},
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        //print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        //print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd.setImmersiveMode(true);
    _rewardedAd.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      //print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
      setState(() {
        if (page == 1) {
          todayNextButtonStatus = 0;
          prefs.setInt(sharePrefTodayNextButtonStatus, todayNextButtonStatus);
          isPlayAds = false;
          prefs.setBool(sharePrefTodayPlayAds, isPlayAds);
          reSetTheQuestion();
        } else if (page == 2) {
          todayBQANextButtonStatus = 0;
          prefs.setInt(
              sharePrefTodayBQANextButtonStatus, todayBQANextButtonStatus);
          isBQAPlayAds = false;
          prefs.setBool(sharePrefTodayBQAPlayAds, isBQAPlayAds);
          reSetTheBQAQuestion();
        }
      });
    });
    _rewardedAd = null;
  }

  @override
  Widget build(BuildContext context) {
    Widget tempList;
    if (page == 0)
      tempList = _myListViewGame(context);
    else if (page == 1)
      tempList = _myListViewChapterMC(context);
    else if (page == 2)
      tempList = _myListViewBQAMC(context);
    else if (page == 3) tempList = _myListViewGameRules(context);
    return tempList;
  }

  Widget _myListViewGame(BuildContext context) {
    final europeanCountries = [
      FlutterI18n.translate(context, "gameMenuChapterMC"),
      FlutterI18n.translate(context, "gameMenuBQAMC"),
      FlutterI18n.translate(context, "gameMenuGameRules")
    ];
    return new Scaffold(
      appBar: AppBar(
        title: Text(
          FlutterI18n.translate(context, "bottomBarGame"),
          style: TextStyle(
            fontSize: ScreenUtil()
                .setSp(fontOfContent - 5, allowFontScalingSelf: true),
          ),
        ),
      ),
      body: new Center(
        child: ListView.separated(
          itemCount: europeanCountries.length,
          itemBuilder: (context, index) {
            return GestureDetector(
                child: ListTile(
                  title: Text(
                    europeanCountries[index],
                    style: TextStyle(
                      fontSize: ScreenUtil()
                          .setSp(fontOfContent, allowFontScalingSelf: true),
                    ),
                  ),
                ),
                onTap: () {
                  setState(() {
                    if (index == 0)
                      page = 1;
                    else if (index == 1)
                      page = 2;
                    else if (index == 2) page = 3;
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

  void shareToOther() {
    Share.share(copyShareReturnText());
  }

  String copyShareReturnText() {
    String tempText = FlutterI18n.translate(context, "shareAppText");

    return tempText;
  }

  void nextButtonFun() {
    if (todayNextButtonStatus == 0)
      nextButtonText = FlutterI18n.translate(context, "buttonNext");
    else if (todayNextButtonStatus == 1)
      nextButtonText = FlutterI18n.translate(context, "adsToQuestionButton");
    else if (todayNextButtonStatus == 2)
      nextButtonText = FlutterI18n.translate(context, "buttonOutToday");
  }

  Widget _myListViewBQAMC(BuildContext context) {
    // backing data
    //var europeanCountries = queryBibleTitleByDefault();
    nowBQALevel = FlutterI18n.translate(context, "displayCurrectLevel") +
        " " +
        prefs.getInt(sharePrefGameBQALevel).toString() +
        "\n" +
        FlutterI18n.translate(context, "nextLevelText") +
        " " +
        expBQAStart.toString() +
        "/" +
        expBQAEnd.toString();
    if (todayBQAAdsRewards < maxBQAAdsRewards)
      todayBQANextButtonStatus = isBQAPlayAds ? 1 : 0;
    prefs.setInt(sharePrefTodayBQANextButtonStatus, todayBQANextButtonStatus);
    nextBQAButtonFun();
    return new Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),
            ),
            onPressed: () => {
              setState(() {
                page = 0;
              })
            },
          ),
          title: Text(
            FlutterI18n.translate(context, "gameMenuBQAMC"),
            style: TextStyle(
              fontSize: ScreenUtil()
                  .setSp(fontOfContent - 5, allowFontScalingSelf: true),
            ),
          ),
        ),
        body: new Center(
          child: new Container(
            margin: new EdgeInsets.all(4.0),
            constraints: new BoxConstraints.expand(),
            child: ListView(
              children: <Widget>[
                new Column(
                  children: <Widget>[
                    //new Container(height: 5.0),
                    new Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 14.0),
                      //height: 100.0,
                      width: MediaQuery.of(context).size.width, //screen size
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(nowBQALevel,
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ScreenUtil().setSp(fontOfContent,
                                      allowFontScalingSelf: true))),
                          LinearProgressIndicator(
                            backgroundColor: Colors.cyanAccent,
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                Colors.green[300]),
                            value: (expBQAStart / expBQAEnd),
                          ),
                          /*Text(
                              FlutterI18n.translate(context, "todayScoreText") +
                                  totalTodayBQACorrectAnswerNum.toString() +
                                  '/' +
                                  totalTodayBQAAnswerNumMax.toString(),
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ScreenUtil().setSp(fontOfContent,
                                      allowFontScalingSelf: true))),*/
                        ],
                      ),
                    ),
                    //new Container(height: 5.0),
                    new Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 14.0),
                      //height: 100.0,
                      width: MediaQuery.of(context).size.width, //screen size

                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: gameBQALogicMC(context),
                      ),
                    ),
                    //new box style
                    new Container(height: 5.0),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  Widget _myListViewChapterMC(BuildContext context) {
    // backing data
    //var europeanCountries = queryBibleTitleByDefault();
    nowLevel = FlutterI18n.translate(context, "displayCurrectLevel") +
        " " +
        prefs.getInt(sharePrefGameLevel).toString() +
        "\n" +
        FlutterI18n.translate(context, "nextLevelText") +
        " " +
        expStart.toString() +
        "/" +
        expEnd.toString();
    if (todayAdsRewards < maxAdsRewards)
      todayNextButtonStatus = isPlayAds ? 1 : 0;
    prefs.setInt(sharePrefTodayNextButtonStatus, todayNextButtonStatus);
    nextButtonFun();
    return new Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),
            ),
            onPressed: () => {
              setState(() {
                page = 0;
              })
            },
          ),
          title: Text(
            FlutterI18n.translate(context, "gameMenuChapterMC"),
            style: TextStyle(
              fontSize: ScreenUtil()
                  .setSp(fontOfContent - 5, allowFontScalingSelf: true),
            ),
          ),
        ),
        body: new Center(
          child: new Container(
            margin: new EdgeInsets.all(4.0),
            constraints: new BoxConstraints.expand(),
            child: ListView(
              children: <Widget>[
                new Column(
                  children: <Widget>[
                    //new Container(height: 5.0),
                    new Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 14.0),
                      //height: 100.0,
                      width: MediaQuery.of(context).size.width, //screen size
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(nowLevel,
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ScreenUtil().setSp(fontOfContent,
                                      allowFontScalingSelf: true))),
                          LinearProgressIndicator(
                            backgroundColor: Colors.cyanAccent,
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                Colors.green[300]),
                            value: (expStart / expEnd),
                          ),
                          /*Text(
                              FlutterI18n.translate(context, "todayScoreText") +
                                  totalTodayCorrectAnswerNum.toString() +
                                  '/' +
                                  totalTodayAnswerNumMax.toString(),
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ScreenUtil().setSp(fontOfContent,
                                      allowFontScalingSelf: true))),*/
                        ],
                      ),
                    ),
                    //new Container(height: 5.0),
                    new Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 14.0),
                      //height: 100.0,
                      width: MediaQuery.of(context).size.width, //screen size

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
        ));
  }

  Widget _myListViewGameRules(BuildContext context) {
    // backing data
    var europeanCountries = [FlutterI18n.translate(context, "gameRulesText")];

    return new Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),
            ),
            onPressed: () => {
              setState(() {
                page = 0;
              })
            },
          ),
          title: Text(
            FlutterI18n.translate(context, "gameMenuGameRules"),
            style: TextStyle(
              fontSize: ScreenUtil()
                  .setSp(fontOfContent - 5, allowFontScalingSelf: true),
            ),
          ),
        ),
        body: new Center(
          child: ListView.separated(
            itemCount: europeanCountries.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                child: ListTile(
                  title: Text(
                    europeanCountries[index],
                    style: TextStyle(
                      fontSize: ScreenUtil()
                          .setSp(fontOfContent, allowFontScalingSelf: true),
                    ),
                  ),
                ),
              );
            }, //itemBuilder
            separatorBuilder: (context, index) {
              return Divider();
            }, //separatorBuilder
          ),
        ));
  }

  List<Widget> gameLogicMC(BuildContext context) {
    if (isPressNext) displayItem = gameLogicCode();

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
      new Text(
        displayItem[1],
        style: new TextStyle(
          fontSize: ScreenUtil().setSp(fontOfContent,
              allowFontScalingSelf: true), //color: fontTextColor
        ),
      ),
    );

    for (int i = 2; i < 6; i++) {
      tempList.add(
        RaisedButton(
          color: displayColorMC[i - 2],
          textColor: buttonTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          child: Text(
            displayItem[i],
            style: new TextStyle(
              fontSize: ScreenUtil().setSp(fontOfContent,
                  allowFontScalingSelf: true), //color: buttonTextColor
            ),
          ),
          onPressed: () {
            /*if(prefs!=null)
                        {
                            
                        }*/
            if (!isAnswered && !isPlayAds) {
              setState(() {
                todayNextButtonStatus = 0;
                prefs.setInt(
                    sharePrefTodayNextButtonStatus, todayNextButtonStatus);
                isAnswered = true;
                if (displayItem[6] == displayItem[i]) {
                  displayColorMC[i - 2] = correctAnswerColor;
                  int tempInt = prefs.getInt(sharePrefCorrectQuestionNum) + 1;
                  prefs.setInt(sharePrefCorrectQuestionNum, tempInt);
                  if (prefs.getInt(sharePrefCorrectQuestionNum) >= expEnd) {
                    prefs.setInt(sharePrefGameLevel,
                        prefs.getInt(sharePrefGameLevel) + 1);
                    prefs.setInt(sharePrefCorrectQuestionNum, 0);
                  }
                  totalTodayCorrectAnswerNum++;
                  prefs.setInt(sharePrefTodayCorrectAnswerNum,
                      totalTodayCorrectAnswerNum);
                } else {
                  displayColorMC[i - 2] = weekEndTextColor;
                  if (displayItem[6] == displayItem[2])
                    displayColorMC[0] = correctAnswerColor;
                  else if (displayItem[6] == displayItem[3])
                    displayColorMC[1] = correctAnswerColor;
                  else if (displayItem[6] == displayItem[4])
                    displayColorMC[2] = correctAnswerColor;
                  else if (displayItem[6] == displayItem[5])
                    displayColorMC[3] = correctAnswerColor;
                }

                int tempInt2 = prefs.getInt(sharePrefTotalAnsweredNum) + 1;
                prefs.setInt(sharePrefTotalAnsweredNum, tempInt2);
                if (tempInt2 % 10 == 0) {
                  if (todayAdsRewards >= maxAdsRewards) {
                    todayCanAd = false;
                    prefs.setBool(sharePrefTodayCanRewardAdsGameMC, todayCanAd);
                    todayNextButtonStatus = 2;
                  } else {
                    todayAdsRewards =
                        prefs.getInt(sharePrefTodayRewardAdsGameMC) + 1;
                    prefs.setInt(
                        sharePrefTodayRewardAdsGameMC, todayAdsRewards);
                    todayNextButtonStatus = 1;
                  }
                  prefs.setInt(
                      sharePrefTodayNextButtonStatus, todayNextButtonStatus);
                  isPlayAds = true;
                  prefs.setBool(sharePrefTodayPlayAds, isPlayAds);
                }

                setLevelExp();
              });
            }
          },
        ),
      );
      tempList.add(SizedBox(
        height: ScreenUtil().setSp(10, allowFontScalingSelf: true),
      ));
    }
    tempList.add(
      new Container(height: 5.0),
    );
    tempList.add(
      Visibility(
        visible: isAnswered || isPlayAds,
        child: RaisedButton(
          color: bottomNavigationColor,
          textColor: buttonTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          child: Text(
            nextButtonText,
            style: new TextStyle(
              fontSize: ScreenUtil().setSp(fontOfContent,
                  allowFontScalingSelf: true), //color: buttonTextColor
            ),
          ),
          onPressed: () async {
            if (isPlayAds && todayAdsRewards <= maxAdsRewards && todayCanAd) {
              //RewardedVideoAd.instance.show().catchError((e) => print("error in loading 1st time"));
              _showRewardedAd();
              // Load only if not loaded
              /*if (!rewardedAd.isLoaded) await rewardedAd.load();
              if (rewardedAd.isLoaded) rewardedAd.show();
              // Load the ad again after it's shown
              rewardedAd.load();*/
            } else if (!isPlayAds) {
              setState(() {
                reSetTheQuestion();
              });
            }
          },
        ),
      ),
    );

    return tempList;
  }

  void reSetTheQuestion() {
    todayNextButtonStatus = prefs.getInt(sharePrefTodayNextButtonStatus);
    todayAdsRewards = prefs.getInt(sharePrefTodayRewardAdsGameMC);
    todayCanAd = prefs.getBool(sharePrefTodayCanRewardAdsGameMC);
    isPlayAds = prefs.getBool(sharePrefTodayPlayAds);
    totalTodayCorrectAnswerNum = prefs.getInt(sharePrefTodayCorrectAnswerNum);

    if (todayAdsRewards == 0 && todayCanAd) {
      isPlayAds = false;
      prefs.setBool(sharePrefTodayPlayAds, isPlayAds);
    }

    isPressNext = true;
    isAnswered = false;
    displayColorMC = [
      bottomNavigationColor,
      bottomNavigationColor,
      bottomNavigationColor,
      bottomNavigationColor
    ];
  }

  void init() {
    /*
    RewardedVideoAd.instance.listener =
        (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      print("RewardedVideoAd event $event");
      if (event == RewardedVideoAdEvent.rewarded) {
        setState(() {
          if(page==1)
          {
              todayNextButtonStatus = 0;
              prefs.setInt(sharePrefTodayNextButtonStatus,todayNextButtonStatus);
              isPlayAds = false;
              prefs.setBool(sharePrefTodayPlayAds,isPlayAds);
              reSetTheQuestion();
          }
          else if(page==2)
          {
            todayBQANextButtonStatus = 0;
            prefs.setInt(sharePrefTodayBQANextButtonStatus,todayBQANextButtonStatus);
            isBQAPlayAds = false;
            prefs.setBool(sharePrefTodayBQAPlayAds,isBQAPlayAds);
            reSetTheBQAQuestion();
          }
          
          
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
                        */
    //each day picture testing code
    //prefs.setInt(sharePrefCorrectQuestionNum, 50);
    //prefs.setInt(sharePrefTotalAnsweredNum, 90);
    //prefs.setInt(sharePrefGameLevel, 5);
    //prefs.setInt(sharePrefTodayRewardAdsGameMC, 10);
    //prefs.setBool(sharePrefTodayPlayAds, false);
    //prefs.setInt(sharePrefTodayCorrectAnswerNum, 100);
    //prefs.setBool(sharePrefTodayPlayAds,true);
    //todayNextButtonStatus = 2;
    //prefs.setInt(sharePrefTodayNextButtonStatus,todayNextButtonStatus);

    reSetTheQuestion();
    reSetTheBQAQuestion();
    setLevelExp();
    setBQALevelExp();
  }

  void setLevelExp() {
    expEnd = numStartX;
    int tempEnd = prefs.getInt(sharePrefGameLevel);
    for (int i = 0; i < tempEnd; i++) {
      expEnd *= numX;
    }

    expStart = prefs.getInt(sharePrefCorrectQuestionNum);
  }

  List<String> gameLogicCode() {
    String questionNo = FlutterI18n.translate(context, "questionText") + " 1";
    int titleIdMC = new Random().nextInt(bibleTitleTotalNum.length - 1);
    int titleNumMC = new Random().nextInt(bibleTitleTotalNum[titleIdMC]);
    //titleIdMC=63;
    //titleNumMC=0;
    List<String> tempBibleList = queryBibleContentByTitle(
        (titleIdMC + 1).toString(), (titleNumMC + 1).toString());
    int titleNumCharNumMC = new Random().nextInt(tempBibleList.length - 1);
    //titleNumCharNumMC = 14;

    String theQuestion = "";
    int titleIdMCWrong1 = 0;
    int titleNumMCCWrong1 = 0;
    int titleIdMCWrong2 = 0;
    int titleNumMCCWrong2 = 0;
    int titleIdMCWrong3 = 0;
    int titleNumMCCWrong3 = 0;

    do {
      titleIdMCWrong1 = new Random().nextInt(bibleTitleTotalNum.length - 1);
    } while (titleIdMCWrong1 == titleIdMC);
    titleNumMCCWrong1 =
        new Random().nextInt(bibleTitleTotalNum[titleIdMCWrong1]);

    do {
      titleIdMCWrong2 = new Random().nextInt(bibleTitleTotalNum.length - 1);
    } while (
        titleIdMCWrong2 == titleIdMC || titleIdMCWrong2 == titleIdMCWrong1);
    titleNumMCCWrong2 =
        new Random().nextInt(bibleTitleTotalNum[titleIdMCWrong2]);

    do {
      titleIdMCWrong3 = new Random().nextInt(bibleTitleTotalNum.length - 1);
    } while (titleIdMCWrong3 == titleIdMC ||
        titleIdMCWrong3 == titleIdMCWrong1 ||
        titleIdMCWrong3 == titleIdMCWrong2);
    titleNumMCCWrong3 =
        new Random().nextInt(bibleTitleTotalNum[titleIdMCWrong3]);

    titleIdMC += 1;
    titleNumMC += 1;
    titleIdMCWrong1 += 1;
    titleNumMCCWrong1 += 1;
    titleIdMCWrong2 += 1;
    titleNumMCCWrong2 += 1;
    titleIdMCWrong3 += 1;
    titleNumMCCWrong3 += 1;

    do {
      titleNumCharNumMC = new Random().nextInt(tempBibleList.length - 1);
      //titleNumCharNumMC = 14;
      theQuestion = tempBibleList[titleNumCharNumMC]
          .substring(tempBibleList[titleNumCharNumMC].indexOf('.') + 1);
    } while (theQuestion == "" ||
        theQuestion == "見上節" ||
        theQuestion == "见上节"); //bug checking

    theQuestion = /*FlutterI18n.translate(context, "bibleTitle.$titleIdMC.title")+" "+titleNumMC.toString() + " " +*/ tempBibleList[
        titleNumCharNumMC];

    List<String> tempAnswer = [
      FlutterI18n.translate(context, "bibleTitle.$titleIdMC.title") +
          " " +
          titleNumMC.toString(),
      FlutterI18n.translate(context, "bibleTitle.$titleIdMCWrong1.title") +
          " " +
          titleNumMCCWrong1.toString(),
      FlutterI18n.translate(context, "bibleTitle.$titleIdMCWrong2.title") +
          " " +
          titleNumMCCWrong2.toString(),
      FlutterI18n.translate(context, "bibleTitle.$titleIdMCWrong3.title") +
          " " +
          titleNumMCCWrong3.toString()
    ];
    tempAnswer.shuffle();

    List<String> temp = new List<String>();
    String correctAnswer =
        FlutterI18n.translate(context, "bibleTitle.$titleIdMC.title") +
            " " +
            titleNumMC.toString();
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
    String temp =
        FlutterI18n.translate(context, "bible.$titleId.$titleNum.content");
    List<String> tmepBibleList = unescape.convert(temp).split("=.=");

    return tmepBibleList;
  }

  Future<List<String>> getBibleBookmarkByTitleId(int titleId) async {
    List<BibleBookmark> temp =
        await dbHelper.getBibleBookmarkByTitleId(titleId);
    List<String> tmepList = new List<String>();
    if (temp.length != 0) {
      for (BibleBookmark tempBookmark in temp) {
        String temp = titleId.toString() +
            ":" +
            tempBookmark.content.toString() +
            ":" +
            tempBookmark.text.toString();
        List<String> tempTitleList = temp.split(':');
        List<String> tempContentList = tempTitleList[2].split('-');
        String tempDisplayContent = FlutterI18n.translate(
                context, "bibleTitle." + tempTitleList[0] + ".title") +
            " " +
            tempTitleList[1] +
            ":";
        if (tempContentList.length > 1)
          tempDisplayContent += tempContentList[0] +
              "-" +
              tempContentList[tempContentList.length - 1] +
              "";
        else
          tempDisplayContent += tempContentList[0];
        tempDisplayContent += "+";
        for (int i = 0; i < tempContentList.length; i++) {
          String temp1 = FlutterI18n.translate(
                  context,
                  "bible." +
                      tempTitleList[0] +
                      "." +
                      tempTitleList[1] +
                      ".content")
              .split('=.=')[int.parse(tempContentList[i]) - 1];
          tempDisplayContent += temp1.substring(temp1.indexOf('.') + 1).trim();
        }
        tmepList.add(unescape.convert(tempDisplayContent));
        //tmepList.add(titleId.toString() + ":"+ tempBookmark.content.toString()+":"+tempBookmark.text.toString());
      }
    }
    //else
    //  tmepList.add('No');

    return tmepList;
  }

  List<String> gameBQALogicCode() {
    int selectedBQANumMC = new Random().nextInt(176) + 1;
    //titleNumCharNumMC = 14;

    String theQuestion = "";
    String correctAnswer = "";

    List<String> tempStringList =
        FlutterI18n.translate(context, "BQA.$selectedBQANumMC").split("=.=");
    theQuestion = tempStringList[0];
    correctAnswer = tempStringList[1];
    List<String> tempAnswer = [
      tempStringList[1],
      tempStringList[2],
      tempStringList[3],
      tempStringList[4]
    ];
    tempAnswer.shuffle();

    List<String> temp = new List<String>();

    temp.add(theQuestion);
    temp.add(tempAnswer[0]);
    temp.add(tempAnswer[1]);
    temp.add(tempAnswer[2]);
    temp.add(tempAnswer[3]);
    temp.add(correctAnswer);
    isBQAPressNext = false;
    return temp;
  }

  List<Widget> gameBQALogicMC(BuildContext context) {
    if (isBQAPressNext) displayBQAItem = gameBQALogicCode();

    List<Widget> tempList = new List<Widget>();

    tempList.add(
      new Text(
        displayBQAItem[0],
        style: new TextStyle(
          fontSize: ScreenUtil().setSp(fontOfContent,
              allowFontScalingSelf: true), //color: fontTextColor
        ),
      ),
    );

    for (int i = 1; i < 5; i++) {
      tempList.add(
        RaisedButton(
          color: displayColorBQAMC[i - 1],
          textColor: buttonTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          child: Text(
            displayBQAItem[i],
            style: new TextStyle(
              fontSize: ScreenUtil().setSp(fontOfContent,
                  allowFontScalingSelf: true), //color: buttonTextColor
            ),
          ),
          onPressed: () {
            /*if(prefs!=null)
                            {
                                
                            }*/
            if (!isBQAAnswered && !isBQAPlayAds) {
              setState(() {
                todayBQANextButtonStatus = 0;
                prefs.setInt(sharePrefTodayBQANextButtonStatus,
                    todayBQANextButtonStatus);
                isBQAAnswered = true;
                if (displayBQAItem[5] == displayBQAItem[i]) {
                  displayColorBQAMC[i - 1] = correctAnswerColor;
                  int tempInt =
                      prefs.getInt(sharePrefCorrectBQAQuestionNum) + 1;
                  prefs.setInt(sharePrefCorrectBQAQuestionNum, tempInt);
                  if (prefs.getInt(sharePrefCorrectBQAQuestionNum) >=
                      expBQAEnd) {
                    prefs.setInt(sharePrefGameBQALevel,
                        prefs.getInt(sharePrefGameBQALevel) + 1);
                    prefs.setInt(sharePrefCorrectBQAQuestionNum, 0);
                  }
                  totalTodayBQACorrectAnswerNum++;
                  prefs.setInt(sharePrefTodayBQACorrectAnswerNum,
                      totalTodayBQACorrectAnswerNum);
                } else {
                  displayColorBQAMC[i - 1] = weekEndTextColor;
                  if (displayBQAItem[5] == displayBQAItem[1])
                    displayColorBQAMC[0] = correctAnswerColor;
                  else if (displayBQAItem[5] == displayBQAItem[2])
                    displayColorBQAMC[1] = correctAnswerColor;
                  else if (displayBQAItem[5] == displayBQAItem[3])
                    displayColorBQAMC[2] = correctAnswerColor;
                  else if (displayBQAItem[5] == displayBQAItem[4])
                    displayColorBQAMC[3] = correctAnswerColor;
                }

                int tempInt2 = prefs.getInt(sharePrefTotalBQAAnsweredNum) + 1;
                prefs.setInt(sharePrefTotalBQAAnsweredNum, tempInt2);
                if (tempInt2 % 10 == 0) {
                  if (todayBQAAdsRewards >= maxBQAAdsRewards) {
                    todayBQACanAd = false;
                    prefs.setBool(
                        sharePrefTodayBQACanRewardAdsGameMC, todayBQACanAd);
                    todayBQANextButtonStatus = 2;
                  } else {
                    todayBQAAdsRewards =
                        prefs.getInt(sharePrefTodayBQARewardAdsGameMC) + 1;
                    prefs.setInt(
                        sharePrefTodayBQARewardAdsGameMC, todayBQAAdsRewards);
                    todayBQANextButtonStatus = 1;
                  }
                  prefs.setInt(sharePrefTodayBQANextButtonStatus,
                      todayBQANextButtonStatus);
                  isBQAPlayAds = true;
                  prefs.setBool(sharePrefTodayBQAPlayAds, isBQAPlayAds);
                }

                setBQALevelExp();
              });
            }
          },
        ),
      );
      tempList.add(SizedBox(
        height: ScreenUtil().setSp(10, allowFontScalingSelf: true),
      ));
    }
    tempList.add(
      new Container(height: 5.0),
    );
    tempList.add(
      Visibility(
        visible: isBQAAnswered || isBQAPlayAds,
        child: RaisedButton(
          color: bottomNavigationColor,
          textColor: buttonTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          child: Text(
            nextBQAButtonText,
            style: new TextStyle(
              fontSize: ScreenUtil().setSp(fontOfContent,
                  allowFontScalingSelf: true), //color: buttonTextColor
            ),
          ),
          onPressed: () async {
            if (isBQAPlayAds &&
                todayBQAAdsRewards <= maxBQAAdsRewards &&
                todayBQACanAd) {
              /*RewardedVideoAd.instance
                    .show()
                    .catchError((e) => print("error in loading 1st time"));*/
              _showRewardedAd();
              // Load only if not loaded
              /* (!rewardedAd.isLoaded) await rewardedAd.load();
              if (rewardedAd.isLoaded) rewardedAd.show();
              // Load the ad again after it's shown
              rewardedAd.load();*/
            } else if (!isBQAPlayAds) {
              setState(() {
                reSetTheBQAQuestion();
              });
            }
          },
        ),
      ),
    );

    return tempList;
  }

  void setBQALevelExp() {
    expBQAEnd = numBQAStartX;
    int tempEnd = prefs.getInt(sharePrefGameBQALevel);
    for (int i = 0; i < tempEnd; i++) {
      expBQAEnd *= numBQAX;
    }

    expBQAStart = prefs.getInt(sharePrefCorrectBQAQuestionNum);
  }

  void reSetTheBQAQuestion() {
    todayBQANextButtonStatus = prefs.getInt(sharePrefTodayBQANextButtonStatus);
    todayBQAAdsRewards = prefs.getInt(sharePrefTodayBQARewardAdsGameMC);
    todayBQACanAd = prefs.getBool(sharePrefTodayBQACanRewardAdsGameMC);
    isBQAPlayAds = prefs.getBool(sharePrefTodayBQAPlayAds);
    totalTodayBQACorrectAnswerNum =
        prefs.getInt(sharePrefTodayBQACorrectAnswerNum);

    if (todayBQAAdsRewards == 0 && todayBQACanAd) {
      isBQAPlayAds = false;
      prefs.setBool(sharePrefTodayBQAPlayAds, isBQAPlayAds);
    }

    isBQAPressNext = true;
    isBQAAnswered = false;
    displayColorBQAMC = [
      bottomNavigationColor,
      bottomNavigationColor,
      bottomNavigationColor,
      bottomNavigationColor
    ];
  }

  void nextBQAButtonFun() {
    if (todayBQANextButtonStatus == 0)
      nextBQAButtonText = FlutterI18n.translate(context, "buttonNext");
    else if (todayBQANextButtonStatus == 1)
      nextBQAButtonText = FlutterI18n.translate(context, "adsToQuestionButton");
    else if (todayBQANextButtonStatus == 2)
      nextBQAButtonText = FlutterI18n.translate(context, "buttonOutToday");
  }
}
