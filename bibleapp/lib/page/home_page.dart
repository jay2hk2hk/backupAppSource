import 'dart:io';

import 'package:bibleapp/model/bible_notes.dart';
//import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:bibleapp/page/bible_app.dart';
import 'package:bibleapp/page/settings_page.dart';
import 'package:bibleapp/page/main_page.dart';
import 'package:bibleapp/page/search_page.dart';
import 'package:bibleapp/page/notes_page.dart';
import 'package:bibleapp/util/common_value.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';

import '../main.dart';
import 'game_page.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
//import 'package:native_admob_flutter/native_admob_flutter.dart';

Locale currentLang;

GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
GlobalKey globalKey = new GlobalKey(debugLabel: 'btm_app_bar');

DateTime eventNoteTitle = DateTime.parse(dateFormat.format(DateTime.now()));

void main() async {}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _bottomNavigationColor = bottomNavigationColor;
  int _currentIndex = 0;
  List<Widget> list = List();
  final dateFormat = new DateFormat('yyyy-MM-dd');
  double fontOfContent = 40.0;
  //String bannerAdsId = BannerAd.testAdUnitId;
  //String firebaseAdId = FirebaseAdMob.testAppId;
  String bannerAdsId = Platform.isAndroid
      ? "ca-app-pub-9860072337130869/5088892533"
      : "ca-app-pub-9860072337130869/8724092620";
  String firebaseAdId = Platform.isAndroid
      ? "ca-app-pub-9860072337130869~8212800236"
      : "ca-app-pub-9860072337130869~3480731194";
  // TODO: Add a BannerAd instance
  BannerAd _ad;

  // TODO: Add _isAdLoaded
  bool _isAdLoaded = false;
  //BannerAd _anchoredBanner;
  //bool _loadingAnchoredBanner = false;
  /*static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );*/
  // bannerController = BannerAdController();

  /*static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    //testDevices: testDevice != null ? <String>[testDevice] : null,
    //keywords: <String>['foo', 'bar'],
    //contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
    testDevices: <String>[],
  );
  BannerAd _bannerAd;
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdsId,
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }*/

  @override
  void dispose() {
    //为了避免内存泄露，需要调用.dispose
    super.dispose();
    //_bannerAd?.dispose();
    // TODO: Dispose a BannerAd object
    _ad.dispose();

    //_anchoredBanner?.dispose();
    //bannerController.dispose();
  }

  @override
  void initState() {
    //FirebaseAdMob.instance.initialize(appId: firebaseAdId);
    //_bannerAd = createBannerAd()..load();
    //MobileAds.instance.initialize();
    // TODO: Create a BannerAd instance
    _ad = BannerAd(
      adUnitId: bannerAdsId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();

          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    );

    // TODO: Load an ad
    _ad.load();

    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();

      await _setPref();
      //currentLang = Locale('en','US');
      //prefs.setString(sharePrefDisplayLanguage, languageTextValue[0]);
      /*int tempBannerPosition = 160;
      if (Platform.isAndroid) {
        if (ScreenUtil.screenHeight <= 480) tempBannerPosition = 195;
      } else {
        if (ScreenUtil.screenHeight <= 480)
          tempBannerPosition = 185;
        else if (ScreenUtil.screenHeight <= 960)
          tempBannerPosition = 290;
        else if (ScreenUtil.screenHeight <= 1136)
          tempBannerPosition = 210;
        else if (ScreenUtil.screenHeight <= 1334)
          tempBannerPosition = 210;
        else if (ScreenUtil.screenHeight <= 1776)
          tempBannerPosition = 200;
        else if (ScreenUtil.screenHeight <= 2488)
          tempBannerPosition = 160;
        else if (ScreenUtil.screenHeight <= 2688)
          tempBannerPosition = 140;
        else if (ScreenUtil.screenHeight < 2788) tempBannerPosition = 120;
      }*/

      /*_bannerAd ??= createBannerAd();
      _bannerAd
        ..load()
        ..show(
            anchorOffset: ScreenUtil().setHeight(tempBannerPosition),
            anchorType: AnchorType.bottom);*/
    });

    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();

      var now = DateTime.parse(dateFormat.format(DateTime.now()));

      //print(now.difference(now.subtract(Duration(hours: 5))).inDays);
      //game mc
      if (prefs.getInt(sharePrefCorrectQuestionNum) == null) {
        prefs.setInt(sharePrefCorrectQuestionNum, 0);

        prefs.setInt(sharePrefGameLevel, 1);
      }
      //bqa
      if (prefs.getInt(sharePrefCorrectBQAQuestionNum) == null) {
        prefs.setInt(sharePrefCorrectBQAQuestionNum, 0);

        prefs.setInt(sharePrefGameBQALevel, 1);
      }

      DateTime tempTime = now;
      if (prefs.getString(sharePrefBibleTodaysDate) == null) {
        prefs.setString(sharePrefBibleTodaysDate, now.toString());
        prefs.setBool(sharePrefBibleTodaysGotCrownLoadedReward, false);
      }

      if (prefs.getInt(sharePrefReadBibleLevel) == null) {
        prefs.setInt(sharePrefReadBibleLevel, 0);
      }

      if (prefs.getString(sharePrefBibleTodaysString) == null) {
        prefs.setString(sharePrefBibleTodaysString,
            saveAllBibleTodaysSentence[now.month - 1][now.day - 1]);
      } else {
        //print(DateTime.parse(prefs.getString(sharePrefBibleTodaysDate)).difference(DateTime.now()).inDays);
        if (DateTime.parse(prefs.getString(sharePrefBibleTodaysDate))
                .difference(now)
                .inDays <
            0) {
          if (prefs.getInt(sharePrefReadBibleLevel) >= 3) {
            prefs.setString(sharePrefBibleTodaysString,
                saveAllBibleTodaysSentenceOneYearC[now.month - 1][now.day - 1]);
          } else if (prefs.getInt(sharePrefReadBibleLevel) >= 2) {
            prefs.setString(sharePrefBibleTodaysString,
                saveAllBibleTodaysSentenceHalf[now.month - 1][now.day - 1]);
          } else {
            prefs.setString(sharePrefBibleTodaysString,
                saveAllBibleTodaysSentence[now.month - 1][now.day - 1]);
            if (prefs.getInt(sharePrefReadBibleLevel) > 0) {
              String tempString = "20:";
              if (prefs
                  .getString(sharePrefBibleTodaysString)
                  .contains(tempString)) tempString = "19:";
              prefs.setString(
                  sharePrefBibleTodaysString,
                  prefs.getString(sharePrefBibleTodaysString) +
                      "," +
                      tempString +
                      now.day.toString());
            }
          }
        }
      }

      if (prefs.getString(sharePrefBibleTodaysReadString) == null) {
        prefs.setString(sharePrefBibleTodaysReadString,
            saveAllBibleTodaysSentence[now.month - 1][now.day - 1]);
      } else {
        //print(DateTime.parse(prefs.getString(sharePrefBibleTodaysDate)).difference(DateTime.now()).inDays);
        if (DateTime.parse(prefs.getString(sharePrefBibleTodaysDate))
                .difference(now)
                .inDays <
            0) {
          if (prefs.getInt(sharePrefReadBibleLevel) >= 3) {
            prefs.setString(sharePrefBibleTodaysReadString,
                saveAllBibleTodaysSentenceOneYearC[now.month - 1][now.day - 1]);
          } else if (prefs.getInt(sharePrefReadBibleLevel) >= 2) {
            prefs.setString(sharePrefBibleTodaysReadString,
                saveAllBibleTodaysSentenceHalf[now.month - 1][now.day - 1]);
          } else {
            prefs.setString(sharePrefBibleTodaysReadString,
                saveAllBibleTodaysSentence[now.month - 1][now.day - 1]);
            if (prefs.getInt(sharePrefReadBibleLevel) > 0) {
              String tempString = "20:";
              if (prefs
                  .getString(sharePrefBibleTodaysReadString)
                  .contains(tempString)) tempString = "19:";
              prefs.setString(
                  sharePrefBibleTodaysReadString,
                  prefs.getString(sharePrefBibleTodaysReadString) +
                      "," +
                      tempString +
                      now.day.toString());
            }
          }
        }
      }

      if (prefs.getString(sharePrefBibleTodaysDate) != null) {
        tempTime = DateTime.parse(prefs.getString(sharePrefBibleTodaysDate));
        if (tempTime.isBefore(now)) {
          prefs.setString(sharePrefBibleTodaysDate, now.toString());
          prefs.setBool(sharePrefBibleTodaysGotCrownLoadedReward, false);
        }
      }

      if (prefs.getBool(sharePrefBibleTodaysGotCrown) == null) {
        prefs.setBool(sharePrefBibleTodaysGotCrown, false);
      } else {
        if (tempTime.isBefore(now)) {
          prefs.setBool(sharePrefBibleTodaysGotCrown, false);
        }
      }

      //game MC
      if (prefs.getInt(sharePrefTodayRewardAdsGameMC) == null) {
        prefs.setInt(sharePrefTodayRewardAdsGameMC, 0);
        prefs.setBool(sharePrefTodayCanRewardAdsGameMC, true);
        prefs.setInt(sharePrefTotalAnsweredNum, 0);
        prefs.setInt(sharePrefTodayNextButtonStatus, 0);
        prefs.setBool(sharePrefTodayPlayAds, false);
        prefs.setInt(sharePrefTodayCorrectAnswerNum, 0);
      } else {
        if (tempTime.isBefore(now)) {
          prefs.setInt(sharePrefTodayRewardAdsGameMC, 0);
          prefs.setBool(sharePrefTodayCanRewardAdsGameMC, true);
          prefs.setInt(sharePrefTotalAnsweredNum, 0);
          prefs.setInt(sharePrefTodayNextButtonStatus, 0);
          prefs.setBool(sharePrefTodayPlayAds, false);
          prefs.setInt(sharePrefTodayCorrectAnswerNum, 0);
        }
      }

      //BQA
      if (prefs.getInt(sharePrefTodayBQARewardAdsGameMC) == null) {
        prefs.setInt(sharePrefTodayBQARewardAdsGameMC, 0);
        prefs.setBool(sharePrefTodayBQACanRewardAdsGameMC, true);
        prefs.setInt(sharePrefTotalBQAAnsweredNum, 0);
        prefs.setInt(sharePrefTodayBQANextButtonStatus, 0);
        prefs.setBool(sharePrefTodayBQAPlayAds, false);
        prefs.setInt(sharePrefTodayBQACorrectAnswerNum, 0);
      } else {
        if (tempTime.isBefore(now)) {
          prefs.setInt(sharePrefTodayBQARewardAdsGameMC, 0);
          prefs.setBool(sharePrefTodayBQACanRewardAdsGameMC, true);
          prefs.setInt(sharePrefTotalBQAAnsweredNum, 0);
          prefs.setInt(sharePrefTodayBQANextButtonStatus, 0);
          prefs.setBool(sharePrefTodayBQAPlayAds, false);
          prefs.setInt(sharePrefTodayBQACorrectAnswerNum, 0);
        }
      }

      if (prefs.getInt(sharePrefBibleTodaysGotCrownTotal) == null) {
        prefs.setInt(sharePrefBibleTodaysGotCrownTotal, 0);
      }

      if (prefs.getString(sharePrefDisplayLanguage) == null) {
        String lc = Platform.localeName;
        if (Platform.isAndroid) {
          if (lc.contains('TW')) {
            currentLang = Locale('zh', 'TW');
            prefs.setString(sharePrefDisplayLanguage, languageTextValue[2]);
          } else if (lc.contains('HK')) {
            currentLang = Locale('zh', 'HK');
            prefs.setString(sharePrefDisplayLanguage, languageTextValue[1]);
          } else if (lc.contains('CN')) {
            currentLang = Locale('zh', 'CN');
            prefs.setString(sharePrefDisplayLanguage, languageTextValue[3]);
          } else {
            currentLang = Locale('en', 'US');
            prefs.setString(sharePrefDisplayLanguage, languageTextValue[0]);
          }
        } else {
          if (lc.contains('Hant_HK')) {
            currentLang = Locale('zh', 'HK');
            prefs.setString(sharePrefDisplayLanguage, languageTextValue[1]);
          } else if (lc.contains('Hant')) {
            currentLang = Locale('zh', 'TW');
            prefs.setString(sharePrefDisplayLanguage, languageTextValue[2]);
          } else if (lc.contains('Hans')) {
            currentLang = Locale('zh', 'CN');
            prefs.setString(sharePrefDisplayLanguage, languageTextValue[3]);
          } else {
            currentLang = Locale('en', 'US');
            prefs.setString(sharePrefDisplayLanguage, languageTextValue[0]);
          }
        }

        /*currentLang = Localizations.localeOf(context);
        if(!currentLang.languageCode.contains('en_US') && !currentLang.languageCode.contains('zh'))
          currentLang = Locale('en','US');
        prefs.setString(sharePrefDisplayLanguage, languageTextValue[0]); */
      } else {
        List<String> tempLang =
            prefs.getString(sharePrefDisplayLanguage).split('-');
        currentLang = Locale(tempLang[0], tempLang[1]);
        //prefs.setString(sharePrefDisplayLanguage, languageTextValue[0]);
      }

      if (prefs.getString(sharePrefSoundLanguage) == null) {
        String lc = Platform.localeName;
        if (Platform.isAndroid) {
          if (lc.contains('TW')) {
            prefs.setString(sharePrefSoundLanguage, languageVolumeValue[2]);
          } else if (lc.contains('HK')) {
            prefs.setString(sharePrefSoundLanguage, languageVolumeValue[1]);
          } else if (lc.contains('CN')) {
            prefs.setString(sharePrefSoundLanguage, languageVolumeValue[3]);
          } else {
            prefs.setString(sharePrefSoundLanguage, languageVolumeValue[0]);
          }
        } else {
          if (lc.contains('Hant_HK')) {
            prefs.setString(sharePrefSoundLanguage, languageVolumeValue[1]);
          } else if (lc.contains('Hant')) {
            prefs.setString(sharePrefSoundLanguage, languageVolumeValue[2]);
          } else if (lc.contains('Hans')) {
            prefs.setString(sharePrefSoundLanguage, languageVolumeValue[3]);
          } else {
            prefs.setString(sharePrefSoundLanguage, languageVolumeValue[0]);
          }
        }

        /*Locale tempLocale = Localizations.localeOf(context);
        if(!tempLocale.languageCode.contains('en') && !tempLocale.languageCode.contains('zh'))
          prefs.setString(sharePrefSoundLanguage, languageVolumeValue[0]); 
        else
        {
          String temp = tempLocale.languageCode+'-'+tempLocale.countryCode;
          if(languageTextValue[1]==temp)
            prefs.setString(sharePrefSoundLanguage, languageVolumeValue[1]); 
          else prefs.setString(sharePrefSoundLanguage, temp); 
        } */
      }

      if (prefs.getInt(sharePrefLightDark) == null) {
        prefs.setInt(sharePrefLightDark, 0);
      }

      if (prefs.getInt(sharePrefUpdateVersionNum) == null) {
        prefs.setInt(sharePrefUpdateVersionNum, 0);
      }

      await FlutterI18n.refresh(context, currentLang);
      setState(() {
        currentLang = FlutterI18n.currentLocale(context);
      });
    }).whenComplete(() => {
          list
            ..add(MainPage(globalKey))
            ..add(BibleApp(_scaffoldKey))
            ..add(GamePage(globalKey))
            ..add(SearchPage(globalKey))
            ..add(NotesPage(globalKey))
            ..add(SettingsPage(globalKey))
        });
    setInitEventInCal();
    super.initState();
    /*bannerController.onEvent.listen((e) {
      final event = e.keys.first;
      // final info = e.values.first;
      switch (event) {
        case BannerAdEvent.loaded:
          // setState(() => _bannerAdHeight = (info as int)?.toDouble());
          break;
        default:
          break;
      }
    });
    bannerController.load();*/
    //not sleep mode
    Wakelock.enable();
  }

  _setPref() async {
    if (prefs != null) {
      if (prefs.getString(sharePrefTitleId) == null) {
        await prefs.setString(sharePrefTitleId, "1");
      }

      if (prefs.getString(sharePrefTitleNum) == null) {
        await prefs.setString(sharePrefTitleNum, "1");
      }

      if (prefs.getDouble(sharePrefFontSize) == null) {
        await prefs.setDouble(sharePrefFontSize, 60.0);
      }

      /*if(prefs.getDouble(sharePrefSpeechRate) == null)
        {
          await prefs.setDouble(sharePrefSpeechRate, 0.5);
        } */

      if (prefs.getString(sharePrefContentNum) == null) {
        await prefs.setString(sharePrefContentNum, "1");
      }

      /*if(prefs.getString(sharePrefSoundLanguage) == null)
        {
          await prefs.setString(sharePrefSoundLanguage, "en-US");
        }*/

      /*if(prefs.getString(sharePrefDisplayLanguage) == null)
        {
          await prefs.setString(sharePrefDisplayLanguage, languageTextValue[0]);
        }*/
    }
  }

  /*Future<void> _createAnchoredBanner(BuildContext context) async {
    /*final AnchoredAdaptiveBannerAdSize size = ;
    await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      MediaQuery.of(context).size.width.truncate(),
    );*/
    final AdSize size = AdSize.banner;

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    final BannerAd banner = BannerAd(
      size: size,
      request: request,
      adUnitId: bannerAdsId,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$BannerAd loaded.');
          setState(() {
            _anchoredBanner = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$BannerAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
      ),
    );
    return banner.load();
  }*/

  void setInitEventInCal() async {
    var now = eventNoteTitle;
    var firstDayDateTime = new DateTime(now.year, now.month, 1);
    // Find the last day of the month.
    var lastDayDateTime = (now.month < 12)
        ? new DateTime(now.year, now.month + 1, 0)
        : new DateTime(now.year + 1, 1, 0);
    Map<DateTime, List> tempEvents = {};
    List<BibleNotes> tempList =
        await dbHelper.getBibleNotesByMonth(firstDayDateTime, lastDayDateTime);
    events = {};
    for (BibleNotes tempNote in tempList) {
      if (tempEvents[DateTime.parse(
              dateFormat.format(DateTime.parse(tempNote.date)))] !=
          null)
        tempEvents[DateTime.parse(
                dateFormat.format(DateTime.parse(tempNote.date)))]
            .add([
          tempNote.id,
          tempNote.title,
          tempNote.content,
          DateTime.parse(dateFormat.format(DateTime.parse(tempNote.date)))
        ]);
      else
        tempEvents[DateTime.parse(
            dateFormat.format(DateTime.parse(tempNote.date)))] = [
          [
            tempNote.id,
            tempNote.title,
            tempNote.content,
            DateTime.parse(dateFormat.format(DateTime.parse(tempNote.date)))
          ]
        ];
    }
    events = tempEvents;
  }

  @override
  Widget build(BuildContext context) {
    //设置适配尺寸 (填入设计稿中设备的屏幕尺寸) 此处假如设计稿是按iPhone6的尺寸设计的(iPhone6 750*1334)
    //ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    ScreenUtil.init(context /*, allowFontScaling: true*/);
    //RestartWidget.restartApp(context);
    /*if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }*/

    return
        //Column(
        //children: <Widget>[
        //Expanded(
        //flex: 9,
        //child:
        /*MaterialApp
          (
            home:*/
        Theme(
            data: prefs == null || prefs.getInt(sharePrefLightDark) == 0
                ? ThemeData.light()
                : ThemeData.dark(),
            child: Scaffold(
              body: //Container(
                  //child:
                  //list.length>0? list[_currentIndex] : Text(''),
                  //),

                  Column(
                children: <Widget>[
                  Expanded(
                    flex: 9,
                    child: list.length > 0 ? list[_currentIndex] : Text(''),
                  ),
                  Expanded(
                    flex: 0,
                    child: Container(
                      child: AdWidget(ad: _ad),
                      width: _ad.size.width.toDouble(),
                      height: _ad.size.height.toDouble(),
                      alignment: Alignment.center,
                    ),
                  ),
                ],
              ),

              bottomNavigationBar: list.length > 0
                  ?
                  //Theme(
                  //data:prefs.getInt(sharePrefLightDark) ==0 ? ThemeData.light(): ThemeData.dark(),
                  //child:
                  BottomNavigationBar(
                      selectedItemColor: _bottomNavigationColor,
                      selectedFontSize: ScreenUtil()
                          .setSp(fontOfContent, allowFontScalingSelf: true),
                      key: globalKey,
                      items: [
                        BottomNavigationBarItem(
                          icon: FaIcon(
                            FontAwesomeIcons.home,
                            color: _bottomNavigationColor,
                            size: ScreenUtil().setSp(fontOfContent,
                                allowFontScalingSelf: true),
                          ),
                          label:
                              FlutterI18n.translate(context, "bottomBarHome"),
                        ),
                        BottomNavigationBarItem(
                          icon: FaIcon(
                            FontAwesomeIcons.bible,
                            color: _bottomNavigationColor,
                            size: ScreenUtil().setSp(fontOfContent,
                                allowFontScalingSelf: true),
                          ),
                          label:
                              FlutterI18n.translate(context, "bottomBarBible"),
                        ),
                        BottomNavigationBarItem(
                          icon: FaIcon(
                            FontAwesomeIcons.gamepad,
                            color: _bottomNavigationColor,
                            size: ScreenUtil().setSp(fontOfContent,
                                allowFontScalingSelf: true),
                          ),
                          label:
                              FlutterI18n.translate(context, "bottomBarGame"),
                        ),
                        BottomNavigationBarItem(
                          icon: FaIcon(
                            FontAwesomeIcons.search,
                            color: _bottomNavigationColor,
                            size: ScreenUtil().setSp(fontOfContent,
                                allowFontScalingSelf: true),
                          ),
                          label:
                              FlutterI18n.translate(context, "bottomBarSearch"),
                        ),
                        BottomNavigationBarItem(
                          icon: FaIcon(
                            FontAwesomeIcons.book,
                            color: _bottomNavigationColor,
                            size: ScreenUtil().setSp(fontOfContent,
                                allowFontScalingSelf: true),
                          ),
                          label:
                              FlutterI18n.translate(context, "bottomBarNotes"),
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(
                            Icons.more,
                            color: _bottomNavigationColor,
                            size: ScreenUtil().setSp(fontOfContent,
                                allowFontScalingSelf: true),
                          ),
                          label:
                              FlutterI18n.translate(context, "bottomBarMore"),
                        ),
                      ],
                      currentIndex: _currentIndex,
                      onTap: (int index) {
                        setState(() {
                          if (_scaffoldKey.currentState != null &&
                              _scaffoldKey.currentState.isDrawerOpen)
                            _scaffoldKey.currentState.openEndDrawer();
                          _currentIndex = index;
                        });
                      },
                      type: BottomNavigationBarType.shifting,
                      //)
                    )
                  : null,
              //)
            ));
    //),
    /*Expanded(
          flex: 1,
          child: Text(''),
        ),*/
    //],
    //);
  }
}
