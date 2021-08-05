import 'dart:ui';

import 'package:bibleapp/model/bible_content.dart';
import 'package:bibleapp/model/bible_title.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<DateTime, List> events;
Color buttonTextColor = Color(0xFFFFFFFF); //white
Color backgroundColor = Color(0xFFFFFFFF); //white
Color boxShadowColor = Color(0x1F000000); //black12
Color bottomNavigationColor = Color(0xFF2196F3); //blue
Color raisedButtonColor = Color(0xFF03A9F4); //lightBlue
Color splashColor = Color(0xFF9E9E9E); //grey
Color themeColor = Color(0xFF2196F3); //blue
Color iconColor = Color(0xFFFFFFFF); //white
Color containerColor = Color(0xFFFFFFFF); //white
Color titleColor = Color(0xFF2196F3); //blue
Color iconAlertDialogColor = Color(0xFF000000); //black
Color lightlineListColor = Color(0xFFFFFD180); //orange
Color fontTextColor = Color(0xFF000000); //black
Color weekEndTextColor = Color(0xFFFF5252); //red
Color correctAnswerColor = Color(0xFF33cc33); //green

Locale currentLang;
SharedPreferences prefs; //save the user data
List<String> chnageLanguageList = [
  "English King James Version",
  "繁體中文和合本(廣東話)",
  "繁體中文和合本(國語)",
  "简体中文和合本(普通话)"
];

List<String> languageTextValue = ["en-US", "zh-HK", "zh-TW", "zh-CN"];
List<String> languageVolumeValue = ["en-US", "yue-HK", "zh-TW", "zh-CN"];
String sharePrefTitleId = '_titleId';
String sharePrefTitleNum = '_titleNum';
String sharePrefContentNum = '_contentNum';
String sharePrefFontSize = '_fontSize';
String sharePrefSpeechRate = '_speechRate';
String sharePrefDisplayLanguage = '_displayLang';
String sharePrefSoundLanguage = '_soundLang';
String sharePrefBibleTodaysDate = '_bibleTodaysDate';
String sharePrefBibleTodaysString = '_bibleTodaysString';
String sharePrefBibleTodaysReadString = '_bibleTodaysReadString';
String sharePrefBibleTodaysGotCrown = '_bibleTodaysGotCrown';
String sharePrefBibleTodaysGotCrownTotal = '_bibleTodaysGotCrownTotal';
String sharePrefBibleTodaysGotCrownLoadedReward =
    '_bibleTodaysGotCrownLoadedReward';
String sharePrefLightDark = '_lightDark';
String sharePrefReadBibleLevel = '_readBibleLevel';
String sharePrefUpdateVersionNum = '_updateVersionNum';
//for game char MC
String sharePrefCorrectQuestionNum = '_correctQuestionNum';
String sharePrefTotalAnsweredNum = '_totalAnsweredNum';
String sharePrefGameLevel = '_gameLevel';
String sharePrefTodayRewardAdsGameMC = '_todayRewardAdsGameMC';
String sharePrefTodayCanRewardAdsGameMC = '_todayCanRewardAdsGameMC';
String sharePrefTodayNextButtonStatus = '_todayNextButtonStatus';
String sharePrefTodayPlayAds = '_todayPlayAds';
String sharePrefTodayCorrectAnswerNum = '_todayCorrectAnswerNum';
//BQA
String sharePrefCorrectBQAQuestionNum = '_correctBQAQuestionNum';
String sharePrefTotalBQAAnsweredNum = '_totalBQAAnsweredNum';
String sharePrefGameBQALevel = '_gameBQALevel';
String sharePrefTodayBQARewardAdsGameMC = '_todayBQARewardAdsGameMC';
String sharePrefTodayBQACanRewardAdsGameMC = '_todayBQACanRewardAdsGameMC';
String sharePrefTodayBQANextButtonStatus = '_todayBQANextButtonStatus';
String sharePrefTodayBQAPlayAds = '_todayBQAPlayAds';
String sharePrefTodayBQACorrectAnswerNum = '_todayBQACorrectAnswerNum';

//

String cuvBibleContentFile = 'assets/json/bible_cuv.json';
String cuvBibleTitleFile = 'assets/json/bible_title_cuv.json';
List<BibleContent> jsonBibleContentResult =
    new List<BibleContent>(); //content display
