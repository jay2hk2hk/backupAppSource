class BibleTitle
{
  
  String _titleId;
  String _titleTotal;
  String _title;
  

BibleTitle(
        this._titleId,
        this._titleTotal,
        this._title,
    );

    String get titleId => _titleId;
    String get titleTotal => _titleTotal;
    String get title => _title;

BibleTitle.fromMap(dynamic obj) {
    this._titleId = obj['titleId'].toString();
    this._titleTotal = obj['titleTotal'].toString();
    this._title = obj['title'];
  }
  

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["titleId"] = _titleId;
    map["titleTotal"] = _titleTotal;
    map["title"] = _title;
    return map;
  }

    factory BibleTitle.fromJson(Map<String, dynamic> data) { 
      return new BibleTitle(
          data["titleId"],
          data["titleTotal"],
          data["title"],
      );
    }
    Map<String, dynamic> toJson() => {
        "titleId": _titleId,
        "titleTotal": _titleTotal,
        "title": _title,
    };


}