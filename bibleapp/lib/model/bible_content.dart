class BibleContent
{
  String tableName = "bible_content_cuv";
  String idName = "id";
  String titleName = "title";
  String titleNumName = "titleNum";
  String contentName = "content";
  int _id;
  String _titleId;
  String _titleNum;
  String _content;
  

BibleContent(
        this._id,
        this._titleId,
        this._titleNum,
        this._content,
    );

    int get id => _id;
    String get titleId => _titleId;
    String get titleNum => _titleNum;
    String get content => _content;

BibleContent.fromMap(dynamic obj) {
    this._id = obj['id'];
    this._titleId = obj['titleId'];
    this._titleNum = obj['titleNum'].toString();
    this._content = obj['content'];
  }
  

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = _id;
    map["titleId"] = _titleId;
    map["titleNum"] = _titleNum;
    map["content"] = _content;
    return map;
  }

    factory BibleContent.fromJson(Map<String, dynamic> data) { 
      return new BibleContent(
          data["id"],
          data["titleId"],
          data["titleNum"],
          data["content"],
      );
    }
    Map<String, dynamic> toJson() => {
        "id": _id,
        "titleId": _titleId,
        "titleNum": _titleNum,
        "content": _content,
    };


}