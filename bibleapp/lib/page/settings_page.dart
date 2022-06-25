import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:bibleapp/model/bible_bookmark.dart';
import 'package:bibleapp/util/common_value.dart';
import 'package:bibleapp/util/sql_helper.dart';
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
import 'package:bibleapp/util/common_function.dart';

GlobalKey globalKey = new GlobalKey(debugLabel: 'btm_app_bar');

class SettingsPage extends StatefulWidget {
  @override
  @override
  SettingsPage(GlobalKey key) {
    globalKey = key;
  }
  _SettingsPageState createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  //String _userName;
  //String _userId;
  final dbHelper = SQLHelper.instance;
  static double fontOfContent = 60.0; //px
  double sizeOfIcon = 50.0;
  static int page =
      0; //0 = more 1 = bookmark title, 2 = bookmark, 3 = style, 4 = FAQ, 5 = about, 6 = level, 7 = about, 8 other, 9 TheApostlesCreed
  static int bibleTitleTotal = 66;
  static int bibleTitleNew = 40;
  static int bibleTitleOld = 39;
  static int titleId = 0;
  var unescape = new HtmlUnescape(); //decode th html chinese word
  static String displayLanguage = languageTextValue[0];

  @override
  void initState() {
    BackButtonInterceptor.add(myInterceptor);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    BackButtonInterceptor.remove(myInterceptor);
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    //print("BACK BUTTON!"); // Do some stuff.
    if (page == 1 || /*page==2 ||*/ page == 3 ||
        page == 4 ||
        page == 5 ||
        page == 6 ||
        page == 7 ||
        page == 8) {
      setState(() {
        page = 0;
      });
    } else if (page == 2) {
      setState(() {
        page = 1;
      });
    } else if (page == 9 || page == 10 || page == 11) {
      setState(() {
        page = 8;
      });
    } else
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    Widget tempList;
    if (page == 0)
      tempList = _myListViewMore(context);
    else if (page == 1)
      tempList = _myListViewBookmarkTitle(context);
    else if (page == 2)
      tempList = _myListViewBookmark(context);
    else if (page == 3)
      tempList = _myListViewStyle(context);
    else if (page == 4)
      tempList = _myListViewFAQ(context);
    else if (page == 5)
      tempList = _myListViewAboutUs(context);
    else if (page == 6)
      tempList = _myListBibleLevel(context);
    else if (page == 7)
      tempList = _myListViewSupportForUs(context);
    else if (page == 8)
      tempList = _myListViewOtherInformation(context);
    else if (page == 9)
      tempList = _myListViewTheApostlesCreed(context);
    else if (page == 10)
      tempList = _myListViewTheNiceneCreed(context);
    else if (page == 11)
      tempList = _myListViewTheAthanasianCreed(context);
    else if (page == 12) tempList = _myListSelectLang(context);

    return tempList;
  }