List<BibleTitle> jsonBibleTitleResult = new List<BibleTitle>(); //title display
List<String> bibleGoodSentenceExhortation = [
  "3:19:32",
  "5:31:6",
  "20:3:5-6",
  "21:7:8",
  "21:9:10",
  "21:12:1",
  "28:10:12",
  "33:6:8",
  "46:4:7",
  "46:15:58",
  "43:14:21",
  "49:6:13",
  "51:2:6",
  "51:3:2",
  "51:3:17",
  "52:5:12",
  "54:6:11",
  "55:2:11-12",
  "55:2:24",
  "56:2:11-12",
  "60:5:7"
]; //勸勉
List<String> bibleGoodSentenceFalse = [
  "40:23:27-28",
  "40:6:1",
  "21:12:14",
  "60:1:22",
  "55:3:5",
  "45:12:9",
  "48:1:10",
  "51:3:23-24"
]; //虛假
List<String> bibleGoodSentenceEvilWords = [
  "59:1:26",
  "40:5:37",
  "20:15:28",
  "49:4:25",
  "40:4:25",
  "20:10:19",
  "45:2:1",
  "20:19:9",
  "41:3:28-29"
]; //惡言
List<String> bibleGoodSentenceGreedy = ["40:6:21", "58:13:5", "54:6:7-10"]; //貪念
List<String> bibleGoodSentenceArrogant = [
  "20:13:10",
  "48:5:26",
  "20:16:5",
  "20:3:5-6",
  "20:11:2",
  "20:21:30",
  "47:10:17-18"
]; //高傲
List<String> bibleGoodSentenceGodsLove = [
  "23:46:4",
  "23:54:10",
  "36:3:17",
  "43:3:16",
  "46:13:8",
  "47:5:14",
  "62:4:10"
]; //神的愛
List<String> bibleGoodSentenceGodsWork = [
  "1:1:26",
  "2:3:15",
  "10:22:35-36",
  "18:10:11-12",
  "18:36:15",
  "19:23:2-3",
  "19:127:1",
  "23:9:6",
  "23:42:3",
  "23:55:8",
  "27:2:22",
  "27:4:17",
  "47:1:20",
  "47:12:9",
  "49:3:20",
  "50:2:13",
  "53:3:3",
  "62:1:7"
]; //神的作為
List<String> bibleGoodSentenceTrialOfSuffering = [
  "5:8:3",
  "19:46:1",
  "19:66:11-12",
  "34:1:7",
  "40:5:10",
  "40:11:28",
  "41:13:13",
  "45:5:3-4",
  "45:8:18",
  "50:1:29",
  "58:2:18",
  "60:4:14"
]; //苦難試煉
List<String> bibleGoodSentenceDeclare = [
  "1:22:14",
  "5:33:27",
  "6:24:15",
  "9:7:12",
  "9:15:22",
  "14:7:14",
  "19:9:7-8",
  "19:24:3-4",
  "19:81:10",
  "19:84:11",
  "19:111:10",
  "20:4:18",
  "24:32:27",
  "30:4:13",
  "41:3:35",
  "41:10:45",
  "42:15:10",
  "43:6:35",
  "43:6:37",
  "43:8:12",
  "43:11:25",
  "43:14:6",
  "43:15:5",
  "47:4:7",
  "54:2:5-6",
  "58:6:10",
  "58:13:8"
]; //宣告
List<String> bibleGoodSentenceJealous = [
  "59:4:5-7",
  "59:3:16",
  "19:37:1-5"
]; //妒忌
List<String> bibleGoodSentenceLazy = [
  "58:10:24-25",
  "49:5:15-18",
  "46:15:58"
]; //懶惰
List<String> bibleGoodSentenceHatred = [
  "49:4:26-27",
  "40:24:12-13",
  "20:29:11",
  "20:19:11",
  "46:11:27-29",
  "20:3:30",
  "20:24:17-18",
  "58:13:14-15"
]; //憎恨
List<String> bibleGoodSentenceErotic = [
  "20:5:23",
  "20:6:23-26",
  "48:5:19-21",
  "58:13:25",
  "55:2:21"
]; //愛慾
List<String> bibleGoodSentenceInferiority = ["43:15:16", "46:1:27-29"]; //自卑
List<String> bibleGoodSentenceFear = [
  "55:1:7",
  "20:2:7",
  "23:41:10",
  "49:4:15-16",
  "41:5:36",
  "23:12:2",
  "19:56:3-4",
  "58:13:6",
  "19:27:1",
  "20:3:24-26"
]; //懼怕
List<String> bibleGoodSentenceConcern = ["40:18:19", "1:28:15", "61:3:9"]; //憂慮
List<String> bibleGoodSentenceDefeat = [
  "46:10:13",
  "40:11:28",
  "59:5:16",
  "40:7:13-14",
  "59:1:12"
]; //挫敗
List<String> bibleGoodSentencePrayer = [
  "40:16:27",
  "42:18:1",
  "41:11:24",
  "19:34:15",
  "27:6:10",
  "42:11:1",
  "49:6:18",
  "41:14:38",
  "40:5:44"
]; //祈禱
List<String> bibleGoodSentenceSuffering = [
  "46:10:13",
  "18:42:3",
  "47:12:9",
  "66:7:17",
  "40:14:14",
  "19:11:5",
  "18:2:10",
  "19:143:8",
  "40:11:28",
  "19:46:1",
  "43:16:33",
  "19:34:9",
  "45:8:18",
  "59:1:2-4",
  "19:119:71",
  "46:10:13",
  "19:32:7",
  "40:5:10",
  "19:17:7",
  "19:18:18",
  "19:20:9"
]; //苦難
List<String> bibleGoodSentenceConfidence = [
  "40:8:13",
  "40:9:2",
  "40:15:28",
  "40:17:20",
  "40:21:21",
  "41:9:23",
  "42:17:6",
  "45:4:19",
  "45:9:32",
  "45:12:3",
  "45:12:6",
  "45:14:22",
  "45:14:23",
  "47:1:24",
  "47:3:4",
  "47:5:7",
  "47:10:15",
  "48:5:5",
  "48:5:6",
  "51:2:2",
  "52:3:7",
  "52:3:10",
  "53:1:4",
  "54:1:5",
  "54:1:14",
  "54:1:19",
  "54:6:11",
  "55:1:13",
  "56:2:2",
  "57:1:6",
  "58:3:14",
  "58:4:2",
  "58:6:12",
  "58:10:22",
  "58:10:39",
  "58:11:13",
  "58:12:2",
  "58:13:7",
  "59:1:3-4",
  "59:1:6",
  "59:2:14",
  "59:2:17",
  "59:2:18",
  "59:2:20",
  "59:2:22",
  "59:2:26",
  "59:5:15",
  "60:1:9",
  "60:1:21" /*,"61:1:5-7","62:5:4","62:13:10"*/
]; //信心
List<String> bibleGoodSentenceJoy = [
  "20:17:22",
  "19:4:7",
  "18:22:26",
  "20:15:13",
  "20:10:28",
  "19:34:2",
  "50:4:4",
  "45:12:12",
  "59:1:2",
  "19:64:10",
  "48:5:22",
  "19:16:9",
  "43:16:24",
  "19:16:11",
  "43:16:22",
  "60:4:13",
  "19:97:11-12",
  "60:1:8",
  "42:15:7",
  "23:55:12"
]; //喜樂
List<String> bibleGoodSentenceHope = [
  "61:3:13",
  "19:62:5",
  "19:71:5",
  "19:71:14",
  "19:119:49",
  "60:1:3",
  "60:1:13",
  "60:1:21",
  "60:3:15",
  "47:1:7",
  "61:3:14",
  "48:5:5",
  "20:10:28",
  "45:5:2",
  "19:147:11",
  "45:8:24-25",
  "49:1:12",
  "53:2:16",
  "56:1:2",
  "56:2:13",
  "56:3:6-7",
  "58:3:6"
]; //盼望
List<String> bibleGoodSentenceBaptized = [
  "48:3:26-27",
  "40:28:19-20",
  "60:3:21",
  "44:2:38",
  "41:16:16",
  "43:3:5",
  "44:22:16",
  "45:6:3",
  "42:3:21-22",
  "46:12:13",
  "43:1:33",
  "44:10:47",
  "44:19:4",
  "44:2:41",
  "56:3:5"
]; //受洗
List<String> bibleGoodSentenceSafe = [
  "4:6:24-26",
  "43:16:33",
  "50:4:6-7",
  "43:14:27",
  "40:5:9",
  "60:3:10-11",
  "53:3:16",
  "19:4:8",
  "23:26:3",
  "51:3:13",
  "51:3:15",
  "65:1:2",
  "20:16:32",
  "59:3:18",
  "19:34:14",
  "58:12:14",
  "49:4:3",
  "19:119:165",
  "59:3:17",
  "19:46:10",
  "50:4:9",
  "23:52:7",
  "45:8:6",
  "20:20:3",
  "58:12:11",
  "19:29:11",
  "45:5:1",
  "42:2:14",
  "47:13:11",
  "45:12:18",
  "20:3:1-2",
  "43:20:21",
  "20:12:20",
  "58:13:20-21",
  "45:1:7",
  "23:54:10",
  "45:16:20",
  "44:9:31"
]; //平安
List<String> bibleGoodSentenceBless = [
  "24:17:7-8",
  "4:6:24-26",
  "19:20:4",
  "20:16:3",
  "24:29:11",
  "50:4:19",
  "2:23:25",
  "19:34:8",
  "5:30:16",
  "19:23:1-2",
  "45:12:14",
  "20:16:20",
  "19:31:19",
  "42:6:27-28",
  "57:1:25",
  "60:3:9",
  "48:5:22-23",
  "5:28:1",
  "40:5:6",
  "50:4:23",
  "39:3:10",
  "40:5:9",
  "19:119:2",
  "20:10:22",
  "40:25:21",
  "42:6:45",
  "64:1:2",
  "47:9:8",
  "19:1:1",
  "65:1:2",
  "35:3:19",
  "5:15:6",
  "20:3:7-8",
  "20:18:22",
  "19:67:7",
  "40:5:8",
  "47:9:11",
  "6:1:8",
  "19:149:4",
  "26:34:26",
  "19:29:11",
  "19:34:1",
  "66:22:21",
  "58:13:20-21",
  "11:2:3",
  "47:13:14",
  "20:18:21",
  "5:10:12-13",
  "19:3:8",
  "43:20:29",
  "20:10:6",
  "40:5:4",
  "19:33:12",
  "42:24:50-51",
  "39:2:2",
  "2:20:12",
  "20:10:7",
  "59:3:10",
  "19:31:16",
  "59:1:25",
  "20:4:10",
  "20:2:7",
  "2:1:21",
  "44:13:3",
  "45:1:7",
  "1:2:3",
  "42:6:22",
  "18:42:10",
  "41:10:29-30",
  "3:26:3-4",
  "1:26:4-5",
  "19:118:25-26",
  "19:32:1",
  "5:4:40",
  "19:8:4",
  "1:1:28",
  "18:5:17",
  "5:5:29",
  "40:5:11",
  "49:1:3",
  "24:7:5-7",
  "44:3:26"
]; //祝福

