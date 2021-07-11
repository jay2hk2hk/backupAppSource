import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:bibleapp/util/common_value.dart';
import 'package:bibleapp/page/home_page.dart';
import 'package:bibleapp/model/bible_notes.dart';
import 'package:bibleapp/util/sql_helper.dart';
//import 'package:zefyr/zefyr.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import '../main.dart';

double fontOfContent = 60.0; //px
double fontOfTitleButton = 40.0;
double rowHeight = 30.0;
GlobalKey globalKey = new GlobalKey(debugLabel: 'btm_app_bar');
final dateFormat = new DateFormat('yyyy-MM-dd');
DateTime eventNoteTitle = DateTime.parse(dateFormat.format(DateTime.now()));
final dbHelper = SQLHelper.instance;
BibleNotes editCurrentNotes = new BibleNotes();

void main() => runApp(NotesPage(globalKey));

class NotesPage extends StatefulWidget {
  @override
  NotesPage(GlobalKey key) {
    globalKey = key;
  }
  _NotesPageState createState() => new _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List _selectedEvents = new List();
  CalendarController _calendarController;
  static DateTime _selectedDay =
      DateTime.parse(dateFormat.format(DateTime.now()));
  static int page = 0; //0 = cal 1 = notes list, 2 = edit notes
  static final TextEditingController _controller = new TextEditingController();
  static final TextEditingController _controller2 = new TextEditingController();

  //stt
  final SpeechToText speech = SpeechToText();
  bool _hasSpeech = false;
  String _currentLocaleId = "";
  String lastWords = "";

  double sizeOfIcon = 50.0;

  void errorListener(SpeechRecognitionError error) {
    print("Received error status: $error, listening: ${speech.isListening}");
    //Navigator.pop(context);
    stopListening();
    //setState(() {});
  }

  void statusListener(String status) {
    print(
        "Received listener status: $status, listening: ${speech.isListening}");
    //if(!speech.isListening)
    //Navigator.pop(context);
    //setState(() {});
  }

  Future<void> initSpeechState() async {
    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);
    if (hasSpeech) {
      //_localeNames = await speech.locales();
      Future.delayed(Duration(milliseconds: 200), () async {
        var systemLocale = await speech.systemLocale();
        _currentLocaleId = systemLocale.localeId;
      });
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  void startListening() {
    lastWords = "";
    //lastError = "";
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 5),
        localeId: _currentLocaleId,
        //onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        partialResults: true);
    //setState(() {});
  }

  void stopListening() {
    speech.stop();
    //setState(() {});
  }

  void cancelListening() {
    speech.cancel();
    //setState(() {});
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      //lastWords = "${result.recognizedWords} - ${result.finalResult}";
      if (result.finalResult) {
        lastWords = result.recognizedWords;
        print("lastWords=" + lastWords);
        _controller2.text += lastWords;
        //Navigator.pop(context);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    initSpeechState();
    //_controller2.selection = TextSelection.fromPosition(
    //    TextPosition(offset: _controller2.text.length));

    //_events = {
    /*_selectedDay: [[1,'Event A7'], [2,'Event B7']/*, 'Event C7', 'Event D7'*/],
      _selectedDay.subtract(Duration(days: 30)): [[3,'Event A0'], [4,'Event B0']],
      
      _selectedDay.subtract(Duration(days: 30)): ['Event A0', 'Event B0', 'Event C0'],
      _selectedDay.subtract(Duration(days: 27)): ['Event A1'],
      _selectedDay.subtract(Duration(days: 20)): ['Event A2', 'Event B2', 'Event C2', 'Event D2'],
      _selectedDay.subtract(Duration(days: 16)): ['Event A3', 'Event B3'],
      _selectedDay.subtract(Duration(days: 10)): ['Event A4', 'Event B4', 'Event C4'],
      _selectedDay.subtract(Duration(days: 4)): ['Event A5', 'Event B5', 'Event C5'],
      _selectedDay.subtract(Duration(days: 2)): ['Event A6', 'Event B6'],
      
      _selectedDay.add(Duration(days: 1)): ['Event A8', 'Event B8', 'Event C8', 'Event D8'],
      _selectedDay.add(Duration(days: 3)): Set.from(['Event A9', 'Event A9', 'Event B9']).toList(),
      _selectedDay.add(Duration(days: 7)): ['Event A10', 'Event B10', 'Event C10'],
      _selectedDay.add(Duration(days: 11)): ['Event A11', 'Event B11'],
      _selectedDay.add(Duration(days: 17)): ['Event A12', 'Event B12', 'Event C12', 'Event D12'],
      _selectedDay.add(Duration(days: 22)): ['Event A13', 'Event B13'],
      _selectedDay.add(Duration(days: 26)): ['Event A14', 'Event B14', 'Event C14'],
      */
    //};
    //setInitEventInCal();
    //_events = setInitEventInCal();
    //getTodaysMonthEvent();
    //_selectedEvents = _events[_selectedDay] ?? [];
    _calendarController = CalendarController();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
    BackButtonInterceptor.remove(myInterceptor);
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    //print("BACK BUTTON!"); // Do some stuff.
    if (page != 0) {
      if (page == 2) {
        if (_controller.text != "" || _controller2.text != "") {
          _saveNote();
        } else {
          setState(() {
            page = 1;
          });
        }
      } else {
        setState(() {
          page -= 1;
        });
      }
    } else
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return true;
  }

