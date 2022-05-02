import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:bibleapp/page/user_provider.dart';
import 'package:bibleapp/page/home_page.dart';
import 'package:bibleapp/util/common_value.dart';
//import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/loaders/decoders/json_decode_strategy.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:catcher/catcher.dart';

void main() async {
  /// STEP 1. Create catcher configuration.
  /// Debug configuration with dialog report mode and console handler. It will show dialog and once user accepts it, error will be shown   /// in console.
  /*CatcherOptions debugOptions =
      CatcherOptions(DialogReportMode(), [ConsoleHandler()]);
      
  /// Release configuration. Same as above, but once user accepts dialog, user will be prompted to send email with crash to support.
  CatcherOptions releaseOptions = CatcherOptions(DialogReportMode(), [
    EmailManualHandler(["jay2hk2hk@gmail.com"])
  ]);*/

  final FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: FileTranslationLoader(
      useCountryCode: true,
      fallbackFile: 'en_US',
      basePath: 'assets/i18n',
      //forcedLocale: Locale('en','US'),
      decodeStrategies: [JsonDecodeStrategy()],
    ),
    missingTranslationHandler: (key, locale) {
      print("--- Missing Key: $key, languageCode: ${locale.languageCode}");
    },
  );
  WidgetsFlutterBinding.ensureInitialized();
  //prefs = await SharedPreferences.getInstance();
  //await flutterI18nDelegate.load(null);
  runApp(MyApp(flutterI18nDelegate));

  /// STEP 2. Pass your root widget (MyApp) along with Catcher configuration:
  //Catcher(MyApp(flutterI18nDelegate), debugConfig: debugOptions, releaseConfig: releaseOptions);

  WidgetsFlutterBinding.ensureInitialized();
  //await MobileAds.initialize();
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
      child: */
          MaterialApp(
        /// STEP 3. Add navigator key from Catcher. It will be used to navigate user to report page or to show dialog.
        //navigatorKey: Catcher.navigatorKey,
        debugShowCheckedModeBanner: false,
        /*theme: new ThemeData(
          primaryColor: themeColor,
        ),*/ //theme:lightDark==0 ? ThemeData.light(): ThemeData.dark(),
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
        builder: FlutterI18n.rootAppBuilder(),
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
    context.findAncestorStateOfType<_RestartWidgetState>().restartApp();
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
