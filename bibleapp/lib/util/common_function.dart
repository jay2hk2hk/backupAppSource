import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:bibleapp/main.dart';
import 'package:bibleapp/model/bible_game.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:bibleapp/util/common_value.dart';
import 'package:bibleapp/page/settings_page.dart';

List<String> queryNumberMic(BuildContext context) {
  List<String> tmepList = new List<String>();
  for (int i = 1; i <= 10; i++) {
    tmepList.add(FlutterI18n.translate(context, "numberForMic.$i"));
  }
  return tmepList;
}

//query title by default
List<String> queryBibleTitleByDefault(
    BuildContext context, int bibleTitleTotal, int bibleTitleNew) {
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
  for (int i = startCount; i <= endCount; i++) {
    if (i == startCount)
      tmepList.add(FlutterI18n.translate(context,
          "bibleTitleSelection.1.selection") /*bibleAll["bibleTitleSelection"]["1"]["selection"]*/);
    else if (i == bibleTitleNew)
      tmepList.add(FlutterI18n.translate(context,
          "bibleTitleSelection.2.selection") /*bibleAll["bibleTitleSelection"]["2"]["selection"]*/);
    tmepList.add(FlutterI18n.translate(context,
        "bibleTitle.$i.title") /*bibleAll["bibleTitle"][i.toString()]["title"]*/);
  }
  tmepList.add('');
  return tmepList;
}

String getBibleTitleIdByTitle(BuildContext context, String title) {
  //List<BibleTitle> temp = jsonBibleTitleResult.where((v) => v.title == title).toList();
  //return temp[0].titleId;
  String temp = FlutterI18n.translate(context,
      "bibleTitle.$title.titleId") /*bibleAll["bibleTitle"][title]["titleId"]*/;
  return temp;
}

List<String> queryTitleNum(String titleId, List<int> bibleTitleTotalNum) {
  int temp = bibleTitleTotalNum[int.parse(titleId) - 1];
  List<String> tmepList = List.generate(temp, (i) => (i + 1).toString());
  tmepList.add('');

  return tmepList;
}

List<String> queryBibleWrong(BuildContext context) {
  List<String> tmepList = new List<String>();
  for (int i = 1; i <= 2; i++) {
    tmepList.add(FlutterI18n.translate(context, "bibleTitleWrongFix.$i"));
  }
  return tmepList;
}

//language
changeLanguage(
    BuildContext context, String value, String displayLanguage) async {
  displayLanguage = value;
  prefs.setString(sharePrefDisplayLanguage, displayLanguage);
  String language = "";
  List<String> cl = value.split("-");
  currentLang = Locale(cl[0], cl[1]);

  await FlutterI18n.refresh(context, currentLang);
  //setState(() {
  //_dataForListView = queryBibleContentByTitle(_titleId,_titleNum);
  if (languageTextValue[0] == value)
    language = languageVolumeValue[0];
  else if (languageTextValue[1] == value) {
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
    Platform.isAndroid
        ? language = languageVolumeValue[1]
        : language = languageTextValue[1];
  } else if (languageTextValue[2] == value)
    language = languageVolumeValue[2];
  else if (languageTextValue[3] == value) language = languageVolumeValue[3];
  prefs.setString(sharePrefSoundLanguage, language);
  RestartWidget.restartApp(context);
  //});
}