  void setInitEventInCal(
      DateTime firstDayDateTime, DateTime lastDayDateTime) async {
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

  Future<List<dynamic>> getMonthEvent(DateTime firstDayDateTime,
      DateTime lastDayDateTime /*, DateTime dateSelect*/) async {
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
    return tempEvents[eventNoteTitle] ?? [];
  }

  Future<List> getTodaysMonthEvent() async {
    var now = eventNoteTitle;

    var firstDayDateTime = new DateTime(now.year, now.month, 1);
    // Find the last day of the month.
    var lastDayDateTime = (now.month < 12)
        ? new DateTime(now.year, now.month + 1, 0)
        : new DateTime(now.year + 1, 1, 0);
    //_events = getMonthEvent(firstDayDateTime,lastDayDateTime);

    //List<dynamic> tempListForEachEvent = new List<dynamic>();
    /*Map<DateTime,List<dynamic>> tempMap = Map<DateTime,List<dynamic>>();
      DateTime tempDateTime;
      for(BibleNotes bn in tempList)
      {
        //print(_events[DateTime.parse(bn.date)]);
        
        if(tempDateTime!=DateTime.parse(dateFormat.format(DateTime.parse(bn.date))))
          tempDateTime = DateTime.parse(dateFormat.format(DateTime.parse(bn.date)));
        if(tempDateTime==DateTime.parse(dateFormat.format(DateTime.parse(bn.date))))
          tempListForEachEvent.add([bn.id,bn.title,bn.content,bn.date]);

          _events[DateTime.parse(bn.date)].add([bn.id,bn.title,bn.content,bn.date]);
        
      }*/

    //Map<DateTime,List<dynamic>> tempMap = {DateTime.now():[]};
    //tempList.forEach((notes)=>_events[DateTime.parse(notes.date)].add([[notes.id,notes.title,notes.content,notes.date]]));

    //_events.addAll(tempMap);
    //print(_events);
    //_selectedEvents = _events[eventNoteTitle] ?? [];
    //print(eventNoteTitle);
    //return _selectedEvents;
    return getMonthEvent(firstDayDateTime, lastDayDateTime /*,eventNoteTitle*/);
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    print('CALLBACK: _onDaySelected');
    setState(() {
      eventNoteTitle = DateTime.parse(dateFormat.format(day));
      _selectedEvents = events;
      page = 1;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged ' + first.toString());
    setInitEventInCal(first, last);
    setState(() {
      //_events = getMonthEvent(first,last);
      //print(_events);
      //print(_selectedDay);
      //var now = eventNoteTitle;
      //var firstDayDateTime = new DateTime(now.year, now.month , 1);
      // Find the last day of the month.
      //var lastDayDateTime = (now.month < 12) ? new DateTime(now.year, now.month + 1, 0) : new DateTime(now.year + 1, 1, 0);

      eventNoteTitle = DateTime.parse(dateFormat.format(first));
      _selectedEvents = events[eventNoteTitle] ?? [];
      //_selectedEvents = getMonthEvent(firstDayDateTime,lastDayDateTime,_selectedDay);
    });
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) async {
    print('CALLBACK: _onCalendarCreated');
    setState(() {
      //_events = getMonthEvent(first,last);
      //print(_events);

      eventNoteTitle = DateTime.parse(dateFormat.format(DateTime.now()));
      _selectedEvents = events[eventNoteTitle] ?? [];
    });
  }

  Widget _buildEventList(List<dynamic> selectedEvents) {
    List<Widget> tempReturnList = selectedEvents
        .map((event) => Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                child: Text(
                  /*event[0].toString() + ' ' +*/ event[1].toString(),
                  style: new TextStyle(
                      fontSize: ScreenUtil()
                          .setSp(fontOfContent, allowFontScalingSelf: true),
                      color: buttonTextColor),
                ),
                onPressed: () {
                  setState(() {
                    editCurrentNotes = BibleNotes(
                        id: int.parse(event[0].toString()),
                        title: event[1].toString(),
                        content: event[2].toString(),
                        date: event[3].toString());
                    _controller.text =
                        editCurrentNotes != null ? editCurrentNotes.title : "";
                    _controller2.text = editCurrentNotes != null
                        ? editCurrentNotes.content
                        : "";
                    page = 2;
                  });
                  //final BottomNavigationBar navigationBar = globalKey.currentWidget;
                  //navigationBar.onTap(1);
                  //editCurrentNotes = BibleNotes(id:int.parse(event[0].toString()),title: event[1].toString(),content: event[2].toString(),date: event[3].toString());
                  /*Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => NotesEditor()),
                                      );*/
                },
                color: raisedButtonColor,
                textColor: buttonTextColor,
                //padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                splashColor: splashColor,
              ),
            ))
        .toList();
    tempReturnList.add(
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                FontAwesomeIcons.plus, /*color: Colors.black*/
              ),
              Text(
                " " + FlutterI18n.translate(context, "addNote"),
                style: new TextStyle(
                    fontSize: ScreenUtil()
                        .setSp(fontOfContent, allowFontScalingSelf: true),
                    color: buttonTextColor),
              ),
            ],
          ),
          onPressed: () {
            setState(() {
              editCurrentNotes = new BibleNotes();
              _controller.text =
                  ""; //editCurrentNotes != null ? editCurrentNotes.title : "";
              _controller2.text =
                  ""; //editCurrentNotes != null ? editCurrentNotes.content : "";
              page = 2;
            });
            //final BottomNavigationBar navigationBar = globalKey.currentWidget;
            //navigationBar.onTap(1);

            /*Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => NotesEditor()),
                                      );*/
          },
          color: raisedButtonColor,
          textColor: buttonTextColor,
          //padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
          splashColor: splashColor,
        ),
      ),
    );
    return ListView(
      children: tempReturnList,
    );
  }

  List<Widget> getTableCalendar() {
    List<Widget> tempList = new List<Widget>();

    tempList.add(
      TableCalendar(
        locale: prefs.getString(sharePrefDisplayLanguage),
        calendarController: _calendarController,
        rowHeight: ScreenUtil().setSp(110.0, allowFontScalingSelf: true),
        events: events,
        //holidays: _holidays,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        formatAnimation: FormatAnimation.slide,
        //availableGestures: AvailableGestures.none,

        calendarStyle: CalendarStyle(
          weekdayStyle: TextStyle().copyWith(
              fontSize: ScreenUtil()
                  .setSp(fontOfContent, allowFontScalingSelf: true)),
          weekendStyle: TextStyle().copyWith(
              fontSize: ScreenUtil()
                  .setSp(fontOfContent, allowFontScalingSelf: true)),
          selectedStyle: TextStyle().copyWith(
              fontSize: ScreenUtil()
                  .setSp(fontOfContent, allowFontScalingSelf: true)),
          selectedColor: bottomNavigationColor,
          todayColor: Colors.blue[200],
          //markersColor: Colors.brown[700],
          outsideDaysVisible: false,
          //contentPadding: EdgeInsets.all(10.0),
          //weekdayStyle: new TextStyle(
          //fontSize: ScreenUtil().setSp(fontOfTitleButton, allowFontScalingSelf: true),),
          //weekendStyle: new TextStyle(
          //fontSize: ScreenUtil().setSp(fontOfTitleButton, allowFontScalingSelf: true),),
        ),
        headerStyle: HeaderStyle(
          centerHeaderTitle: true,
          formatButtonVisible: false,
          titleTextStyle: TextStyle().copyWith(
              fontSize: ScreenUtil()
                  .setSp(fontOfContent, allowFontScalingSelf: true)),
          formatButtonTextStyle: TextStyle().copyWith(
              color: buttonTextColor,
              fontSize: ScreenUtil()
                  .setSp(fontOfContent, allowFontScalingSelf: true)),
          formatButtonDecoration: BoxDecoration(
            color: bottomNavigationColor,
            //border: Border.all(width: 0.8),
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle().copyWith(
              fontSize: ScreenUtil()
                  .setSp(fontOfContent, allowFontScalingSelf: true)),
          weekendStyle: TextStyle().copyWith(
              color: weekEndTextColor,
              fontSize: ScreenUtil()
                  .setSp(fontOfContent, allowFontScalingSelf: true)),
        ),

        onDaySelected: _onDaySelected,
        onVisibleDaysChanged: _onVisibleDaysChanged,
        onCalendarCreated: _onCalendarCreated,
      ),
    );
    /*tempList.add(
      SizedBox(height: 8.0),        
    );
    tempList.add(
      Expanded(child: FutureBuilder<List>(
                future: getTodaysMonthEvent(),
                initialData: List(),
                builder: (context, snapshot)
                {
                  return _buildEventList(snapshot.data);
                }
                )),
                );*/

    return tempList;
  }

  Widget getCalPage() {
    return /*MaterialApp(
      title: FlutterI18n.translate(context, "appName"),
      home: */
        Scaffold(
      appBar: AppBar(
        title: Text(
          FlutterI18n.translate(context, "bottomBarNotes"),
          style: TextStyle(
            color: buttonTextColor,
            fontSize: ScreenUtil()
                .setSp(fontOfContent - 5, allowFontScalingSelf: true),
          ),
        ),
      ),
      body: Center(
        child: new Container(
          child: Column(
            children: getTableCalendar(),
          ),
        ),
      ),
      //),
    );
  }

  void _saveNote() async {
    editCurrentNotes = BibleNotes(
        id: editCurrentNotes.id,
        title: _controller.text,
        content: _controller2.text,
        date: eventNoteTitle.toString());
    int id = await dbHelper.insertNotes(editCurrentNotes);
    editCurrentNotes = BibleNotes(
        id: id,
        title: _controller.text,
        content: _controller2.text,
        date: eventNoteTitle.toString());
    setState(() {
      page = 1;
    });
  }

  Widget getNotesPage(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          //resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                /*color: Colors.black*/ size:
                    ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),
              ),
              onPressed: () {
                if (_controller.text != "" || _controller2.text != "") {
                  _saveNote();
                } else {
                  setState(() {
                    page = 1;
                  });
                }
              },
            ),
            title: Text(
              dateFormat.format(eventNoteTitle).toString(),
              style: new TextStyle(
                  fontSize: ScreenUtil()
                      .setSp(fontOfContent - 5, allowFontScalingSelf: true),
                  color: buttonTextColor),
            ),
            actions: <Widget>[
              IconButton(
                  icon: Icon(
                    FontAwesomeIcons.save,
                    color: iconColor,
                    size: ScreenUtil()
                        .setSp(sizeOfIcon, allowFontScalingSelf: true),
                  ),
                  onPressed: () {
                    _saveNote();
                  }),
              SizedBox(
                width: ScreenUtil().setSp(5, allowFontScalingSelf: true),
              ),
              IconButton(
                  icon: Icon(
                    FontAwesomeIcons.trash,
                    color: iconColor,
                    size: ScreenUtil()
                        .setSp(sizeOfIcon, allowFontScalingSelf: true),
                  ),
                  onPressed: () //async
                      {
                    _showConfirm(context, "");
                  }),
              /*SizedBox(width:ScreenUtil().setSp(5, allowFontScalingSelf: true),),
          IconButton(icon: Icon(FontAwesomeIcons.microphone,color: iconColor,size: ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),), onPressed: ()
          {
            if(_hasSpeech || !speech.isListening)
            {
              startListening();
              //showDialog(
              //barrierDismissible: false,
              //context: context,
              //builder: (_) {
              //  return MyDialog();
              //});
            }
          }
          ),*/
              SizedBox(
                width: ScreenUtil().setSp(5, allowFontScalingSelf: true),
              ),
            ],
          ),
          body: Container(
            margin: new EdgeInsets.all(4.0),
            child: SingleChildScrollView(
                // new line
                child: Column(
              children: <Widget>[
                TextFormField(
                  style: TextStyle(
                    fontSize: ScreenUtil()
                        .setSp(fontOfContent, allowFontScalingSelf: true),
                  ),
                  controller: _controller,
                  decoration: InputDecoration(
                      labelText: FlutterI18n.translate(context, "noteTitle")),
                ),
                TextFormField(
                  style: TextStyle(
                    fontSize: ScreenUtil()
                        .setSp(fontOfContent, allowFontScalingSelf: true),
                  ),
                  controller: _controller2,
                  onChanged: (text) {
                    //TextSelection previousSelection = _controller2.selection;
                    //_controller2.text = text;
                    //_controller2.selection = previousSelection;
                  },
                  maxLines: 10,
                  minLines: 3,
                  decoration: InputDecoration(
                      labelText: FlutterI18n.translate(context, "noteContent")),
                ),
              ],
            )),
          ),
        ));
  }

  Widget getNotesListPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            /*color: Colors.black*/ size:
                ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),
          ),
          onPressed: () {
            setState(() {
              page = 0;
            });
          },
        ),
        title: Text(
          dateFormat.format(eventNoteTitle).toString(),
          style: new TextStyle(
              fontSize:
                  ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true),
              color: buttonTextColor),
        ),
        /*actions: <Widget>[
          IconButton(icon: Icon(FontAwesomeIcons.save,color: iconColor,), onPressed: () async
          {
              editCurrentNotes = BibleNotes(id:editCurrentNotes.id,title: _controller.text,content: _controller2.text,date: eventNoteTitle.toString());
              int id = await dbHelper.insertNotes(editCurrentNotes);
              editCurrentNotes = BibleNotes(id:id,title: _controller.text,content: _controller2.text,date: eventNoteTitle.toString());
              setState(() {
                page = 0;
              });
          }),
          IconButton(icon: Icon(FontAwesomeIcons.trash,color: iconColor,), onPressed: () //async
          {
            _showConfirm(context,"");
              
          }),
        ],*/
      ),
      body: Container(
        margin: new EdgeInsets.all(4.0),
        child: Column(
          children: <Widget>[
            Expanded(
                child: FutureBuilder<List>(
                    future: getTodaysMonthEvent(),
                    initialData: List(),
                    builder: (context, snapshot) {
                      return _buildEventList(snapshot.data);
                    })),
          ],
        ),
      ),
    );
  }

  void _showConfirm(BuildContext _context, String text) {
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
                await dbHelper.deleteNote(editCurrentNotes.id);
                Navigator.of(context).pop();
                setState(() {
                  page = 1;
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    Widget tempReturn;
    if (page == 0)
      tempReturn = getCalPage();
    else if (page == 1)
      tempReturn = getNotesListPage(context);
    else if (page == 2) tempReturn = getNotesPage(context);

    return /*MaterialApp(
      theme:prefs.getInt(sharePrefLightDark) ==0 ? ThemeData.light(): ThemeData.dark(),
      home: */
        tempReturn;
    //);
  }
}

/*
class NotesEditor extends StatefulWidget {
  @override
  _NotesEditorState createState() => new _NotesEditorState();

}
class _NotesEditorState extends State<NotesEditor>
{
  //final TextEditingController _controller = new TextEditingController();
  //final TextEditingController _controller2 = new TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _controller.text = editCurrentNotes != null ? editCurrentNotes.title : "";
    _controller2.text = editCurrentNotes != null ? editCurrentNotes.content : "";
    return Scaffold(
      appBar: AppBar(
        title: Text(dateFormat.format(eventNoteTitle).toString(),style:new TextStyle(fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true)
        ,color:buttonTextColor),),
        actions: <Widget>[
          IconButton(icon: Icon(FontAwesomeIcons.save,color: iconColor,), onPressed: () async
          {
              editCurrentNotes = BibleNotes(id:editCurrentNotes.id,title: _controller.text,content: _controller2.text,date: eventNoteTitle.toString());
              int id = await dbHelper.insertNotes(editCurrentNotes);
              editCurrentNotes = BibleNotes(id:id,title: _controller.text,content: _controller2.text,date: eventNoteTitle.toString());
          }),
        ],
      ),
      body: Container(
        margin: new EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter your username'
              ),
            ),
            TextFormField(
              controller: _controller2,
              maxLines: 15,
              minLines: 10,
              decoration: InputDecoration(
                labelText: 'Enter your notes'
              ),
            ),

          ],
        ),
      ),
    );
  }


}
*/

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
        shape: RoundedRectangleBorder(
            //Alert Dialog with Rounded corners in flutter
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: Text(
          FlutterI18n.translate(context, "pleaseSelect"),
          textAlign: TextAlign.center,
          style: TextStyle(
              /*color: iconAlertDialogColor,*/ fontWeight: FontWeight.bold),
        ),
        content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Listening...'),
            ]),
      ),
    );
  }
}