List<String> bibleGoodSentenceGrace = [
  "58:4:16",
  "4:6:24-26",
  "49:2:4-5",
  "19:103:8",
  "60:5:10",
  "56:2:11-12",
  "23:30:18",
  "55:1:9",
  "40:6:14",
  "45:6:14",
  "66:22:21",
  "45:3:23-24",
  "45:6:15",
  "49:2:8-9",
  "19:90:17",
  "14:30:9",
  "57:1:25",
  "43:3:16",
  "19:23:6",
  "60:1:13",
  "45:5:15",
  "45:5:21",
  "47:12:9",
  "19:130:1-2",
  "44:20:24",
  "20:28:13",
  "61:3:18",
  "55:2:1",
  "47:13:14",
  "50:4:23",
  "45:6:1-2",
  "45:12:3",
  "16:9:31",
  "50:1:29",
  "23:55:7",
  "40:18:21-22",
  "48:2:21",
  "19:8:4",
  "45:1:7",
  "29:2:13",
  "24:3:12",
  "60:3:7",
  "45:16:20",
  "58:8:12"
]; //恩典

List<String> bibleGoodSentenceMercy = [
  "58:4:16",
  "40:9:13",
  "49:2:4-5",
  "19:51:1-2",
  "33:7:18",
  "23:30:18",
  "14:30:9",
  "40:6:14",
  "19:25:6-7",
  "45:12:1",
  "45:6:15",
  "19:90:17",
  "19:23:6",
  "19:112:5",
  "43:3:16",
  "19:40:11",
  "19:130:1-2",
  "45:5:15",
  "16:9:31",
  "20:28:13",
  "47:12:9",
  "23:55:7",
  "40:18:21-22",
  "24:3:12",
  "50:1:29",
  "47:13:14",
  "56:3:5"
]; //憐憫

List<String> bibleGoodSentenceForgive = [
  "20:17:9",
  "49:4:32",
  "40:6:14",
  "51:3:13",
  "14:7:14",
  "42:6:37",
  "40:18:21-22",
  "20:28:13",
  "19:86:5",
  "33:7:18",
  "41:11:25",
  "44:13:38-39",
  "62:2:2",
  "14:30:9",
  "19:32:5",
  "29:2:13",
  "49:1:7",
  "40:6:12",
  "44:3:19",
  "44:2:38",
  "59:5:14-15",
  "23:55:7",
  "16:9:31",
  "44:17:30",
  "24:3:12",
  "19:32:1",
  "40:9:12",
  "40:6:15",
  "42:17:3-4",
  "40:12:32",
  "58:8:12",
  "51:1:13-14",
  "23:1:18",
  "40:12:31",
  "23:55:7",
  "40:18:21-22",
  "48:2:21",
  "19:8:4",
  "45:1:7",
  "29:2:13",
  "24:3:12",
  "60:3:7",
  "45:16:20",
  "58:8:12"
]; //饒恕

List<String> bibleGoodSentenceHeal = [
  "41:9:23",
  "42:8:50",
  "19:147:3",
  "59:5:14-15",
  "41:10:52",
  "40:10:8",
  "20:17:22",
  "59:5:16",
  "14:7:14",
  "23:53:5",
  "60:2:24",
  "12:20:5",
  "42:10:9",
  "40:9:12",
  "2:15:26",
  "42:13:10-17",
  "24:17:14",
  "42:4:18",
  "19:107:20",
  "19:146:8",
  "47:12:9",
  "23:55:7",
  "40:18:21-22",
  "24:3:12",
  "50:1:29",
  "47:13:14",
  "56:3:5"
]; //醫治

