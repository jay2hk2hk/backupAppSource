class BibleBookmark {
  final int id;
  final int title;
  final int content;
  final int text;

  BibleBookmark({this.id, this.title, this.content, this.text});

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'text': text,
    };
  }

}
