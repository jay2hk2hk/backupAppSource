import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:bibleapp/util/common_value.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/services.dart';

double fontOfContent = 60.0;//px
GlobalKey globalKey = new GlobalKey(debugLabel: 'btm_app_bar');
int displayListNum = 0;

void main() {
    runApp(SearchPage(globalKey));
  }

class SearchPage extends StatefulWidget {
  @override
  SearchPage(GlobalKey key) {
    globalKey = key;
  }

  _SearchPageState createState() => new _SearchPageState();
}
  
class _SearchPageState extends State<SearchPage>{
  static int page = 0; //0 = seach page 1 = content page
  static ItemScrollController _scrollController = ItemScrollController();//the scroll controller of jump to
  double sizeOfIcon = 50.0;
  
@override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }
@override
  void dispose() {
    super.dispose();
    BackButtonInterceptor.remove(myInterceptor);
  }
  bool myInterceptor(bool stopDefaultButtonEvent) {
    //print("BACK BUTTON!"); // Do some stuff.
    if(page==1)
    {
      setState(() {
        page=0;
      });
    }
    else
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return true;
  }

  Widget getSearch(BuildContext context)
  {
    return /*MaterialApp(
      title: FlutterI18n.translate(context, "appName"),
      home: */Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, "bottomBarSearch")
          ,style: TextStyle(/*color: buttonTextColor,*/fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true),),),
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
                          color: backgroundColor,
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
                        child: new Wrap(
                          spacing: ScreenUtil().setSp(20.0, allowFontScalingSelf: true), // gap between adjacent chips
                          runSpacing: ScreenUtil().setSp(20.0, allowFontScalingSelf: true), // gap between lines
                          children: listOfSearchButton(context),
                        ),
                      ),
                      //new box style
                      new Container(height: 5.0),
                      
                    ],
                  ),
                ],
              ),
              
          ),
          
          
        ),
      //),
    );
  }

  Widget getSearchResult(BuildContext context)
  {
    return /*MaterialApp(
      title: FlutterI18n.translate(context, "appName"),
      home:*/Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, /*color: Colors.black*/size: ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),),
          onPressed: () => {
            setState(() {
                page = 0;
              })
          },
        ), 
        title: Text(FlutterI18n.translate(context, "searchButtonList.$displayListNum"),style:new TextStyle(fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true)
        ,color:buttonTextColor
        ),),
      ),
      body: FutureBuilder<List>(
          future: loadQueryToList(context),
          initialData: List(),
          builder: (context, snapshot) {
          return new ScrollablePositionedList.separated(
          itemScrollController: _scrollController,
          itemCount: snapshot.data==null ? 0 : snapshot.data.length,
          separatorBuilder: (context, index) =>
              Divider(height: 1.0, color: splashColor),
                  itemBuilder: (context, index) {
                  String temp = snapshot.data.length!=0 ? snapshot.data[index].toString() : "";
                  String titleButtonText = snapshot.data.length!=0 ? temp.substring(0,temp.indexOf(':')) : "";
                  String tempTitle = snapshot.data.length!=0 ? temp.substring(temp.indexOf(':')+1,temp.indexOf('+')) : "";
                  String contentText = snapshot.data.length!=0 ? temp.substring(temp.indexOf('+')+1) : "";
                return Container(
                    /*color: _selectedIndex != null && _selectedIndex == index
                          ? Colors.red
                          : Colors.white,*/
                    
                    child:ListTile(
                      title: RaisedButton(
                        color:bottomNavigationColor,
                        textColor: buttonTextColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              child: Text(titleButtonText+":"+tempTitle
                              ,style:new TextStyle(fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true)
                              ,color: buttonTextColor
                              ),),
                                  onPressed: (){
                                    if(prefs!=null)
                                    {
                                        prefs.setString(sharePrefTitleId,saveAllBibleSentence[displayListNum][index].split(':')[0]);
                                        prefs.setString(sharePrefTitleNum, titleButtonText.split(' ')[1]);
                                        List<String> temp = tempTitle.split('-');
                                        prefs.setString(sharePrefContentNum, temp[0]);
                                    }
                                    //Navigator.pop(context);
                                    final BottomNavigationBar navigationBar = globalKey.currentWidget;
                                    navigationBar.onTap(1);
                                  },
                                  //color: raisedButtonColor,
                                  //textColor: buttonTextColor,
                                  //padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                                  //splashColor: splashColor,
                            ),
                    subtitle: Text(snapshot.data.length == 0 ? "" : contentText
                      ,style: new TextStyle(
                      fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true),
                      //color:fontTextColor
                      ),),
                    onTap: () => null,
                    ),
                  );
            
            
                
            
          }, //itemBuilder
        );
      },
          ),
    //)
    );
  }

  @override
  Widget build(BuildContext context) {
    //ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return /*MaterialApp(
      theme:prefs.getInt(sharePrefLightDark) ==0 ? ThemeData.light(): ThemeData.dark(),
      home: */page == 0 ? getSearch(context) : getSearchResult(context);
    //);
    
  }

  List<Widget>listOfSearchButton(BuildContext context)
  {
    List<Widget> temp = new List<Widget>();
    for(int i=0;i<saveAllBibleSentence.length;i++)
    {
      temp.add(
          RaisedButton(
            color:bottomNavigationColor,
            textColor: buttonTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          child: Text(FlutterI18n.translate(context, "searchButtonList.$i"),style:new TextStyle(fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true)
          ,color: buttonTextColor),),
              onPressed: (){
                displayListNum = i;
                setState(() {
                  page = 1;
                });
                /*Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchedList()),
                  );*/
              },
              //color: raisedButtonColor,
              //textColor: buttonTextColor,
              //padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
              //splashColor: splashColor,
        ),
      );
    }
    return temp;
  }

  Future<List<String>>loadQueryToList(BuildContext context)async
  {
    //int titleNum = new Random().nextInt(saveAllBibleSentence.length-1);
    //int contentNum = new Random().nextInt(saveAllBibleSentence[titleNum].length-1);
    //String temp = saveAllBibleSentence[titleNum][contentNum];
    
    List<String> returnList = new List<String>();
    for(int y=0;y<saveAllBibleSentence[displayListNum].length;y++)
    {
      String temp = saveAllBibleSentence[displayListNum][y];
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
      returnList.add(tempDisplayContent);

    }
    return returnList;
  }

}


