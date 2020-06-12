import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:bibleapp/page/user_provider.dart';
import 'package:bibleapp/page/home_page.dart';
import 'package:bibleapp/util/common_value.dart';
//import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  
  final FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: FileTranslationLoader(
        useCountryCode: true,
        //fallbackFile: 'zh_HK',
        basePath: 'assets/i18n',
        forcedLocale: Locale('en','US')),
  );
  WidgetsFlutterBinding.ensureInitialized();
  //prefs = await SharedPreferences.getInstance();
  await flutterI18nDelegate.load(null);
  runApp(MyApp(flutterI18nDelegate));

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  //runApp(new MyApp());
  if (Platform.isAndroid) {
    //设置Android头部的导航栏透明
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatelessWidget {

  final FlutterI18nDelegate flutterI18nDelegate;
  static int lightDark = 0;
  MyApp(this.flutterI18nDelegate);

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () async {
      //prefs = await SharedPreferences.getInstance();
      //lightDark = prefs.getInt(sharePrefLightDark);
      //RestartWidget.restartApp(context);
      //await FlutterI18n.refresh(context, Localizations.localeOf(context));
      /*setState(() {
        currentLang = FlutterI18n.currentLocale(context);
      });*/
    });
    return new RestartWidget(
        child: /*FlutterEasyLoading(
      child: */MaterialApp(
        /*theme: new ThemeData(
          primaryColor: themeColor,
        ),*///theme:lightDark==0 ? ThemeData.light(): ThemeData.dark(),
        home: new UserContainer(
          user: null,
          child: new HomePage(),
          /**
       * 将用户数据共享给子控件，任何地方的子控件都可以获取到父控件所保存的用户信息
       * 根据有没有用户信息，进入不同的页面
       * 
       */
        ),
        localizationsDelegates: [
        flutterI18nDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      ),
    //)
    );
  }
}

//这个组件用来重新加载整个child Widget的。当我们需要重启APP的时候，可以使用这个方案
///https://stackoverflow.com/questions/50115311/flutter-how-to-force-an-application-restart-in-production-mode
class RestartWidget extends StatefulWidget {
  final Widget child;

  RestartWidget({Key key, @required this.child})
      : assert(child != null),
        super(key: key);

  static restartApp(BuildContext context) {
    final _RestartWidgetState state =
        context.ancestorStateOfType(const TypeMatcher<_RestartWidgetState>());
    state.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      child: widget.child,
    );
  }
}