List<String> bibleGoodSentenceMiracle = [
  "41:10:27",
  "41:9:23",
  "42:18:27",
  "24:32:27",
  "42:8:50",
  "42:1:37",
  "19:139:13-14",
  "40:19:26",
  "40:17:20",
  "42:9:16-17",
  "42:13:10-17",
  "19:9:1",
  "40:21:21",
  "41:6:49-50",
  "44:1:9",
  "23:7:14",
  "43:20:8-9",
  "40:1:22-23",
  "40:1:18",
  "19:146:8",
  "47:12:9",
  "23:55:7",
  "40:18:21-22",
  "24:3:12",
  "50:1:29",
  "47:13:14",
  "56:3:5"
]; //神蹟

List<String> bibleGoodSentenceLove = [
  "19:121:7-8",
  "49:5:15-16",
  "20:27:19",
  "47:5:7",
  "51:3:23-24",
  "20:21:21",
  "41:8:36",
  "19:73:26",
  "60:3:10-11",
  "19:31:3",
  "20:4:23",
  "21:3:1",
  "19:25:4",
  "45:12:2",
  "43:6:35",
  "19:37:7",
  "20:13:3",
  "19:23:6",
  "5:30:16",
  "43:7:38",
  "48:2:20",
  "20:19:8",
  "58:12:14",
  "20:10:17",
  "59:3:13",
  "21:7:10",
  "40:16:25",
  "19:37:5-6",
  "40:6:34",
  "21:7:14",
  "54:4:12",
  "50:2:14-16",
  "19:118:24",
  "62:4:9",
  "40:6:25",
  "24:17:9-10",
  "46:15:22",
  "20:3:1-2",
  "40:10:39",
  "42:11:28",
  "43:14:6",
  "50:1:21",
  "40:5:14",
  "48:5:25",
  "19:16:11",
  "59:1:12",
  "46:6:12",
  "20:13:12",
  "40:16:26",
  "46:6:19-20",
  "19:63:3-4",
  "45:14:8",
  "55:3:16-17",
  "20:10:9",
  "62:4:15",
  "19:119:93",
  "43:8:12",
  "66:3:19",
  "21:3:12-13",
  "19:54:4",
  "48:5:1",
  "47:5:1",
  "62:5:12",
  "21:3:11",
  "20:4:26",
  "20:14:12",
  "50:4:12",
  "45:8:6",
  "44:20:24",
  "42:12:22-23",
  "59:2:17",
  "43:10:10",
  "47:10:3",
  "19:34:22",
  "19:119:1",
  "46:10:31",
  "1:50:20",
  "44:17:28",
  "20:4:10",
  "45:12:18",
  "21:12:1",
  "47:13:11",
  "59:1:18",
  "23:57:15",
  "19:90:4",
  "47:5:14-15",
  "19:24:1",
  "60:1:15-16",
  "30:5:4",
  "40:3:8",
  "46:8:6",
  "45:8:11",
  "41:8:35",
  "21:12:13",
  "21:9:7",
  "60:2:16",
  "60:1:18-19",
  "35:2:4",
  "54:4:8",
  "5:8:3",
  "50:1:23-24",
  "58:12:1",
  "23:55:7",
  "43:1:3",
  "1:1:26",
  "61:1:3",
  "66:3:5",
  "3:20:26",
  "58:3:14",
  "5:4:40",
  "45:6:1-2",
  "21:5:18",
  "55:3:12",
  "42:9:24",
  "1:1:29",
  "19:86:11",
  "51:3:9-10",
  "42:12:24",
  "43:6:57"
]; //愛

List<String> bibleGoodSentenceLife = [
  "46:13:4-5",
  "46:16:14",
  "19:143:8",
  "51:3:14",
  "20:3:3-4",
  "62:4:16",
  "49:4:2",
  "62:4:19",
  "46:13:13",
  "60:4:8",
  "45:12:9",
  "49:3:16-17",
  "46:13:2",
  "43:15:12",
  "23:49:15-16",
  "45:12:10",
  "53:3:5",
  "49:5:25-26",
  "62:4:12",
  "62:4:20",
  "43:15:13",
  "23:43:4",
  "46:2:9",
  "45:13:8",
  "62:3:1",
  "62:4:18",
  "22:8:6",
  "52:3:12",
  "20:21:21",
  "62:4:8",
  "20:10:12",
  "45:8:38-39",
  "25:3:22-23",
  "41:12:30",
  "41:12:31",
  "49:4:15",
  "19:116:1-2",
  "46:13:1",
  "46:10:24",
  "65:1:2",
  "60:3:10-11",
  "19:30:5",
  "54:4:12",
  "55:1:7",
  "40:5:44",
  "45:13:10",
  "62:4:10",
  "45:8:35",
  "19:42:8",
  "3:19:17-18",
  "46:13:3",
  "19:103:8",
  "48:5:22-23",
  "54:6:11",
  "49:5:2",
  "62:3:11",
  "19:94:18",
  "61:1:5-7",
  "19:63:3-4",
  "58:13:1-2",
  "42:10:27",
  "62:4:11",
  "62:2:15",
  "43:14:21",
  "43:13:34",
  "62:4:7",
  "66:3:19",
  "19:86:5",
  "48:5:14",
  "43:14:15",
  "43:13:35",
  "45:8:28",
  "46:13:6-7",
  "62:4:9",
  "49:2:4-5",
  "45:13:9",
  "20:3:11-12",
  "45:5:5",
  "48:5:13",
  "19:33:5",
  "43:14:23",
  "19:103:13",
  "53:1:3",
  "62:3:16",
  "45:8:37",
  "47:13:11",
  "19:27:4",
  "5:6:4-5",
  "62:4:21",
  "43:17:26",
  "47:5:14-15",
  "19:40:11",
  "51:2:2",
  "23:54:10",
  "47:13:14",
  "62:3:17",
  "65:1:20-21",
  "40:19:18-19",
  "43:3:16",
  "19:115:1",
  "40:22:39",
  "19:31:16",
  "19:44:3",
  "29:2:13",
  "43:15:10",
  "40:19:19",
  "48:5:6",
  "19:112:1"
]; //生活