/*
class SearchedList extends StatefulWidget {
  @override
  _SearchedListState createState() => new _SearchedListState();

}
class _SearchedListState extends State<SearchedList>
{
  static ItemScrollController _scrollController = ItemScrollController();//the scroll controller of jump to
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "searchButtonList.$displayListNum"),style:new TextStyle(fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true)
        ,color:buttonTextColor),),
      ),
      body: FutureBuilder<List>(
          future: loadQueryToList(context),
          initialData: List(),
          builder: (context, snapshot) {
          return new ScrollablePositionedList.separated(
          itemScrollController: _scrollController,
          itemCount: snapshot.data==null ? 0 : snapshot.data.length,
          separatorBuilder: (context, index) =>
              Divider(height: 1.0, color: splashColor),
                  itemBuilder: (context, index) {
                  String temp = snapshot.data.length!=0 ? snapshot.data[index].toString() : "";
                  String titleButtonText = snapshot.data.length!=0 ? temp.substring(0,temp.indexOf(':')) : "";
                  String tempTitle = snapshot.data.length!=0 ? temp.substring(temp.indexOf(':')+1,temp.indexOf('+')) : "";
                  String contentText = snapshot.data.length!=0 ? temp.substring(temp.indexOf('+')+1) : "";
                return Container(
                    /*color: _selectedIndex != null && _selectedIndex == index
                          ? Colors.red
                          : Colors.white,*/
                    
                    child:ListTile(
                      title: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              child: Text(titleButtonText+":"+tempTitle
                              ,style:new TextStyle(fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true)
                              ,color: buttonTextColor),),
                                  onPressed: (){
                                    if(prefs!=null)
                                    {
                                        prefs.setString(sharePrefTitleId,saveAllBibleSentence[displayListNum][index].split(':')[0]);
                                        prefs.setString(sharePrefTitleNum, titleButtonText.split(' ')[1]);
                                        List<String> temp = tempTitle.split('-');
                                        prefs.setString(sharePrefContentNum, temp[0]);
                                    }
                                    Navigator.pop(context);
                                    final BottomNavigationBar navigationBar = globalKey.currentWidget;
                                    navigationBar.onTap(1);
                                  },
                                  color: raisedButtonColor,
                                  textColor: buttonTextColor,
                                  //padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                                  splashColor: splashColor,
                            ),
                    subtitle: Text(snapshot.data.length == 0 ? "" : contentText
                      ,style: new TextStyle(
                      fontSize: ScreenUtil().setSp(fontOfContent, allowFontScalingSelf: true),
                      color:fontTextColor),),
                    onTap: () => null,
                    ),
                  );
            
            
                
            
          }, //itemBuilder
        );
      },
          ),
    );
  }


  Future<List<String>>loadQueryToList(BuildContext context)async
  {
    //int titleNum = new Random().nextInt(saveAllBibleSentence.length-1);
    //int contentNum = new Random().nextInt(saveAllBibleSentence[titleNum].length-1);
    //String temp = saveAllBibleSentence[titleNum][contentNum];
    
    List<String> returnList = new List<String>();
    for(int y=0;y<saveAllBibleSentence[displayListNum].length;y++)
    {
      String temp = saveAllBibleSentence[displayListNum][y];
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
      returnList.add(tempDisplayContent);

    }
    return returnList;
  }


}

*/