  Widget _myListViewMore(BuildContext context) {
    final europeanCountries = [
      FlutterI18n.translate(context, "moreMenuBookmark"),
      FlutterI18n.translate(context, "moreMenuThemeStyle"),
      FlutterI18n.translate(context, "moreMenuFAQ"),
      FlutterI18n.translate(context, "moreMenuBibleTodaysLevel"),
      FlutterI18n.translate(context, "moreMenuSupportForUs"),
      FlutterI18n.translate(context, "moreMenuAboutUs"),
      FlutterI18n.translate(context, "moreMenuOtherInformation"),
      FlutterI18n.translate(context, "moreMenuSelectLang")
    ];
    return new Scaffold(
      appBar: AppBar(
        title: Text(
          FlutterI18n.translate(context, "bottomBarMore"),
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
                      page = 3;
                    else if (index == 2)
                      page = 4;
                    else if (index == 3)
                      page = 6;
                    else if (index == 4)
                      page = 7;
                    else if (index == 5)
                      page = 5;
                    else if (index == 6)
                      page = 8;
                    else if (index == 7) page = 12;
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

  Widget _myListViewStyle(BuildContext context) {
    // backing data
    final europeanCountries = [
      FlutterI18n.translate(context, "standardStyle"),
      FlutterI18n.translate(context, "darkStyle")
    ];

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
            FlutterI18n.translate(context, "moreMenuThemeStyle"),
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
                    trailing: (prefs.getInt(sharePrefLightDark) == index)
                        ? Icon(
                            Icons.check,
                            color: Colors.greenAccent,
                          )
                        : SizedBox.shrink(),
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
                      page = 0;
                    });
                    /*if (index == 0) {
                      prefs.setInt(sharePrefLightDark, 0);
                    } else {
                      prefs.setInt(sharePrefLightDark, 1);
                    }*/
                    prefs.setInt(sharePrefLightDark, index);
                    RestartWidget.restartApp(context);
                  });
            }, //itemBuilder
            separatorBuilder: (context, index) {
              return Divider();
            }, //separatorBuilder
          ),
        ));
  }

  Widget _myListViewFAQ(BuildContext context) {
    // backing data
    var europeanCountries = [
      FlutterI18n.translate(context, "questionNoSound"),
      FlutterI18n.translate(context, "answerNoSound"),
      FlutterI18n.translate(context, "questionIfDeleteKeepData"),
      FlutterI18n.translate(context, "answerIfDeleteKeepData"),
      FlutterI18n.translate(context, "questionCanGetBackCrown"),
      FlutterI18n.translate(context, "answerCanGetBackCrown"),
      FlutterI18n.translate(context, "questionCannotUseSaid"),
      FlutterI18n.translate(context, "answerCannotUseSaid")
    ];

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
            FlutterI18n.translate(context, "moreMenuFAQ"),
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

  Widget _myListViewAboutUs(BuildContext context) {
    // backing data
    var europeanCountries = [FlutterI18n.translate(context, "aboutUsText")];

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
            FlutterI18n.translate(context, "moreMenuAboutUs"),
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

  Widget _myListBibleLevel(BuildContext context) {
    // backing data
    final europeanCountries = [
      FlutterI18n.translate(context, "finishedOneYearBasic"),
      FlutterI18n.translate(context, "finishedOneYearAdvanced"),
      FlutterI18n.translate(context, "finishedHalfYearHighGrade"),
      FlutterI18n.translate(context, "finishedOneYearChallengeGrade")
    ];

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
            FlutterI18n.translate(context, "bibleTodaysLevelTitle"),
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
                    trailing: (prefs.getInt(sharePrefReadBibleLevel) == index)
                        ? Icon(
                            Icons.check,
                            color: Colors.greenAccent,
                          )
                        : SizedBox.shrink(),
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
                      page = 0;
                    });
                    /*if (index == 0) {
                      prefs.setInt(sharePrefReadBibleLevel, 0);
                    } else {
                      prefs.setInt(sharePrefReadBibleLevel, 1);
                    }*/
                    prefs.setInt(sharePrefReadBibleLevel, index);
                    RestartWidget.restartApp(context);
                  });
            }, //itemBuilder
            separatorBuilder: (context, index) {
              return Divider();
            }, //separatorBuilder
          ),
        ));
  }

  Widget _myListViewSupportForUs(BuildContext context) {
    // backing data
    var europeanCountries = [
      FlutterI18n.translate(context, "supportForUsText")
    ];

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
            FlutterI18n.translate(context, "moreMenuSupportForUs"),
            style: TextStyle(
              fontSize: ScreenUtil()
                  .setSp(fontOfContent - 5, allowFontScalingSelf: true),
            ),
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  FontAwesomeIcons.share,
                  color: iconColor,
                  size: ScreenUtil()
                      .setSp(sizeOfIcon, allowFontScalingSelf: true),
                ),
                onPressed: () {
                  shareToOther();
                }),
            SizedBox(
              width: ScreenUtil().setSp(5, allowFontScalingSelf: true),
            ),
          ],
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

  Widget _myListViewOtherInformation(BuildContext context) {
    // backing data
    var europeanCountries = [
      FlutterI18n.translate(context, "moreMenuTheApostlesCreed"),
      FlutterI18n.translate(context, "moreMenuTheNiceneCreed"),
      FlutterI18n.translate(context, "moreMenuTheAthanasianCreed")
    ];

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
            FlutterI18n.translate(context, "moreMenuOtherInformation"),
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
                        page = 9;
                      else if (index == 1)
                        page = 10;
                      else if (index == 2) page = 11;
                    });
                  });
            }, //itemBuilder
            separatorBuilder: (context, index) {
              return Divider();
            }, //separatorBuilder
          ),
        ));
  }

  Widget _myListViewTheApostlesCreed(BuildContext context) {
    // backing data
    var europeanCountries = [
      FlutterI18n.translate(context, "theApostlesCreedTText")
    ];

    return new Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),
            ),
            onPressed: () => {
              setState(() {
                page = 8;
              })
            },
          ),
          title: Text(
            FlutterI18n.translate(context, "moreMenuTheApostlesCreed"),
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

  Widget _myListViewTheNiceneCreed(BuildContext context) {
    // backing data
    var europeanCountries = [
      FlutterI18n.translate(context, "theNiceneCreedText")
    ];

    return new Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),
            ),
            onPressed: () => {
              setState(() {
                page = 8;
              })
            },
          ),
          title: Text(
            FlutterI18n.translate(context, "moreMenuTheNiceneCreed"),
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

  Widget _myListViewTheAthanasianCreed(BuildContext context) {
    // backing data
    var europeanCountries = [
      FlutterI18n.translate(context, "theAthanasianCreedText")
    ];

    return new Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),
            ),
            onPressed: () => {
              setState(() {
                page = 8;
              })
            },
          ),
          title: Text(
            FlutterI18n.translate(context, "moreMenuTheAthanasianCreed"),
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

  Widget _myListSelectLang(BuildContext context) {
    // backing data
    final europeanCountries = [
      chnageLanguageList[0],
      chnageLanguageList[1],
      chnageLanguageList[2],
      chnageLanguageList[3]
    ];

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
            FlutterI18n.translate(context, "moreMenuSelectLang"),
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
                    trailing: (prefs.getString(sharePrefDisplayLanguage) ==
                            languageTextValue[index])
                        ? Icon(
                            Icons.check,
                            color: Colors.greenAccent,
                          )
                        : SizedBox.shrink(),
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
                      page = 0;
                    });
                    changeLanguage(
                        context, languageTextValue[index], displayLanguage);
                  });
            }, //itemBuilder
            separatorBuilder: (context, index) {
              return Divider();
            }, //separatorBuilder
          ),
        ));
  }

  void shareToOther() {
    Share.share(copyShareReturnText());
  }

  String copyShareReturnText() {
    String tempText = FlutterI18n.translate(context, "shareAppText");

    return tempText;
  }

  Widget _myListViewBookmarkTitle(BuildContext context) {
    // backing data
    var europeanCountries = queryBibleTitleByDefault();

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
            FlutterI18n.translate(context, "moreMenuBookmark"),
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
                      titleId = index + 1;
                      page = 2;
                    });
                  });
            }, //itemBuilder
            separatorBuilder: (context, index) {
              return Divider();
            }, //separatorBuilder
          ),
        ));
  }

  Widget _myListViewBookmark(BuildContext context) {
    // backing data
    //var europeanCountries = [FlutterI18n.translate(context, "aboutUsText")];

    return new Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),
            ),
            onPressed: () => {
              setState(() {
                page = 1;
              })
            },
          ),
          title: Text(
            FlutterI18n.translate(context, "moreMenuBookmark"),
            style: TextStyle(
              fontSize: ScreenUtil()
                  .setSp(fontOfContent - 5, allowFontScalingSelf: true),
            ),
          ),
        ),
        body: new Center(
          child: FutureBuilder<List>(
            //key: btnKey,
            future: getBibleBookmarkByTitleId(titleId),
            initialData: List(),
            builder: (context, snapshot) {
              return new ScrollablePositionedList.separated(
                itemCount: snapshot.data == null ? 0 : snapshot.data.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1.0, color: splashColor),
                itemBuilder: (context, index) {
                  if (snapshot.data.length != 0) {
                    String temp = snapshot.data.length != 0
                        ? snapshot.data[index].toString()
                        : "";
                    String titleButtonText = snapshot.data.length != 0
                        ? temp.substring(0, temp.indexOf(':'))
                        : "";
                    String tempTitle = snapshot.data.length != 0
                        ? temp.substring(
                            temp.indexOf(':') + 1, temp.indexOf('+'))
                        : "";
                    String contentText = snapshot.data.length != 0
                        ? temp.substring(temp.indexOf('+') + 1)
                        : "";
                    return Container(
                      child: ListTile(
                        trailing: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            List<String> temp = tempTitle.split('-');
                            _showConfirm(
                                context,
                                "",
                                titleId,
                                int.parse(titleButtonText.split(' ')[1]),
                                int.parse(temp[0]));
                          },
                        ),
                        title: RaisedButton(
                          color: bottomNavigationColor,
                          textColor: buttonTextColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          child: Text(
                            titleButtonText + ":" + tempTitle,
                            style: new TextStyle(
                                fontSize: ScreenUtil().setSp(fontOfContent,
                                    allowFontScalingSelf: true),
                                color: buttonTextColor),
                          ),
                          onPressed: () {
                            if (prefs != null) {
                              prefs.setString(
                                  sharePrefTitleId, titleId.toString());
                              prefs.setString(sharePrefTitleNum,
                                  titleButtonText.split(' ')[1]);
                              List<String> temp = tempTitle.split('-');
                              prefs.setString(sharePrefContentNum, temp[0]);
                            }
                            //Navigator.pop(context);
                            final BottomNavigationBar navigationBar =
                                globalKey.currentWidget;
                            navigationBar.onTap(1);
                          },
                        ),
                        subtitle: Text(
                          snapshot.data.length == 0 ? "" : contentText,
                          style: new TextStyle(
                            fontSize: ScreenUtil().setSp(fontOfContent,
                                allowFontScalingSelf: true),
                            //color:fontTextColor
                          ),
                        ),
                        onTap: () => null,
                      ),
                    );
                  } else
                    return Container(
                      child: Text(''),
                    );
                }, //separatorBuilder
              );
            },
          ),
        ));
  }

  List<String> queryBibleTitleByDefault() {
    List<String> tmepList = new List<String>();
    int startCount = 1;
    int endCount = bibleTitleTotal;
    for (int i = startCount; i <= endCount; i++) {
      /*
        if(i==startCount)
          tmepList.add(FlutterI18n.translate(context, "bibleTitleSelection.1.selection")/*bibleAll["bibleTitleSelection"]["1"]["selection"]*/);
        else if(i==bibleTitleNew) 
          tmepList.add(FlutterI18n.translate(context, "bibleTitleSelection.2.selection")/*bibleAll["bibleTitleSelection"]["2"]["selection"]*/);
        */
      tmepList.add(FlutterI18n.translate(context,
          "bibleTitle.$i.title") /*bibleAll["bibleTitle"][i.toString()]["title"]*/);
    }
    tmepList.add('');
    return tmepList;
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

  void _showConfirm(BuildContext _context, String text, int titleId,
      int contentId, int textId) {
    showDialog<void>(
      context: _context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(FlutterI18n.translate(context, "confirmDelete"),
              style: new TextStyle(
                  fontSize: ScreenUtil()
                      .setSp(fontOfContent, allowFontScalingSelf: true))),
          content: Text(text),
          actions: <Widget>[
            FlatButton(
              child: Text(FlutterI18n.translate(context, "cancelButton"),
                  style: new TextStyle(
                      fontSize: ScreenUtil()
                          .setSp(fontOfContent, allowFontScalingSelf: true))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(FlutterI18n.translate(context, "okButton"),
                  style: new TextStyle(
                      fontSize: ScreenUtil()
                          .setSp(fontOfContent, allowFontScalingSelf: true))),
              onPressed: () async {
                await dbHelper.deleteBookMarkByTitleIdContentIdTextId(
                    titleId, contentId, textId);
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }
}