List<List<String>> saveAllBibleSentence = [
  bibleGoodSentenceExhortation,
  bibleGoodSentenceFalse,
  bibleGoodSentenceEvilWords,
  bibleGoodSentenceGreedy,
  bibleGoodSentenceArrogant,
  bibleGoodSentenceGodsLove,
  bibleGoodSentenceGodsWork,
  bibleGoodSentenceTrialOfSuffering,
  bibleGoodSentenceDeclare,
  bibleGoodSentenceJealous,
  bibleGoodSentenceLazy,
  bibleGoodSentenceHatred,
  bibleGoodSentenceErotic,
  bibleGoodSentenceInferiority,
  bibleGoodSentenceFear,
  bibleGoodSentenceConcern,
  bibleGoodSentenceDefeat,
  bibleGoodSentencePrayer,
  bibleGoodSentenceSuffering,
  bibleGoodSentenceConfidence,
  bibleGoodSentenceJoy,
  bibleGoodSentenceHope,
  bibleGoodSentenceBaptized,
  bibleGoodSentenceSafe,
  bibleGoodSentenceBless,
  bibleGoodSentenceGrace,
  bibleGoodSentenceMercy,
  bibleGoodSentenceForgive,
  bibleGoodSentenceHeal,
  bibleGoodSentenceMiracle,
  bibleGoodSentenceLove,
  bibleGoodSentenceLife
];

List<String> date1 = [
  "19:1," + "40:1," + "1:1," + "1:2",
  "19:2," + "40:2," + "1:3," + "1:4",
  "19:3," + "40:3," + "1:5," + "1:6",
  "19:4," + "40:4," + "1:7," + "1:8",
  "19:5," + "40:5," + "1:9," + "1:10",
  "19:6," + "40:6," + "1:11," + "1:12",
  "19:7," + "40:7," + "1:13," + "1:14",
  "19:8," + "40:8," + "1:15," + "1:16",
  "19:9," + "40:9," + "1:17," + "1:18",
  "19:10," + "40:10," + "1:19," + "1:20",
  "19:11," + "40:11," + "1:21," + "1:22",
  "19:12," + "40:12," + "1:23," + "1:24",
  "19:13," + "40:13," + "1:25," + "1:26",
  "19:14," + "40:14," + "1:27," + "1:28",
  "19:15," + "40:15," + "1:29," + "1:30",
  "19:16," + "40:16," + "1:31," + "1:32",
  "19:17," + "40:17," + "1:33," + "1:34",
  "19:18," + "40:18," + "1:35," + "1:36",
  "19:19," + "40:19," + "1:37," + "1:38",
  "19:20," + "40:20," + "1:39," + "1:40",
  "19:21," + "40:21," + "1:41," + "1:42",
  "19:22," + "40:22," + "1:43," + "1:44",
  "19:23," + "40:23," + "1:45," + "1:46",
  "19:24," + "40:24," + "1:47," + "1:48",
  "19:25," + "40:25," + "1:49," + "1:50",
  "19:26," + "40:26," + "2:1," + "2:2",
  "19:27," + "40:27," + "2:3," + "2:4",
  "19:28," + "40:28," + "2:5," + "2:6",
  "19:29," + "44:1," + "2:7," + "2:8",
  "19:30," + "44:2," + "2:9," + "2:10",
  "19:31," + "44:3," + "2:11," + "2:12"
];

List<String> date2 = [
  "19:32," + "44:4," + "2:13," + "2:14",
  "19:33," + "44:5," + "2:15," + "2:16",
  "19:34," + "44:6," + "2:17," + "2:18",
  "19:35," + "44:7," + "2:19," + "2:20",
  "19:36," + "44:8," + "2:21," + "2:22",
  "19:37," + "44:9," + "2:23," + "2:24",
  "19:38," + "44:10," + "2:25," + "2:26",
  "19:39," + "44:11," + "2:27," + "2:28",
  "19:40," + "44:12," + "2:29," + "2:30",
  "19:41," + "44:13," + "2:31," + "2:32",
  "19:42," + "44:14," + "2:33," + "2:34",
  "19:43," + "44:15," + "2:35," + "2:36",
  "19:44," + "44:16," + "2:37," + "2:38",
  "19:45," + "44:17," + "2:39," + "2:40",
  "19:46," + "44:18," + "3:1," + "3:2," + "3:3",
  "19:47," + "44:19," + "3:4," + "3:5",
  "19:48," + "44:20," + "3:6," + "3:7",
  "19:49," + "44:21," + "3:8," + "3:9",
  "19:50," + "44:22," + "3:10," + "3:11",
  "19:51," + "44:23," + "3:12," + "3:13",
  "19:52," + "44:24," + "3:14," + "3:15",
  "19:53," + "44:25," + "3:16," + "3:17",
  "19:54," + "44:26," + "3:18," + "3:19",
  "19:55," + "44:27," + "3:20," + "3:21",
  "19:56," + "44:28," + "3:22," + "3:23",
  "19:57," + "44:1," + "3:24," + "3:25",
  "19:58," + "44:2," + "3:26," + "3:27",
  "19:59," + "44:3," + "4:1," + "4:2",
  ""
];

List<String> date3 = [
  "19:60," + "44:4," + "4:3," + "4:4",
  "19:61," + "44:5," + "4:5," + "4:6",
  "19:62," + "44:6," + "4:7," + "4:8",
  "19:63," + "44:7," + "4:9," + "4:10",
  "19:64," + "44:8," + "4:11," + "4:12",
  "19:65," + "44:9," + "4:13," + "4:14",
  "19:66," + "44:10," + "4:15," + "4:16",
  "19:67," + "44:11," + "4:17," + "4:18",
  "19:68," + "44:12," + "4:19," + "4:20",
  "19:69," + "44:13," + "4:21," + "4:22",
  "19:70," + "44:14," + "4:23," + "4:24",
  "19:71," + "44:15," + "4:25," + "4:26",
  "19:72," + "44:16," + "4:27," + "4:28",
  "19:73," + "45:1," + "4:29," + "4:30",
  "19:74," + "45:2," + "4:31," + "4:32",
  "19:75," + "45:3," + "4:33," + "4:34",
  "19:76," + "45:4," + "4:35," + "4:36",
  "19:77," + "45:5," + "5:1," + "5:2",
  "19:78," + "45:6," + "5:3," + "5:4",
  "19:79," + "45:7," + "5:5," + "5:6",
  "19:80," + "45:8," + "5:7," + "5:8",
  "19:81," + "45:9," + "5:9," + "5:10",
  "19:82," + "45:10," + "5:11," + "5:12",
  "19:83," + "45:11," + "5:13," + "5:14",
  "19:84," + "45:12," + "5:15," + "5:16",
  "19:85," + "45:13," + "5:17," + "5:18",
  "19:86," + "45:14," + "5:19," + "5:20",
  "19:87," + "45:15," + "5:21," + "5:22",
  "19:88," + "45:16," + "5:23," + "5:24",
  "19:89," + "42:1," + "5:25",
  "19:90," + "42:2," + "5:26," + "5:27"
];

