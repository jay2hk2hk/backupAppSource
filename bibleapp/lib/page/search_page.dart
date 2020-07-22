import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:bibleapp/util/common_value.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:html_unescape/html_unescape.dart';
import 'dart:async';

import '../main.dart';

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
  static var bibleTitleTotalNum = [50,40,27,36,34,24,21,4,31,24,22,25,29
                ,36,10,13,10,42,150,31,12,8,66,52,5,48
                ,12,14,3,9,1,4,7,3,3,3,2,14,4
                ,28,16,24,21,28,16,16,13,6
                ,6,4,4,5,3,6,4,3,1
                ,13,5,5,3,5,1,1,1,22];
  List<List<List<String>>> searchList = new List<List<List<String>>>();  
  static final TextEditingController _controller = new TextEditingController();    
  List<String> searchResult = new List<String>();
  var unescape = new HtmlUnescape();//decode th html chinese word

  
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
    searchList = new List<List<List<String>>>(); 
    List<List<String>> tempSearchList = new List<List<String>>();
    int i1 = 1;
    int j1 = 1;
    for(int i=0;i<bibleTitleTotalNum.length;i++)
    {
      tempSearchList = new List<List<String>>();
      i1 = i+1;
      for(int j=0; j<bibleTitleTotalNum[i];j++)
      {
        j1 = j+1;
        List<String> tempList = unescape.convert(FlutterI18n.translate(context, "bible.$i1.$j1.content")).split("=.=");
        tempSearchList.add(tempList);
      }
      searchList.add(tempSearchList);
        
    }
    return /*MaterialApp(
      title: FlutterI18n.translate(context, "appName"),
      home: */
      GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: TextFormField(
                style:TextStyle(fontSize: ScreenUtil().setSp(fontOfContent-10, allowFontScalingSelf: true),),
                controller: _controller,
                decoration: InputDecoration(
                  labelText: FlutterI18n.translate(context, "searchInput")
                ),
              ),
            //Text(FlutterI18n.translate(context, "bottomBarSearch"),
            //style: TextStyle(fontSize: ScreenUtil().setSp(fontOfContent-5, allowFontScalingSelf: true),),),
            actions: <Widget>[
              
              IconButton(icon: Icon(FontAwesomeIcons.search,color: iconColor,size: ScreenUtil().setSp(sizeOfIcon, allowFontScalingSelf: true),), onPressed: ()
              {
                if(_controller.text.trim()!="")
                {
                  searchResult = new List<String>();
                  for(int x=0;x<searchList.length;x++)
                  {
                    for(int y=0;y<searchList[x].length;y++)
                    {
                      for(int z=0;z<searchList[x][y].length;z++)
                      {
                        if(searchList[x][y][z].contains(_controller.text))
                        {
                          searchResult.add((x+1).toString()+":"+(y+1).toString()+":"+(z+1).toString());
                        }
                      }
                    }
                  }
                  displayListNum = -1;
                  setState(() {
                    page = 1;
                  });
                }
                
              }),
              SizedBox(width:ScreenUtil().setSp(10, allowFontScalingSelf: true),),
            ],
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
      ),
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
        title: displayListNum>=0 ? Text(FlutterI18n.translate(context, "searchButtonList.$displayListNum"),style:new TextStyle(fontSize: ScreenUtil().setSp(fontOfContent-5, allowFontScalingSelf: true)
        ,color:buttonTextColor
        ),) : 
        Text(_controller.text,style:new TextStyle(fontSize: ScreenUtil().setSp(fontOfContent-5, allowFontScalingSelf: true)
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
                if(snapshot.data.length!=0)
                return Container(
                    
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
                  else return Container(child: Text(''),);
            
                
            
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
    
    List<String> tempList = new List<String>();
    if(displayListNum<0)
      tempList = searchResult;
    else tempList  = saveAllBibleSentence[displayListNum];
    List<String> returnList = new List<String>();
    for(int y=0;y<tempList.length;y++)
    {
      String temp = tempList[y];
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
        tempDisplayContent+=unescape.convert(temp1).substring(temp1.indexOf('.')+1).trim();
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