List<String> date4 = [
  "19:91," + "42:3," + "5:28",
  "19:92," + "42:4," + "5:29," + "5:30",
  "19:93," + "42:5," + "5:31," + "5:32",
  "19:94," + "42:6," + "5:33," + "5:34",
  "19:95," + "42:7," + "6:1," + "6:2",
  "19:96," + "42:8," + "6:3," + "6:4",
  "19:97," + "42:9," + "6:5," + "6:6",
  "19:98," + "42:10," + "6:7," + "6:8",
  "19:99," + "42:11," + "6:9," + "6:10",
  "19:100," + "42:12," + "6:11," + "6:12",
  "19:101," + "42:13," + "6:13," + "6:14",
  "19:102," + "42:14," + "6:15," + "6:16",
  "19:103," + "42:15," + "6:17," + "6:18",
  "19:104," + "42:16," + "6:19," + "6:20",
  "19:105," + "42:17," + "6:21," + "6:22",
  "19:106," + "42:18," + "6:23," + "6:24",
  "19:107," + "42:19," + "7:1," + "7:2",
  "19:108," + "42:20," + "7:3," + "7:4",
  "19:109," + "42:21," + "7:5," + "7:6",
  "19:110," + "42:22," + "7:7," + "7:8",
  "19:111," + "42:23," + "7:9," + "7:10",
  "19:112," + "42:24," + "7:11," + "7:12",
  "19:113," + "46:1," + "7:13," + "7:14",
  "19:114," + "46:2," + "7:15," + "7:16," + "7:17",
  "19:115," + "46:3," + "7:18," + "7:19",
  "19:116," + "46:4," + "7:20," + "7:21",
  "19:117," + "46:5," + "8:1," + "8:2",
  "19:118," + "46:6," + "8:3," + "8:4",
  "19:119," + "46:7," + "9:1," + "9:2",
  "19:119," + "46:8," + "9:3," + "9:4"
];

List<String> date5 = [
  "19:120," + "46:9," + "9:5," + "9:6," + "9:7",
  "19:121," + "46:10," + "9:8," + "9:9",
  "19:122," + "46:11," + "9:10," + "9:11",
  "19:123," + "46:12," + "9:12," + "9:13",
  "19:124," + "46:13," + "9:14," + "9:15",
  "19:125," + "46:14," + "9:16," + "9:17",
  "19:126," + "46:15," + "9:18," + "9:19",
  "19:127," + "46:16," + "9:20," + "9:21",
  "19:128," + "47:1," + "9:22," + "9:23",
  "19:129," + "47:2," + "9:24," + "9:25",
  "19:130," + "47:3," + "9:26," + "9:27",
  "19:131," + "47:4," + "9:28," + "9:29",
  "19:132," + "47:5," + "9:30," + "9:31",
  "19:133," + "47:6," + "13:1," + "13:2",
  "19:134," + "47:7," + "13:3," + "13:4",
  "19:135," + "47:8," + "13:5," + "13:6," + "13:7",
  "19:136," + "47:9," + "13:8," + "13:9," + "13:10",
  "19:137," + "47:10," + "10:1," + "10:2",
  "19:138," + "47:11," + "10:3," + "10:4",
  "19:139," + "47:12," + "10:5," + "10:6",
  "19:140," + "47:13," + "10:7," + "10:8",
  "19:141," + "43:1," + "10:9," + "10:10",
  "19:142," + "43:2," + "10:11," + "10:12",
  "19:143," + "43:3," + "10:13," + "10:14",
  "19:144," + "43:4," + "10:15," + "10:16",
  "19:145," + "43:5," + "10:17," + "10:18",
  "19:146," + "43:6," + "10:19," + "10:20",
  "19:147," + "43:7," + "10:21," + "10:22",
  "19:148," + "43:8," + "10:23," + "10:24",
  "19:149," + "43:9," + "11:1," + "11:2",
  "19:150," + "43:10," + "13:11," + "13:12"
];

List<String> date6 = [
  "20:1," + "43:11," + "13:13," + "13:14," + "13:15",
  "20:2," + "43:12," + "13:16," + "13:17",
  "20:3," + "43:13," + "13:18," + "13:19",
  "20:4," + "43:14," + "13:20," + "13:21," + "13:22",
  "20:5," + "43:15," + "13:23," + "13:24",
  "20:6," + "43:16," + "13:25," + "13:26",
  "20:7," + "43:17," + "13:27," + "13:28," + "13:29",
  "20:8," + "43:18," + "11:3," + "11:4",
  "20:9," + "43:19," + "22:1," + "22:2," + "22:3",
  "20:10," + "43:20," + "22:4," + "22:5," + "22:6",
  "20:11," + "43:21," + "22:7," + "22:8",
  "20:12," + "48:1," + "11:5," + "11:6",
  "20:13," + "48:2," + "11:7," + "11:8",
  "20:14," + "48:3," + "11:9," + "11:10",
  "20:15," + "48:4," + "14:1," + "14:2," + "14:3",
  "20:16," + "48:5," + "14:4," + "14:5",
  "20:17," + "48:6," + "14:6," + "14:7",
  "20:18," + "49:1," + "21:1," + "21:2",
  "20:19," + "49:2," + "21:3," + "21:4," + "21:5",
  "20:20," + "49:3," + "21:6," + "21:7",
  "20:21," + "49:4," + "21:8," + "21:9",
  "20:22," + "49:5," + "21:10," + "21:11," + "21:12",
  "20:23," + "49:6," + "14:8," + "14:9",
  "20:24," + "50:1," + "11:11," + "11:12",
  "20:25," + "50:2," + "11:13," + "11:14",
  "20:26," + "50:3," + "14:10," + "14:11",
  "20:27," + "50:4," + "14:12," + "14:13",
  "20:28," + "51:1," + "14:14," + "14:15",
  "20:29," + "51:2," + "14:16," + "14:17",
  "20:30," + "51:3," + "14:18," + "14:19"
];

List<String> date7 = [
  "20:31," + "51:4," + "11:15," + "11:16",
  "19:1," + "40:1," + "11:17," + "11:18",
  "19:2," + "40:2," + "11:19," + "11:20",
  "19:3," + "40:3," + "11:21," + "11:22",
  "19:4," + "40:4," + "14:20," + "14:21",
  "19:5," + "40:5," + "12:1," + "12:2",
  "19:6," + "40:6," + "12:3," + "12:4",
  "19:7," + "40:7," + "12:5," + "12:6",
  "19:8," + "40:8," + "12:7," + "12:8",
  "19:9," + "40:9," + "31:1",
  "19:10," + "40:10," + "14:22",
  "19:11," + "40:11," + "29:1," + "29:2," + "29:3",
  "19:12," + "40:12," + "12:9," + "12:10",
  "19:13," + "40:13," + "12:11," + "12:12",
  "19:14," + "40:14," + "12:13," + "12:14",
  "19:15," + "40:15," + "32:1," + "32:2," + "32:3," + "32:4",
  "19:16," + "40:16," + "30:1," + "30:2",
  "19:17," + "40:17," + "30:3," + "30:4," + "30:5",
  "19:18," + "40:18," + "30:6," + "30:7",
  "19:19," + "40:19," + "30:8," + "30:9",
  "19:20," + "40:20," + "14:23," + "14:24",
  "19:21," + "40:21," + "14:25," + "14:26",
  "19:22," + "40:22," + "23:1," + "23:2",
  "19:23," + "40:23," + "23:3," + "23:4",
  "19:24," + "40:24," + "23:5," + "23:6",
  "19:25," + "40:25," + "14:27," + "14:28",
  "19:26," + "40:26," + "12:15," + "12:16",
  "19:27," + "40:27," + "23:7," + "23:8",
  "19:28," + "40:28," + "23:9," + "23:10",
  "19:29," + "52:1," + "23:11," + "23:12",
  "19:30," + "52:2," + "23:13," + "23:14"
];

List<String> date8 = [
  "19:31," + "52:3," + "23:15," + "23:16",
  "19:32," + "52:4," + "23:17," + "23:18",
  "19:33," + "52:5," + "23:19," + "23:20",
  "19:34," + "53:1," + "23:21," + "23:22",
  "19:35," + "53:2," + "23:23," + "23:24",
  "19:36," + "53:3," + "23:25," + "23:26",
  "19:37," + "54:1," + "23:27," + "23:28",
  "19:38," + "54:2," + "23:29," + "23:30",
  "19:39," + "54:3," + "23:31," + "23:32",
  "19:40," + "54:4," + "23:33," + "23:34",
  "19:41," + "54:5," + "23:35," + "23:36",
  "19:42," + "54:6," + "23:37," + "23:38",
  "19:43," + "55:1," + "23:39," + "23:40",
  "19:44," + "55:2," + "23:41," + "23:42",
  "19:45," + "55:3," + "23:43," + "23:44",
  "19:46," + "55:4," + "23:45," + "23:46",
  "19:47," + "56:1," + "23:47," + "23:48",
  "19:48," + "56:2," + "23:49," + "23:50",
  "19:49," + "56:3," + "23:51," + "23:52",
  "19:50," + "57:1," + "23:53," + "23:54",
  "19:51," + "44:1," + "23:55," + "23:56",
  "19:52," + "44:2," + "23:57," + "23:58",
  "19:53," + "44:3," + "23:59," + "23:60",
  "19:54," + "44:4," + "23:61," + "23:62",
  "19:55," + "44:5," + "23:63," + "23:64",
  "19:56," + "44:6," + "23:65," + "23:66",
  "19:57," + "44:7," + "12:17",
  "19:58," + "44:8," + "12:18," + "12:19",
  "19:59," + "44:9," + "14:29," + "14:30",
  "19:60," + "44:10," + "14:31," + "14:32",
  "19:61," + "44:11," + "28:1," + "28:2," + "28:3"
];

List<String> date9 = [
  "19:62," + "44:12," + "28:4," + "28:5",
  "19:63," + "44:13," + "28:6," + "28:7",
  "19:64," + "44:14," + "28:8," + "28:9," + "28:10",
  "19:65," + "44:15," + "28:11," + "28:12",
  "19:66," + "44:16," + "28:13," + "28:14",
  "19:67," + "58:1," + "33:1," + "33:2",
  "19:68," + "58:2," + "33:3," + "33:4," + "33:5",
  "19:69," + "58:3," + "33:6," + "33:7",
  "19:70," + "58:4," + "12:20," + "12:21",
  "19:71," + "58:5," + "14:33," + "14:34",
  "19:72," + "58:6," + "36:1," + "36:2," + "36:3",
  "19:73," + "58:7," + "34:1," + "34:2," + "34:3",
  "19:74," + "58:8," + "14:35",
  "19:75," + "58:9," + "35:1," + "35:2," + "35:3",
  "19:76," + "58:10," + "24:1," + "24:2",
  "19:77," + "58:11," + "24:3," + "24:4",
  "19:78," + "58:12," + "24:5," + "24:6",
  "19:79," + "58:13," + "24:11," + "24:12",
  "19:80," + "42:1," + "24:26",
  "19:81," + "42:2," + "24:7," + "24:8",
  "19:82," + "42:3," + "24:9," + "24:10",
  "19:83," + "42:4," + "24:14," + "24:15",
  "19:84," + "42:5," + "24:16," + "24:17",
  "19:85," + "42:6," + "24:18," + "24:19," + "24:20",
  "19:86," + "42:7," + "24:35," + "24:36",
  "19:87," + "42:8," + "24:13",
  "19:88," + "42:9," + "24:23," + "24:24",
  "19:89," + "42:10," + "12:22," + "12:23",
  "19:90," + "42:11," + "14:36,",
  "19:91," + "42:12," + "27:1," + "27:2"
];

List<String> date10 = [
  "19:92," + "42:13," + "27:3," + "27:4",
  "19:93," + "42:14," + "27:5," + "27:6",
  "19:94," + "42:15," + "27:7," + "27:8",
  "19:95," + "42:16," + "27:9," + "27:10",
  "19:96," + "42:17," + "27:11," + "27:12",
  "19:97," + "42:18," + "12:24," + "12:25",
  "19:98," + "42:19," + "14:36," + "26:1",
  "19:99," + "42:20," + "26:2," + "26:3",
  "19:100," + "42:21," + "26:4," + "26:5," + "26:6",
  "19:101," + "42:22," + "26:7," + "26:8",
  "19:102," + "42:23," + "26:9," + "26:10",
  "19:103," + "42:24," + "26:11," + "26:12",
  "19:104," + "59:1," + "26:13," + "26:14",
  "19:105," + "59:2," + "26:15," + "26:16",
  "19:106," + "59:3," + "26:17," + "26:18",
  "19:107," + "59:4," + "26:19," + "26:20",
  "19:108," + "59:5," + "26:21," + "26:22",
  "19:109," + "60:1," + "26:23," + "26:24",
  "19:110," + "60:2," + "26:25," + "26:26",
  "19:111," + "60:3," + "26:27," + "26:28",
  "19:112," + "60:4," + "26:29," + "26:30",
  "19:113," + "60:5," + "26:31," + "26:32",
  "19:114," + "61:1," + "26:33," + "26:34," + "26:35",
  "19:115," + "61:2," + "26:36," + "26:37",
  "19:116," + "61:3," + "26:38," + "26:39",
  "19:117," + "62:1," + "26:40," + "26:41",
  "19:118," + "62:2," + "26:42," + "26:43",
  "19:119," + "62:3," + "26:44," + "26:45",
  "19:119," + "62:4," + "26:46," + "26:47",
  "19:120," + "62:5," + "26:48",
  "19:121," + "63:1," + "24:45"
];

List<String> date11 = [
  "19:122," + "64:1," + "24:46," + "24:47",
  "19:123," + "65:1," + "24:48," + "24:49",
  "19:124," + "43:1," + "14:36," + "24:27",
  "19:125," + "43:2," + "24:28," + "24:29",
  "19:126," + "43:3," + "24:50," + "24:51",
  "19:127," + "43:4," + "24:30," + "24:31",
  "19:128," + "43:5," + "24:32," + "24:33",
  "19:129," + "43:6," + "24:21",
  "19:130," + "43:7," + "24:37," + "24:38",
  "19:131," + "43:8," + "24:39",
  "19:132," + "43:9," + "24:40," + "24:41," + "24:42",
  "19:133," + "43:10," + "24:43," + "24:44",
  "19:134," + "43:11," + "25:1," + "25:2",
  "19:135," + "43:12," + "25:3",
  "19:136," + "43:13," + "25:4," + "25:5",
  "19:137," + "43:14," + "14:36",
  "19:138," + "43:15," + "15:1," + "15:2",
  "19:139," + "43:16," + "15:3," + "15:4",
  "19:140," + "43:17," + "37:1," + "37:2",
  "19:141," + "43:18," + "38:1," + "38:2," + "38:3",
  "19:142," + "43:19," + "38:4," + "38:5," + "38:6",
  "19:143," + "43:20," + "38:7," + "38:8",
  "19:144," + "43:21," + "38:9," + "38:10",
  "19:145," + "66:1," + "38:11," + "38:12",
  "19:146," + "66:2," + "38:13," + "38:14",
  "19:147," + "66:3," + "15:5," + "15:6",
  "19:148," + "66:4," + "17:1," + "17:2",
  "19:149," + "66:5," + "17:3," + "17:4",
  "19:150," + "66:6," + "17:5," + "17:6",
  "20:1," + "66:7," + "17:7," + "17:8"
];

List<String> date12 = [
  "20:2," + "66:8," + "17:9," + "17:10",
  "20:3," + "66:9," + "15:7," + "15:8",
  "20:4," + "66:10," + "15:9," + "15:10",
  "20:5," + "66:11," + "16:1," + "16:2," + "16:3",
  "20:6," + "66:12," + "16:4," + "16:5",
  "20:7," + "66:13," + "16:6," + "16:7",
  "20:8," + "66:14," + "16:8," + "16:9",
  "20:9," + "66:15," + "16:10," + "16:11",
  "20:10," + "66:16," + "16:12," + "16:13",
  "20:11," + "66:17," + "39:1," + "39:2",
  "20:12," + "66:18," + "39:3," + "39:4",
  "20:13," + "66:19," + "18:1," + "18:2",
  "20:14," + "66:20," + "18:3," + "18:4," + "18:5",
  "20:15," + "66:21," + "18:6," + "18:7",
  "20:16," + "66:22," + "18:8," + "18:9," + "18:10",
  "20:17," + "58:11," + "18:11," + "18:12",
  "20:18," + "58:12," + "18:13," + "18:14",
  "20:19," + "44:2," + "18:15," + "18:16," + "18:17",
  "20:20," + "46:11," + "18:18," + "18:19",
  "20:21," + "46:12," + "18:20," + "18:21",
  "20:22," + "46:13," + "18:22," + "18:23," + "18:24",
  "20:23," + "46:14," + "18:25," + "18:26",
  "20:24," + "46:15," + "18:27," + "18:28",
  "20:25," + "42:1," + "18:29," + "18:30," + "18:31",
  "20:26," + "42:2," + "18:32," + "18:33",
  "20:27," + "42:3," + "18:34," + "18:35",
  "20:28," + "42:4," + "18:36," + "18:37",
  "20:29," + "50:1," + "18:38," + "18:39",
  "20:30," + "50:2," + "18:40," + "18:41",
  "20:31," + "50:3," + "18:42",
  "19:91," + "50:4," + "19:111"
];

List<List<String>> saveAllBibleTodaysSentence = [
  date1,
  date2,
  date3,
  date4,
  date5,
  date6,
  date7,
  date8,
  date9,
  date10,
  date11,
  date12
];

class Common {}
